-- SheCan AI order workflow setup
-- Adds schema elements required for delivery -> approve/revision lifecycle.
-- Run in Supabase SQL Editor.

alter table if exists public.projects
  add column if not exists delivered_at timestamptz;

alter table if exists public.projects
  add column if not exists delivery_note text;

alter table if exists public.projects
  add column if not exists revision_requested_at timestamptz;

alter table if exists public.projects
  add column if not exists revision_note text;

alter table if exists public.projects
  add column if not exists completed_at timestamptz;

create index if not exists idx_projects_freelancer_status
  on public.projects (freelancer_id, status, updated_at desc);

create index if not exists idx_projects_client_status
  on public.projects (client_id, status, updated_at desc);

-- Notifications read pattern optimization
create index if not exists idx_notifications_user_created
  on public.notifications (user_id, created_at desc);

create table if not exists public.order_events (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  event_type text not null,
  actor_id uuid,
  note text,
  created_at timestamptz not null default now()
);

create index if not exists idx_order_events_project_created
  on public.order_events (project_id, created_at desc);

alter table public.order_events enable row level security;

drop policy if exists "order_events_select_participants" on public.order_events;
create policy "order_events_select_participants"
on public.order_events
for select
to authenticated
using (
  exists (
    select 1
    from public.projects p
    where p.id = order_events.project_id
      and (p.client_id = auth.uid() or p.freelancer_id = auth.uid())
  )
);

drop policy if exists "order_events_insert_participants" on public.order_events;
create policy "order_events_insert_participants"
on public.order_events
for insert
to authenticated
with check (
  exists (
    select 1
    from public.projects p
    where p.id = order_events.project_id
      and (p.client_id = auth.uid() or p.freelancer_id = auth.uid())
  )
);

-- Keep these tables in realtime publication.
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    begin
      alter publication supabase_realtime add table public.projects;
    exception when duplicate_object then
      null;
    end;

    begin
      alter publication supabase_realtime add table public.notifications;
    exception when duplicate_object then
      null;
    end;

    begin
      alter publication supabase_realtime add table public.order_events;
    exception when duplicate_object then
      null;
    end;
  end if;
end $$;
