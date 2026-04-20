-- SheCan AI dummy data seed
--
-- Before running this file:
-- 1) Create two Auth users in Supabase Authentication (one client, one mentor).
-- 2) Replace the placeholder UUIDs below with the real Auth user IDs.
-- 3) Run this in the Supabase SQL Editor on your test project.
--
-- This seed is designed for the app's main flows:
-- users, projects, mentor gigs, conversations, messages, notifications,
-- payments, reviews, disputes, and saved gigs.

create extension if not exists pgcrypto;

-- Replace these IDs with real Auth user IDs from Supabase Auth.
-- client_demo_user_id = the client account UUID
-- mentor_demo_user_id = the mentor account UUID

do $$
begin
  if to_regclass('public.users') is not null then
    delete from public.users
    where id in (
      '5a8a561d-4514-459a-895e-4d9fcd0ecac3',
      '37611565-1f93-4626-a03b-b186bd4f3290',
      '31ebfa46-8010-4ac8-b10c-14ac3603076e'
    );

    -- Insert only core columns that should exist in any users schema.
    insert into public.users (
      id,
      email,
      display_name,
      user_type,
      created_at,
      updated_at
    ) values
      (
        '5a8a561d-4514-459a-895e-4d9fcd0ecac3',
        'client.demo@shecan.ai',
        'Amina Noor',
        'client',
        now(),
        now()
      ),
      (
        '37611565-1f93-4626-a03b-b186bd4f3290',
        'mentor.demo@shecan.ai',
        'Sana Malik',
        'mentor',
        now(),
        now()
      ),
      (
        '31ebfa46-8010-4ac8-b10c-14ac3603076e',
        'mentor2.demo@shecan.ai',
        'Hira Khan',
        'mentor',
        now(),
        now()
      )
    on conflict (id) do update set
      email = excluded.email,
      display_name = excluded.display_name,
      user_type = excluded.user_type,
      updated_at = excluded.updated_at;

    -- Update optional columns only if they exist.
    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'users' and column_name = 'photo_url'
    ) then
      update public.users set photo_url = '' where id in (
        '5a8a561d-4514-459a-895e-4d9fcd0ecac3',
        '37611565-1f93-4626-a03b-b186bd4f3290',
        '31ebfa46-8010-4ac8-b10c-14ac3603076e'
      );
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'users' and column_name = 'phone'
    ) then
      update public.users set phone = '+92-300-1111111' where id = '5a8a561d-4514-459a-895e-4d9fcd0ecac3';
      update public.users set phone = '+92-300-2222222' where id = '37611565-1f93-4626-a03b-b186bd4f3290';
      update public.users set phone = '+92-300-3333333' where id = '31ebfa46-8010-4ac8-b10c-14ac3603076e';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'users' and column_name = 'bio'
    ) then
      update public.users
      set bio = 'Client account for testing project posting, hiring, chat, and payments.'
      where id = '5a8a561d-4514-459a-895e-4d9fcd0ecac3';

      update public.users
      set bio = 'Mentor account for testing gigs, matching, messaging, and reviews.'
      where id = '37611565-1f93-4626-a03b-b186bd4f3290';

      update public.users
      set bio = 'Second mentor account for recommendation and list testing.'
      where id = '31ebfa46-8010-4ac8-b10c-14ac3603076e';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'users' and column_name = 'skills'
    ) then
      update public.users set skills = array['branding', 'content strategy'] where id = '5a8a561d-4514-459a-895e-4d9fcd0ecac3';
      update public.users set skills = array['flutter', 'supabase', 'ui design', 'coaching'] where id = '37611565-1f93-4626-a03b-b186bd4f3290';
      update public.users set skills = array['writing', 'sales', 'social media'] where id = '31ebfa46-8010-4ac8-b10c-14ac3603076e';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'users' and column_name = 'hourly_rate'
    ) then
      update public.users set hourly_rate = 0 where id = '5a8a561d-4514-459a-895e-4d9fcd0ecac3';
      update public.users set hourly_rate = 4500 where id = '37611565-1f93-4626-a03b-b186bd4f3290';
      update public.users set hourly_rate = 3000 where id = '31ebfa46-8010-4ac8-b10c-14ac3603076e';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'users' and column_name = 'rating'
    ) then
      update public.users set rating = 0 where id = '5a8a561d-4514-459a-895e-4d9fcd0ecac3';
      update public.users set rating = 4.9 where id = '37611565-1f93-4626-a03b-b186bd4f3290';
      update public.users set rating = 4.7 where id = '31ebfa46-8010-4ac8-b10c-14ac3603076e';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'users' and column_name = 'completed_projects'
    ) then
      update public.users set completed_projects = 0 where id = '5a8a561d-4514-459a-895e-4d9fcd0ecac3';
      update public.users set completed_projects = 18 where id = '37611565-1f93-4626-a03b-b186bd4f3290';
      update public.users set completed_projects = 9 where id = '31ebfa46-8010-4ac8-b10c-14ac3603076e';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'users' and column_name = 'total_earnings'
    ) then
      update public.users set total_earnings = 0 where id = '5a8a561d-4514-459a-895e-4d9fcd0ecac3';
      update public.users set total_earnings = 81000 where id = '37611565-1f93-4626-a03b-b186bd4f3290';
      update public.users set total_earnings = 42000 where id = '31ebfa46-8010-4ac8-b10c-14ac3603076e';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'users' and column_name = 'total_reviews'
    ) then
      update public.users set total_reviews = 0 where id = '5a8a561d-4514-459a-895e-4d9fcd0ecac3';
      update public.users set total_reviews = 12 where id = '37611565-1f93-4626-a03b-b186bd4f3290';
      update public.users set total_reviews = 7 where id = '31ebfa46-8010-4ac8-b10c-14ac3603076e';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'users' and column_name = 'latitude'
    ) then
      update public.users set latitude = 24.8607 where id = '5a8a561d-4514-459a-895e-4d9fcd0ecac3';
      update public.users set latitude = 31.5204 where id = '37611565-1f93-4626-a03b-b186bd4f3290';
      update public.users set latitude = 33.6844 where id = '31ebfa46-8010-4ac8-b10c-14ac3603076e';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'users' and column_name = 'longitude'
    ) then
      update public.users set longitude = 67.0011 where id = '5a8a561d-4514-459a-895e-4d9fcd0ecac3';
      update public.users set longitude = 74.3587 where id = '37611565-1f93-4626-a03b-b186bd4f3290';
      update public.users set longitude = 73.0479 where id = '31ebfa46-8010-4ac8-b10c-14ac3603076e';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'users' and column_name = 'city'
    ) then
      update public.users set city = 'Karachi' where id = '5a8a561d-4514-459a-895e-4d9fcd0ecac3';
      update public.users set city = 'Lahore' where id = '37611565-1f93-4626-a03b-b186bd4f3290';
      update public.users set city = 'Islamabad' where id = '31ebfa46-8010-4ac8-b10c-14ac3603076e';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'users' and column_name = 'country'
    ) then
      update public.users set country = 'Pakistan' where id in (
        '5a8a561d-4514-459a-895e-4d9fcd0ecac3',
        '37611565-1f93-4626-a03b-b186bd4f3290',
        '31ebfa46-8010-4ac8-b10c-14ac3603076e'
      );
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'users' and column_name = 'address'
    ) then
      update public.users set address = 'Karachi, Pakistan' where id = '5a8a561d-4514-459a-895e-4d9fcd0ecac3';
      update public.users set address = 'Lahore, Pakistan' where id = '37611565-1f93-4626-a03b-b186bd4f3290';
      update public.users set address = 'Islamabad, Pakistan' where id = '31ebfa46-8010-4ac8-b10c-14ac3603076e';
    end if;
  end if;
