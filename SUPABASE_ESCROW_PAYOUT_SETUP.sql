-- =============================================
-- SheCan AI: Escrow + Payout Setup
-- Adds commission logic and escrow release function.
-- Run in Supabase SQL Editor.
-- =============================================

create extension if not exists pgcrypto;

-- Payments: escrow + commission metadata.
ALTER TABLE IF EXISTS public.payments
  ADD COLUMN IF NOT EXISTS item_type text,
  ADD COLUMN IF NOT EXISTS course_id uuid,
  ADD COLUMN IF NOT EXISTS commission_rate numeric(5,4),
  ADD COLUMN IF NOT EXISTS commission_amount numeric(12,2),
  ADD COLUMN IF NOT EXISTS payout_amount numeric(12,2);

-- Optional defaults for clarity.
ALTER TABLE IF EXISTS public.payments
  ALTER COLUMN item_type SET DEFAULT 'service';

-- Enforce valid item types when possible.
DO $$
BEGIN
  IF to_regclass('public.payments') IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_constraint
      WHERE conname = 'payments_item_type_check'
    ) THEN
      ALTER TABLE public.payments
        ADD CONSTRAINT payments_item_type_check
        CHECK (item_type IN ('service', 'course'));
    END IF;
  END IF;
END $$;

-- Track payouts (ledger-style).
create table if not exists public.payouts (
  id uuid primary key default gen_random_uuid(),
  payment_id uuid not null references public.payments(id) on delete cascade,
  client_id uuid,
  mentor_id uuid,
  amount numeric(12,2) not null default 0,
  commission_rate numeric(5,4) not null default 0,
  commission_amount numeric(12,2) not null default 0,
  released_at timestamptz not null default now()
);

create index if not exists idx_payouts_payment_id on public.payouts(payment_id);
create index if not exists idx_payouts_mentor_id on public.payouts(mentor_id);
create index if not exists idx_payouts_client_id on public.payouts(client_id);

alter table if exists public.payouts enable row level security;

drop policy if exists payouts_select_participant on public.payouts;
create policy payouts_select_participant on public.payouts
for select using (
  mentor_id = auth.uid() or client_id = auth.uid()
);

-- No direct inserts/updates by clients; use release function only.

-- Commission rate lookup.
create or replace function public.get_commission_rate(p_item_type text)
returns numeric
language plpgsql
as $$
begin
  if lower(coalesce(p_item_type, 'service')) = 'course' then
    return 0.15;
  end if;
  return 0.10;
end;
$$;

-- Auto-hold escrow on insert when method = 'escrow'.
create or replace function public.set_payment_escrow_default()
returns trigger
language plpgsql
as $$
begin
  if new.method = 'escrow' and (new.escrow_status is null or new.escrow_status = '') then
    new.escrow_status := 'held';
  elsif new.escrow_status is null or new.escrow_status = '' then
    new.escrow_status := 'pending';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_payments_escrow_default on public.payments;
create trigger trg_payments_escrow_default
before insert on public.payments
for each row execute procedure public.set_payment_escrow_default();

-- Release escrow after client approval.
create or replace function public.release_escrow(p_payment_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_payment record;
  v_project record;
  v_rate numeric;
  v_commission numeric;
  v_payout numeric;
  v_item_type text;
begin
  select * into v_payment
  from public.payments
  where id = p_payment_id
  for update;

  if v_payment is null then
    raise exception 'Payment not found';
  end if;

  if v_payment.escrow_status not in ('held', 'pending') then
    raise exception 'Escrow is not releasable';
  end if;

  v_item_type := lower(coalesce(v_payment.item_type, 'service'));

  if v_item_type = 'service' then
    if v_payment.project_id is null then
      raise exception 'Service payment missing project_id';
    end if;

    select * into v_project
    from public.projects
    where id = v_payment.project_id;

    if v_project is null then
      raise exception 'Project not found';
    end if;

    if v_project.client_id <> auth.uid() then
      raise exception 'Only the client can release escrow';
    end if;

    if coalesce(v_project.status, '') <> 'completed'
      and v_project.completed_at is null then
      raise exception 'Project not completed';
    end if;
  elsif v_item_type = 'course' then
    if v_payment.course_id is null then
      raise exception 'Course payment missing course_id';
    end if;

    if not exists (
      select 1
      from public.enrollments e
      where e.course_id = v_payment.course_id
        and e.client_id = auth.uid()
    ) then
      raise exception 'Client is not enrolled in this course';
    end if;
  else
    raise exception 'Unsupported item type';
  end if;

  v_rate := public.get_commission_rate(v_item_type);
  v_commission := round((v_payment.amount * v_rate)::numeric, 2);
  v_payout := round((v_payment.amount - v_commission)::numeric, 2);

  update public.payments
  set escrow_status = 'released',
      escrow_released_at = now(),
      commission_rate = v_rate,
      commission_amount = v_commission,
      payout_amount = v_payout,
      status = 'completed'
  where id = v_payment.id;

  insert into public.payouts (
    payment_id,
    client_id,
    mentor_id,
    amount,
    commission_rate,
    commission_amount
  ) values (
    v_payment.id,
    v_payment.from_user_id,
    v_payment.to_user_id,
    v_payout,
    v_rate,
    v_commission
  );

  return jsonb_build_object(
    'payment_id', v_payment.id,
    'commission_rate', v_rate,
    'commission_amount', v_commission,
    'payout_amount', v_payout
  );
end;
$$;

-- Optional: add payouts to realtime publication.
DO $$
BEGIN
  IF to_regclass('public.payouts') IS NOT NULL THEN
    BEGIN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.payouts;
    EXCEPTION
      WHEN duplicate_object THEN
        NULL;
      WHEN undefined_table THEN
        NULL;
    END;
  END IF;
END $$;
