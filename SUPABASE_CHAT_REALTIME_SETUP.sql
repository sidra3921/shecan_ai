-- SheCan AI chat realtime setup
-- Adds schema + RLS + indexes + realtime publication for:
-- 1) message seen timestamps/read fields
-- 2) typing indicators
-- 3) online presence
--
-- Run this in Supabase SQL Editor.

-- ==================== MESSAGES ENHANCEMENTS ====================
-- Make sure chat read-receipt columns exist for the app flow.
alter table if exists public.messages
  add column if not exists seen_at timestamptz;

alter table if exists public.messages
  add column if not exists read_by text[] default '{}'::text[];

alter table if exists public.messages
  add column if not exists is_read boolean default false;

create index if not exists idx_messages_conversation_created_at
  on public.messages (conversation_id, created_at desc);

create index if not exists idx_messages_sender_id
  on public.messages (sender_id);

-- ==================== TYPING INDICATORS ====================
create table if not exists public.typing_indicators (
  conversation_id uuid not null,
  user_id uuid not null,
  is_typing boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (conversation_id, user_id)
);

alter table public.typing_indicators enable row level security;

create index if not exists idx_typing_indicators_conversation
  on public.typing_indicators (conversation_id, updated_at desc);

create index if not exists idx_typing_indicators_user
  on public.typing_indicators (user_id);

-- Participants of a conversation can read typing state.
drop policy if exists typing_indicators_select_participant on public.typing_indicators;
create policy typing_indicators_select_participant on public.typing_indicators
for select
using (
  exists (
    select 1
    from public.conversations c
    where c.id = typing_indicators.conversation_id
      and auth.uid()::text = any (c.participant_ids)
  )
);

-- User can upsert/update their own typing record in conversations they belong to.
drop policy if exists typing_indicators_insert_own on public.typing_indicators;
create policy typing_indicators_insert_own on public.typing_indicators
for insert
with check (
  user_id = auth.uid()
  and exists (
    select 1
    from public.conversations c
    where c.id = typing_indicators.conversation_id
      and auth.uid()::text = any (c.participant_ids)
  )
);

drop policy if exists typing_indicators_update_own on public.typing_indicators;
create policy typing_indicators_update_own on public.typing_indicators
for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

-- ==================== USER PRESENCE ====================
create table if not exists public.user_presence (
  user_id uuid primary key,
  is_online boolean not null default false,
  last_seen_at timestamptz not null default now()
);

alter table public.user_presence enable row level security;

create index if not exists idx_user_presence_online
  on public.user_presence (is_online, last_seen_at desc);

-- Any authenticated user can read presence (needed for chat header online state).
drop policy if exists user_presence_select_authenticated on public.user_presence;
create policy user_presence_select_authenticated on public.user_presence
for select
using (auth.uid() is not null);

-- User can write only their own presence row.
drop policy if exists user_presence_insert_own on public.user_presence;
create policy user_presence_insert_own on public.user_presence
for insert
with check (user_id = auth.uid());

drop policy if exists user_presence_update_own on public.user_presence;
create policy user_presence_update_own on public.user_presence
for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

-- Optional cleanup policy if you need deletes from client.
drop policy if exists user_presence_delete_own on public.user_presence;
create policy user_presence_delete_own on public.user_presence
for delete
using (user_id = auth.uid());

-- ==================== REALTIME PUBLICATION ====================
-- Ensure tables are included in supabase_realtime publication.
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    begin
      alter publication supabase_realtime add table public.messages;
    exception when duplicate_object then
      null;
    end;

    begin
      alter publication supabase_realtime add table public.typing_indicators;
    exception when duplicate_object then
      null;
    end;

    begin
      alter publication supabase_realtime add table public.user_presence;
    exception when duplicate_object then
      null;
    end;

    begin
      alter publication supabase_realtime add table public.conversations;
    exception when duplicate_object then
      null;
    end;
  end if;
end $$;

-- ==================== SANITY CHECK QUERIES ====================
-- Uncomment and run if needed:
-- select * from public.typing_indicators limit 20;
-- select * from public.user_presence limit 20;
-- select id, conversation_id, sender_id, is_read, seen_at from public.messages order by created_at desc limit 20;