end
$$;

do $$
begin
  if to_regclass('public.projects') is not null then
    delete from public.projects
    where id in (
      '44444444-4444-4444-4444-444444444444',
      '55555555-5555-5555-5555-555555555555'
    );

    -- Insert only core columns first. Then patch optional columns if present.
    insert into public.projects (
      id,
      title,
      description,
      client_id,
      created_at,
      updated_at
    ) values
      (
        '44444444-4444-4444-4444-444444444444',
        'Build a women-led tutoring landing page',
        'Need a clean landing page with signup form, service highlights, and WhatsApp contact button.',
        '5a8a561d-4514-459a-895e-4d9fcd0ecac3',
        now(),
        now()
      ),
      (
        '55555555-5555-5555-5555-555555555555',
        'Create a Supabase-powered mentor booking flow',
        'Need auth, profile data, project matching, messaging, and booking confirmation screens.',
        '5a8a561d-4514-459a-895e-4d9fcd0ecac3',
        now(),
        now()
      )
    on conflict (id) do update set
      title = excluded.title,
      description = excluded.description,
      client_id = excluded.client_id,
      updated_at = excluded.updated_at;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'projects' and column_name = 'budget'
    ) then
      update public.projects set budget = 25000 where id = '44444444-4444-4444-4444-444444444444';
      update public.projects set budget = 45000 where id = '55555555-5555-5555-5555-555555555555';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'projects' and column_name = 'deadline'
    ) then
      update public.projects set deadline = now() + interval '10 days' where id = '44444444-4444-4444-4444-444444444444';
      update public.projects set deadline = now() + interval '18 days' where id = '55555555-5555-5555-5555-555555555555';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'projects' and column_name = 'status'
    ) then
      update public.projects set status = 'pending' where id = '44444444-4444-4444-4444-444444444444';
      update public.projects set status = 'in-progress' where id = '55555555-5555-5555-5555-555555555555';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'projects' and column_name = 'freelancer_id'
    ) then
      update public.projects set freelancer_id = null where id = '44444444-4444-4444-4444-444444444444';
      update public.projects set freelancer_id = '37611565-1f93-4626-a03b-b186bd4f3290' where id = '55555555-5555-5555-5555-555555555555';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'projects' and column_name = 'skills'
    ) then
      update public.projects set skills = array['flutter', 'ui design', 'copywriting'] where id = '44444444-4444-4444-4444-444444444444';
      update public.projects set skills = array['supabase', 'state management', 'chat', 'payments'] where id = '55555555-5555-5555-5555-555555555555';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'projects' and column_name = 'progress'
    ) then
      update public.projects set progress = 0 where id = '44444444-4444-4444-4444-444444444444';
      update public.projects set progress = 55 where id = '55555555-5555-5555-5555-555555555555';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'projects' and column_name = 'latitude'
    ) then
      update public.projects set latitude = 24.8607 where id in (
        '44444444-4444-4444-4444-444444444444',
        '55555555-5555-5555-5555-555555555555'
      );
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'projects' and column_name = 'longitude'
    ) then
      update public.projects set longitude = 67.0011 where id in (
        '44444444-4444-4444-4444-444444444444',
        '55555555-5555-5555-5555-555555555555'
      );
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'projects' and column_name = 'city'
    ) then
      update public.projects set city = 'Karachi' where id in (
        '44444444-4444-4444-4444-444444444444',
        '55555555-5555-5555-5555-555555555555'
      );
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'projects' and column_name = 'country'
    ) then
      update public.projects set country = 'Pakistan' where id in (
        '44444444-4444-4444-4444-444444444444',
        '55555555-5555-5555-5555-555555555555'
      );
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'projects' and column_name = 'address'
    ) then
      update public.projects set address = 'Karachi, Pakistan' where id in (
        '44444444-4444-4444-4444-444444444444',
        '55555555-5555-5555-5555-555555555555'
      );
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'projects' and column_name = 'category'
    ) then
      update public.projects set category = 'design' where id = '44444444-4444-4444-4444-444444444444';
      update public.projects set category = 'development' where id = '55555555-5555-5555-5555-555555555555';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'projects' and column_name = 'experience_level'
    ) then
      update public.projects set experience_level = 'intermediate' where id = '44444444-4444-4444-4444-444444444444';
      update public.projects set experience_level = 'expert' where id = '55555555-5555-5555-5555-555555555555';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'projects' and column_name = 'is_urgent'
    ) then
      update public.projects set is_urgent = true where id = '44444444-4444-4444-4444-444444444444';
      update public.projects set is_urgent = false where id = '55555555-5555-5555-5555-555555555555';
    end if;
  end if;
