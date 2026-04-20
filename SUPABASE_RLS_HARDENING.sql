-- Apply these policies in Supabase SQL Editor for Fiverr-style role/data isolation.
-- Run in a safe environment and adapt if your schema differs.

-- 1) Ensure RLS is enabled.
alter table if exists public.users enable row level security;
alter table if exists public.projects enable row level security;
alter table if exists public.saved_gigs enable row level security;
alter table if exists public.view_history enable row level security;
alter table if exists public.messages enable row level security;
alter table if exists public.notifications enable row level security;
alter table if exists public.payments enable row level security;
alter table if exists public.disputes enable row level security;
alter table if exists public.reviews enable row level security;
alter table if exists public.project_applications enable row level security;
alter table if exists public.mentor_gigs enable row level security;

-- 2) Users: users can read/update only their own profile.
drop policy if exists users_select_own on public.users;
create policy users_select_own on public.users
for select using (id = auth.uid());

drop policy if exists users_update_own on public.users;
create policy users_update_own on public.users
for update using (id = auth.uid()) with check (id = auth.uid());

-- 3) Projects:
-- Clients can create projects for themselves only.
drop policy if exists projects_insert_client on public.projects;
create policy projects_insert_client on public.projects
for insert with check (client_id = auth.uid());

-- Client can read their own projects; mentor can read assigned projects.
drop policy if exists projects_select_participant on public.projects;
create policy projects_select_participant on public.projects
for select using (
  client_id = auth.uid() or freelancer_id = auth.uid()
);

-- Clients can update their own projects, mentors can update assigned projects.
drop policy if exists projects_update_participant on public.projects;
create policy projects_update_participant on public.projects
for update using (
  client_id = auth.uid() or freelancer_id = auth.uid()
) with check (
  client_id = auth.uid() or freelancer_id = auth.uid()
);

-- 4) Saved gigs and view history are private per user.
do $$
begin
  if to_regclass('public.saved_gigs') is not null then
    execute 'drop policy if exists saved_gigs_owner_all on public.saved_gigs';
    execute 'create policy saved_gigs_owner_all on public.saved_gigs
      for all using (user_id = auth.uid()) with check (user_id = auth.uid())';
  end if;
end
$$;

do $$
begin
  if to_regclass('public.view_history') is not null then
    execute 'drop policy if exists view_history_owner_all on public.view_history';
    execute 'create policy view_history_owner_all on public.view_history
      for all using (user_id = auth.uid()) with check (user_id = auth.uid())';
  end if;
end
$$;

-- 5) Messages: sender can insert, conversation participants can read.
-- NOTE: This assumes messages has sender_id and conversation_id and conversations table has participant_ids uuid[].
do $$
begin
  if to_regclass('public.messages') is not null then
    execute 'drop policy if exists messages_insert_sender on public.messages';
    execute 'create policy messages_insert_sender on public.messages
      for insert with check (sender_id = auth.uid())';

    -- Adjust this policy if your conversation membership model differs.
    if to_regclass('public.conversations') is not null then
      execute 'drop policy if exists messages_select_participant on public.messages';
      execute 'create policy messages_select_participant on public.messages
        for select using (
          exists (
            select 1
            from public.conversations c
            where c.id = messages.conversation_id
              and auth.uid() = any(c.participant_ids)
          )
        )';
    end if;
  end if;
end
$$;

-- 6) Notifications are private per receiver.
do $$
begin
  if to_regclass('public.notifications') is not null then
    execute 'drop policy if exists notifications_owner_all on public.notifications';
    execute 'create policy notifications_owner_all on public.notifications
      for all using (user_id = auth.uid()) with check (user_id = auth.uid())';
  end if;
end
$$;

-- 7) Payments: only payer/payee can read; payer creates.
do $$
declare
  select_predicate text := '';
  insert_predicate text := '';
