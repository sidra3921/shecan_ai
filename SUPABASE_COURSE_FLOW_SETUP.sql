-- =============================================
-- SheCan AI: Course Flow Setup
-- Creates dedicated course/enrollment entities to keep
-- Services and Courses separate.
-- =============================================

create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(),
  mentor_id uuid not null,
  title text not null,
  description text not null,
  price numeric(12,2) not null default 0,
  category text,
  duration text,
  thumbnail_url text,
  video_url text,
  level text,
  rating numeric(4,2) not null default 0,
  total_students integer not null default 0,
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_courses_mentor_id on public.courses(mentor_id);
create index if not exists idx_courses_created_at on public.courses(created_at desc);

create table if not exists public.enrollments (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  client_id uuid not null,
  mentor_id uuid,
  progress_percent numeric(5,2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(course_id, client_id)
);

create index if not exists idx_enrollments_course_id on public.enrollments(course_id);
create index if not exists idx_enrollments_client_id on public.enrollments(client_id);
create index if not exists idx_enrollments_mentor_id on public.enrollments(mentor_id);

create or replace function public.sync_course_students_count()
returns trigger
language plpgsql
as $$
begin
  if (tg_op = 'INSERT') then
    update public.courses
    set total_students = total_students + 1,
        updated_at = now()
    where id = new.course_id;
    return new;
  elsif (tg_op = 'DELETE') then
    update public.courses
    set total_students = greatest(total_students - 1, 0),
        updated_at = now()
    where id = old.course_id;
    return old;
  end if;
  return null;
end;
$$;

drop trigger if exists trg_course_students_count_insert on public.enrollments;
create trigger trg_course_students_count_insert
after insert on public.enrollments
for each row execute procedure public.sync_course_students_count();

drop trigger if exists trg_course_students_count_delete on public.enrollments;
create trigger trg_course_students_count_delete
after delete on public.enrollments
for each row execute procedure public.sync_course_students_count();

alter table public.courses enable row level security;
alter table public.enrollments enable row level security;

drop policy if exists "courses public read" on public.courses;
create policy "courses public read"
on public.courses
for select
using (is_published = true or auth.uid() = mentor_id);

drop policy if exists "mentor manages own courses" on public.courses;
create policy "mentor manages own courses"
on public.courses
for all
using (auth.uid() = mentor_id)
with check (auth.uid() = mentor_id);

drop policy if exists "clients read own enrollments" on public.enrollments;
create policy "clients read own enrollments"
on public.enrollments
for select
using (auth.uid() = client_id or auth.uid() = mentor_id);

drop policy if exists "client inserts enrollment" on public.enrollments;
create policy "client inserts enrollment"
on public.enrollments
for insert
with check (auth.uid() = client_id);

drop policy if exists "client updates own enrollment" on public.enrollments;
create policy "client updates own enrollment"
on public.enrollments
for update
using (auth.uid() = client_id)
with check (auth.uid() = client_id);

do $$
begin
  begin
    alter publication supabase_realtime add table public.courses;
  exception when duplicate_object then
    null;
  end;

  begin
    alter publication supabase_realtime add table public.enrollments;
  exception when duplicate_object then
    null;
  end;
end $$;