end
$$;

do $$
begin
  if to_regclass('public.mentor_gigs') is not null then
    delete from public.mentor_gigs
    where id in (
      '66666666-6666-6666-6666-666666666666',
      '77777777-7777-7777-7777-777777777777'
    );

    insert into public.mentor_gigs (
      id,
      mentor_id,
      title,
      description,
      skills,
      category,
      experience_level,
      hourly_rate,
      is_active,
      created_at,
      updated_at
    ) values
      (
        '66666666-6666-6666-6666-666666666666',
        '37611565-1f93-4626-a03b-b186bd4f3290',
        'Women-led Flutter MVP development',
        'I build mobile MVPs with Supabase auth, profiles, chat, and admin-friendly data flows.',
        array['flutter', 'supabase', 'firebase migration', 'ui implementation'],
        'development',
        'expert',
        4500,
        true,
        now(),
        now()
      ),
      (
        '77777777-7777-7777-7777-777777777777',
        '31ebfa46-8010-4ac8-b10c-14ac3603076e',
        'Content strategy and launch support',
        'I help small businesses define offers, content, and launch plans for first customers.',
        array['content strategy', 'social media', 'copywriting'],
        'marketing',
        'intermediate',
        3000,
        true,
        now(),
        now()
      )
    on conflict (id) do update set
      mentor_id = excluded.mentor_id,
      title = excluded.title,
      description = excluded.description,
      skills = excluded.skills,
      category = excluded.category,
      experience_level = excluded.experience_level,
      hourly_rate = excluded.hourly_rate,
      is_active = excluded.is_active,
      updated_at = excluded.updated_at;
  end if;