begin
  if to_regclass('public.payments') is not null then
    if exists (
      select 1
      from information_schema.columns
      where table_schema = 'public'
        and table_name = 'payments'
        and column_name = 'from_user_id'
    ) then
      select_predicate := select_predicate || 'from_user_id = auth.uid()';
      insert_predicate := insert_predicate || 'from_user_id = auth.uid()';
    end if;

    if exists (
      select 1
      from information_schema.columns
      where table_schema = 'public'
        and table_name = 'payments'
        and column_name = 'to_user_id'
    ) then
      if select_predicate <> '' then
        select_predicate := select_predicate || ' or ';
      end if;
      select_predicate := select_predicate || 'to_user_id = auth.uid()';
    end if;

    if exists (
      select 1
      from information_schema.columns
      where table_schema = 'public'
        and table_name = 'payments'
        and column_name = 'user_id'
    ) then
      if select_predicate <> '' then
        select_predicate := select_predicate || ' or ';
      end if;
      select_predicate := select_predicate || 'user_id = auth.uid()';

      if insert_predicate <> '' then
        insert_predicate := insert_predicate || ' or ';
      end if;
      insert_predicate := insert_predicate || 'user_id = auth.uid()';
    end if;

    if exists (
      select 1
      from information_schema.columns
      where table_schema = 'public'
        and table_name = 'payments'
        and column_name = 'payer_id'
    ) then
      if select_predicate <> '' then
        select_predicate := select_predicate || ' or ';
      end if;
      select_predicate := select_predicate || 'payer_id = auth.uid()';

      if insert_predicate <> '' then
        insert_predicate := insert_predicate || ' or ';
      end if;
      insert_predicate := insert_predicate || 'payer_id = auth.uid()';
    end if;

    if exists (
      select 1
      from information_schema.columns
      where table_schema = 'public'
        and table_name = 'payments'
        and column_name = 'payee_id'
    ) then
      if select_predicate <> '' then
        select_predicate := select_predicate || ' or ';
      end if;
      select_predicate := select_predicate || 'payee_id = auth.uid()';
    end if;

    execute 'drop policy if exists payments_select_participant on public.payments';
    if select_predicate <> '' then
      execute 'create policy payments_select_participant on public.payments
        for select using (' || select_predicate || ')';
    end if;

    execute 'drop policy if exists payments_insert_payer on public.payments';
    if insert_predicate <> '' then
      execute 'create policy payments_insert_payer on public.payments
        for insert with check (' || insert_predicate || ')';
    end if;
  end if;
end
$$;

-- 8) Disputes/reviews basic participant safety.
do $$
declare
  disputes_select_predicate text := '';
begin
  if to_regclass('public.disputes') is not null then
    if exists (
      select 1
      from information_schema.columns
      where table_schema = 'public'
        and table_name = 'disputes'
        and column_name = 'raised_by'
    ) then
      disputes_select_predicate := disputes_select_predicate || 'raised_by = auth.uid()';
    end if;

    if exists (
      select 1
      from information_schema.columns
      where table_schema = 'public'
        and table_name = 'disputes'
        and column_name = 'against_user'
    ) then
      if disputes_select_predicate <> '' then
        disputes_select_predicate := disputes_select_predicate || ' or ';
      end if;
      disputes_select_predicate := disputes_select_predicate || 'against_user = auth.uid()';
    end if;

    if exists (
      select 1
      from information_schema.columns
      where table_schema = 'public'
        and table_name = 'disputes'
        and column_name = 'user_id'
    ) then
      if disputes_select_predicate <> '' then
        disputes_select_predicate := disputes_select_predicate || ' or ';
      end if;
      disputes_select_predicate := disputes_select_predicate || 'user_id = auth.uid()';
    end if;

    if exists (
      select 1
      from information_schema.columns
      where table_schema = 'public'
        and table_name = 'disputes'
        and column_name = 'client_id'
    ) then
      if disputes_select_predicate <> '' then
        disputes_select_predicate := disputes_select_predicate || ' or ';
      end if;
      disputes_select_predicate := disputes_select_predicate || 'client_id = auth.uid()';
    end if;

    if exists (
      select 1
      from information_schema.columns
      where table_schema = 'public'
        and table_name = 'disputes'
        and column_name = 'freelancer_id'
    ) then
      if disputes_select_predicate <> '' then
        disputes_select_predicate := disputes_select_predicate || ' or ';
      end if;
      disputes_select_predicate := disputes_select_predicate || 'freelancer_id = auth.uid()';
    end if;

    execute 'drop policy if exists disputes_select_participant on public.disputes';
    if disputes_select_predicate <> '' then
      execute 'create policy disputes_select_participant on public.disputes
        for select using (' || disputes_select_predicate || ')';
    end if;
  end if;
