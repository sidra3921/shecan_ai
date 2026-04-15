-- Run this if mentor gig publish fails with "mentor_gigs table not found".
-- Safe to run multiple times.

create extension if not exists pgcrypto;

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

alter table if exists public.mentor_gigs enable row level security;

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