end
$$;

do $$
begin
  if to_regclass('public.conversations') is not null then
    delete from public.conversations
    where id = '88888888-8888-8888-8888-888888888888';

    insert into public.conversations (
      id,
      participant_ids,
      participant_names,
      participant_avatars,
      last_message,
      last_message_sender_id,
      last_message_timestamp,
      unread_count,
      created_at,
      updated_at,
      project_id,
      project_title
    ) values (
      '88888888-8888-8888-8888-888888888888',
      array['5a8a561d-4514-459a-895e-4d9fcd0ecac3', '37611565-1f93-4626-a03b-b186bd4f3290'],
      jsonb_build_object(
        '5a8a561d-4514-459a-895e-4d9fcd0ecac3', 'Amina Noor',
        '37611565-1f93-4626-a03b-b186bd4f3290', 'Sana Malik'
      ),
      jsonb_build_object(
        '5a8a561d-4514-459a-895e-4d9fcd0ecac3', '',
        '37611565-1f93-4626-a03b-b186bd4f3290', ''
      ),
      'Hello, can we discuss the project scope?',
      '5a8a561d-4514-459a-895e-4d9fcd0ecac3',
      now() - interval '20 minutes',
      1,
      now() - interval '1 day',
      now() - interval '20 minutes',
      '44444444-4444-4444-4444-444444444444',
      'Build a women-led tutoring landing page'
    ) on conflict (id) do update set
      participant_ids = excluded.participant_ids,
      participant_names = excluded.participant_names,
      participant_avatars = excluded.participant_avatars,
      last_message = excluded.last_message,
      last_message_sender_id = excluded.last_message_sender_id,
      last_message_timestamp = excluded.last_message_timestamp,
      unread_count = excluded.unread_count,
      updated_at = excluded.updated_at,
      project_id = excluded.project_id,
      project_title = excluded.project_title;
  end if;