end
$$;

do $$
begin
  if to_regclass('public.reviews') is not null then
    execute 'drop policy if exists reviews_select_public on public.reviews';
    execute 'create policy reviews_select_public on public.reviews
      for select using (true)';

    execute 'drop policy if exists reviews_insert_reviewer on public.reviews';
    execute 'create policy reviews_insert_reviewer on public.reviews
      for insert with check (reviewer_id = auth.uid())';
  end if;
end
$$;

-- 9) Project applications: mentors apply; project owners review; participants can read their own rows.
create table if not exists public.project_applications (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  client_id uuid not null references public.users(id) on delete cascade,
  applicant_id uuid not null references public.users(id) on delete cascade,
  applicant_name text,
  applicant_email text,
  cover_note text,
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists ux_project_applications_project_applicant
on public.project_applications(project_id, applicant_id);

drop policy if exists project_applications_select_participant on public.project_applications;
create policy project_applications_select_participant on public.project_applications
for select using (
  applicant_id = auth.uid() or client_id = auth.uid()
);

drop policy if exists project_applications_insert_mentor on public.project_applications;
create policy project_applications_insert_mentor on public.project_applications
for insert with check (
  applicant_id = auth.uid()
  and exists (
    select 1
    from public.users u
    where u.id = auth.uid()
      and lower(u.user_type) = 'mentor'
  )
);

drop policy if exists project_applications_update_owner_or_applicant on public.project_applications;
create policy project_applications_update_owner_or_applicant on public.project_applications
for update using (
  applicant_id = auth.uid() or client_id = auth.uid()
) with check (
  applicant_id = auth.uid() or client_id = auth.uid()
);

-- 10) Mentor gigs: mentors create/manage their gigs; clients can discover active gigs.
create table if not exists public.mentor_gigs (
  id uuid primary key default gen_random_uuid(),
  mentor_id uuid not null references public.users(id) on delete cascade,
  title text not null,
  description text not null,
  skills text[] not null default '{}',
  category text,
  experience_level text,
  hourly_rate numeric(10,2) not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_mentor_gigs_mentor_id on public.mentor_gigs(mentor_id);
create index if not exists idx_mentor_gigs_active on public.mentor_gigs(is_active);

drop policy if exists mentor_gigs_select_public on public.mentor_gigs;
create policy mentor_gigs_select_public on public.mentor_gigs
for select using (true);

drop policy if exists mentor_gigs_insert_owner_mentor on public.mentor_gigs;
create policy mentor_gigs_insert_owner_mentor on public.mentor_gigs
for insert with check (
  mentor_id = auth.uid()
  and exists (
    select 1
    from public.users u
    where u.id = auth.uid()
      and lower(u.user_type) = 'mentor'
  )
);

drop policy if exists mentor_gigs_update_owner on public.mentor_gigs;
create policy mentor_gigs_update_owner on public.mentor_gigs
for update using (mentor_id = auth.uid())
with check (mentor_id = auth.uid());

drop policy if exists mentor_gigs_delete_owner on public.mentor_gigs;
create policy mentor_gigs_delete_owner on public.mentor_gigs
for delete using (mentor_id = auth.uid());