end
$$;

do $$
begin
  if to_regclass('public.messages') is not null then
    delete from public.messages
    where id in (
      '99999999-9999-9999-9999-999999999999',
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
    );

    -- Insert only likely-core columns first.
    insert into public.messages (
      id,
      conversation_id,
      sender_id,
      receiver_id,
      content,
      created_at
    ) values
      (
        '99999999-9999-9999-9999-999999999999',
        '88888888-8888-8888-8888-888888888888',
        '5a8a561d-4514-459a-895e-4d9fcd0ecac3',
        '37611565-1f93-4626-a03b-b186bd4f3290',
        'Hello, I need a polished landing page by next week.',
        now() - interval '20 minutes'
      ),
      (
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        '88888888-8888-8888-8888-888888888888',
        '37611565-1f93-4626-a03b-b186bd4f3290',
        '5a8a561d-4514-459a-895e-4d9fcd0ecac3',
        'Yes. I can help with scope, screens, and Supabase integration.',
        now() - interval '10 minutes'
      )
    on conflict (id) do update set
      conversation_id = excluded.conversation_id,
      sender_id = excluded.sender_id,
      receiver_id = excluded.receiver_id,
      content = excluded.content,
      created_at = excluded.created_at;

    -- Patch optional columns only when present.
    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'messages' and column_name = 'sender_name'
    ) then
      update public.messages set sender_name = 'Amina Noor' where id = '99999999-9999-9999-9999-999999999999';
      update public.messages set sender_name = 'Sana Malik' where id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'messages' and column_name = 'sender_avatar'
    ) then
      update public.messages set sender_avatar = '' where id in (
        '99999999-9999-9999-9999-999999999999',
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      );
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'messages' and column_name = 'attachment_urls'
    ) then
      update public.messages set attachment_urls = array[]::text[] where id in (
        '99999999-9999-9999-9999-999999999999',
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      );
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'messages' and column_name = 'read_by'
    ) then
      update public.messages set read_by = array['5a8a561d-4514-459a-895e-4d9fcd0ecac3'] where id = '99999999-9999-9999-9999-999999999999';
      update public.messages set read_by = array['5a8a561d-4514-459a-895e-4d9fcd0ecac3', '37611565-1f93-4626-a03b-b186bd4f3290'] where id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'messages' and column_name = 'is_read'
    ) then
      update public.messages set is_read = true where id = '99999999-9999-9999-9999-999999999999';
      update public.messages set is_read = false where id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
    end if;
  end if;
end
$$;

do $$
begin
  if to_regclass('public.notifications') is not null then
    delete from public.notifications
    where id in (
      'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      'cccccccc-cccc-cccc-cccc-cccccccccccc'
    );

    begin
      -- Preferred snake_case schema.
      insert into public.notifications (
        id,
        user_id,
        type,
        title,
        message,
        is_read,
        data,
        created_at
      ) values
        (
          'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
          '5a8a561d-4514-459a-895e-4d9fcd0ecac3',
          'project_update',
          'New mentor match found',
          'A mentor with matching skills is available for your project.',
          false,
          jsonb_build_object('project_id', '44444444-4444-4444-4444-444444444444'),
          now() - interval '30 minutes'
        ),
        (
          'cccccccc-cccc-cccc-cccc-cccccccccccc',
          '37611565-1f93-4626-a03b-b186bd4f3290',
          'message',
          'New message received',
          'You have a new message from the client.',
          false,
          jsonb_build_object('conversation_id', '88888888-8888-8888-8888-888888888888'),
          now() - interval '15 minutes'
        )
      on conflict (id) do update set
        user_id = excluded.user_id,
        type = excluded.type,
        title = excluded.title,
        message = excluded.message,
        is_read = excluded.is_read,
        data = excluded.data,
        created_at = excluded.created_at;
    exception when undefined_column then
      begin
        -- Fallback camelCase schema.
        insert into public.notifications (
          id,
          userId,
          type,
          title,
          message,
          read,
          data,
          createdAt
        ) values
          (
            'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
            '5a8a561d-4514-459a-895e-4d9fcd0ecac3',
            'project_update',
            'New mentor match found',
            'A mentor with matching skills is available for your project.',
            false,
            jsonb_build_object('project_id', '44444444-4444-4444-4444-444444444444'),
            now() - interval '30 minutes'
          ),
          (
            'cccccccc-cccc-cccc-cccc-cccccccccccc',
            '37611565-1f93-4626-a03b-b186bd4f3290',
            'message',
            'New message received',
            'You have a new message from the client.',
            false,
            jsonb_build_object('conversation_id', '88888888-8888-8888-8888-888888888888'),
            now() - interval '15 minutes'
          )
        on conflict (id) do update set
          userId = excluded.userId,
          type = excluded.type,
          title = excluded.title,
          message = excluded.message,
          read = excluded.read,
          data = excluded.data,
          createdAt = excluded.createdAt;
      exception when others then
        raise notice 'Skipped notifications seed due schema mismatch: %', sqlerrm;
      end;
    end;
  end if;
end
$$;

do $$
begin
  if to_regclass('public.payments') is not null then
    delete from public.payments
    where id = 'dddddddd-dddd-dddd-dddd-dddddddddddd';

    begin
      insert into public.payments (
        id,
        project_id,
        from_user_id,
        to_user_id,
        amount,
        status,
        method,
        created_at,
        stripe_payment_intent_id,
        receipt_url
      ) values (
        'dddddddd-dddd-dddd-dddd-dddddddddddd',
        '55555555-5555-5555-5555-555555555555',
        '5a8a561d-4514-459a-895e-4d9fcd0ecac3',
        '37611565-1f93-4626-a03b-b186bd4f3290',
        45000,
        'completed',
        'card',
        now() - interval '2 hours',
        'pi_dummy_001',
        'https://example.com/receipt/pi_dummy_001'
      ) on conflict (id) do update set
        project_id = excluded.project_id,
        from_user_id = excluded.from_user_id,
        to_user_id = excluded.to_user_id,
        amount = excluded.amount,
        status = excluded.status,
        method = excluded.method,
        created_at = excluded.created_at,
        stripe_payment_intent_id = excluded.stripe_payment_intent_id,
        receipt_url = excluded.receipt_url;
    exception when undefined_column then
      begin
        insert into public.payments (
          id,
          projectId,
          fromUserId,
          toUserId,
          amount,
          status,
          method,
          createdAt,
          stripePaymentIntentId,
          receiptUrl
        ) values (
          'dddddddd-dddd-dddd-dddd-dddddddddddd',
          '55555555-5555-5555-5555-555555555555',
          '5a8a561d-4514-459a-895e-4d9fcd0ecac3',
          '37611565-1f93-4626-a03b-b186bd4f3290',
          45000,
          'completed',
          'card',
          now() - interval '2 hours',
          'pi_dummy_001',
          'https://example.com/receipt/pi_dummy_001'
        ) on conflict (id) do update set
          projectId = excluded.projectId,
          fromUserId = excluded.fromUserId,
          toUserId = excluded.toUserId,
          amount = excluded.amount,
          status = excluded.status,
          method = excluded.method,
          createdAt = excluded.createdAt,
          stripePaymentIntentId = excluded.stripePaymentIntentId,
          receiptUrl = excluded.receiptUrl;
      exception when others then
        raise notice 'Skipped payments seed due schema mismatch: %', sqlerrm;
      end;
    end;
  end if;
end
$$;

do $$
begin
  if to_regclass('public.reviews') is not null then
    delete from public.reviews
    where id = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';

    begin
      insert into public.reviews (
        id,
        project_id,
        reviewer_id,
        reviewed_user_id,
        rating,
        comment,
        tags,
        created_at,
        updated_at,
        verified,
        helpful_count,
        fraud_status,
        fraud_reason,
        attachment_urls
      ) values (
        'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
        '55555555-5555-5555-5555-555555555555',
        '5a8a561d-4514-459a-895e-4d9fcd0ecac3',
        '37611565-1f93-4626-a03b-b186bd4f3290',
        5,
        'Clear communication, fast delivery, and strong Supabase integration skills.',
        array['professional', 'reliable', 'responsive'],
        now() - interval '1 day',
        now() - interval '1 day',
        true,
        3,
        'none',
        null,
        array[]::text[]
      ) on conflict (id) do update set
        project_id = excluded.project_id,
        reviewer_id = excluded.reviewer_id,
        reviewed_user_id = excluded.reviewed_user_id,
        rating = excluded.rating,
        comment = excluded.comment,
        tags = excluded.tags,
        created_at = excluded.created_at,
        updated_at = excluded.updated_at,
        verified = excluded.verified,
        helpful_count = excluded.helpful_count,
        fraud_status = excluded.fraud_status,
        fraud_reason = excluded.fraud_reason,
        attachment_urls = excluded.attachment_urls;
    exception when undefined_column then
      begin
        insert into public.reviews (
          id,
          projectId,
          reviewerId,
          reviewedUserId,
          rating,
          comment,
          tags,
          createdAt,
          updatedAt,
          verified,
          helpfulCount,
          fraudStatus,
          fraudReason,
          attachmentUrls
        ) values (
          'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
          '55555555-5555-5555-5555-555555555555',
          '5a8a561d-4514-459a-895e-4d9fcd0ecac3',
          '37611565-1f93-4626-a03b-b186bd4f3290',
          5,
          'Clear communication, fast delivery, and strong Supabase integration skills.',
          array['professional', 'reliable', 'responsive'],
          now() - interval '1 day',
          now() - interval '1 day',
          true,
          3,
          'none',
          null,
          array[]::text[]
        ) on conflict (id) do update set
          projectId = excluded.projectId,
          reviewerId = excluded.reviewerId,
          reviewedUserId = excluded.reviewedUserId,
          rating = excluded.rating,
          comment = excluded.comment,
          tags = excluded.tags,
          createdAt = excluded.createdAt,
          updatedAt = excluded.updatedAt,
          verified = excluded.verified,
          helpfulCount = excluded.helpfulCount,
          fraudStatus = excluded.fraudStatus,
          fraudReason = excluded.fraudReason,
          attachmentUrls = excluded.attachmentUrls;
      exception when others then
        raise notice 'Skipped reviews seed due schema mismatch: %', sqlerrm;
      end;
    end;
  end if;
end
$$;

do $$
begin
  if to_regclass('public.disputes') is not null then
    -- Minimal disputes seed for current schema (project_id + initiator_id).
    delete from public.disputes
    where project_id = '55555555-5555-5555-5555-555555555555'
      and initiator_id = '5a8a561d-4514-459a-895e-4d9fcd0ecac3';

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'disputes' and column_name = 'project_id'
    ) and exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'disputes' and column_name = 'initiator_id'
    ) then
      insert into public.disputes (
        project_id,
        initiator_id
      ) values (
        '55555555-5555-5555-5555-555555555555',
        '5a8a561d-4514-459a-895e-4d9fcd0ecac3'
      );
    end if;
  end if;
end
$$;

do $$
begin
  if to_regclass('public.saved_gigs') is not null then
    delete from public.saved_gigs
    where id = '12121212-1212-1212-1212-121212121212';

    insert into public.saved_gigs (
      id,
      user_id,
      project_id,
      project_title,
      saved_at
    ) values (
      '12121212-1212-1212-1212-121212121212',
      '37611565-1f93-4626-a03b-b186bd4f3290',
      '44444444-4444-4444-4444-444444444444',
      'Build a women-led tutoring landing page',
      now() - interval '4 hours'
    ) on conflict (id) do update set
      user_id = excluded.user_id,
      project_id = excluded.project_id,
      project_title = excluded.project_title,
      saved_at = excluded.saved_at;
  end if;
end
$$;
