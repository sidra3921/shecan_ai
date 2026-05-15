-- =============================================
-- SheCan AI: Gig Moderation Guardrails
-- Blocks prohibited content for mentor_gigs via trigger.
-- Run in Supabase SQL Editor.
-- =============================================

create extension if not exists pgcrypto;
create extension if not exists pg_trgm;

create or replace function public.normalize_moderation_text(p_text text)
returns text
language sql
immutable
as $$
  select regexp_replace(
    replace(
      translate(lower(coalesce(p_text, '')), '01345789@!|$', 'oieastbgaiis'),
      '*',
      ''
    ),
    '[^a-z0-9]+',
    '',
    'g'
  );
$$;

create or replace function public.moderation_skeleton(p_text text)
returns text
language sql
immutable
as $$
  select regexp_replace(public.normalize_moderation_text(p_text), '[aeiou]+', '', 'g');
$$;

create table if not exists public.illegal_keywords (
  id bigserial primary key,
  keyword text not null,
  category text not null,
  severity text not null default 'high',
  normalized_keyword text not null
);

create unique index if not exists ux_illegal_keywords_normalized
on public.illegal_keywords(normalized_keyword);

insert into public.illegal_keywords (keyword, category, severity, normalized_keyword)
values
  ('cocaine', 'drugs', 'high', public.normalize_moderation_text('cocaine')),
  ('heroin', 'drugs', 'high', public.normalize_moderation_text('heroin')),
  ('meth', 'drugs', 'high', public.normalize_moderation_text('meth')),
  ('marijuana sale', 'drugs', 'high', public.normalize_moderation_text('marijuana sale')),
  ('weed delivery', 'drugs', 'high', public.normalize_moderation_text('weed delivery')),
  ('ecstasy', 'drugs', 'high', public.normalize_moderation_text('ecstasy')),
  ('lsd', 'drugs', 'high', public.normalize_moderation_text('lsd')),
  ('fentanyl', 'drugs', 'high', public.normalize_moderation_text('fentanyl')),
  ('narcotics', 'drugs', 'high', public.normalize_moderation_text('narcotics')),
  ('illegal drugs', 'drugs', 'high', public.normalize_moderation_text('illegal drugs')),
  ('drug trafficking', 'drugs', 'critical', public.normalize_moderation_text('drug trafficking')),
  ('sell drugs', 'drugs', 'critical', public.normalize_moderation_text('sell drugs')),
  ('buy drugs', 'drugs', 'critical', public.normalize_moderation_text('buy drugs')),
  ('alcohol sales', 'regulated-goods', 'high', public.normalize_moderation_text('alcohol sales')),
  ('alcoholic sales', 'regulated-goods', 'high', public.normalize_moderation_text('alcoholic sales')),
  ('liquor sales', 'regulated-goods', 'high', public.normalize_moderation_text('liquor sales')),
  ('gun for sale', 'weapons', 'critical', public.normalize_moderation_text('gun for sale')),
  ('firearm', 'weapons', 'high', public.normalize_moderation_text('firearm')),
  ('ak-47', 'weapons', 'critical', public.normalize_moderation_text('ak-47')),
  ('pistol', 'weapons', 'high', public.normalize_moderation_text('pistol')),
  ('ammunition', 'weapons', 'high', public.normalize_moderation_text('ammunition')),
  ('bomb making', 'weapons', 'critical', public.normalize_moderation_text('bomb making')),
  ('explosives', 'weapons', 'critical', public.normalize_moderation_text('explosives')),
  ('grenade', 'weapons', 'critical', public.normalize_moderation_text('grenade')),
  ('sniper', 'weapons', 'high', public.normalize_moderation_text('sniper')),
  ('hitman', 'weapons', 'critical', public.normalize_moderation_text('hitman')),
  ('assassination', 'weapons', 'critical', public.normalize_moderation_text('assassination')),
  ('weapon trafficking', 'weapons', 'critical', public.normalize_moderation_text('weapon trafficking')),
  ('hacking service', 'cybercrime', 'high', public.normalize_moderation_text('hacking service')),
  ('hack account', 'cybercrime', 'high', public.normalize_moderation_text('hack account')),
  ('facebook hack', 'cybercrime', 'high', public.normalize_moderation_text('facebook hack')),
  ('instagram hack', 'cybercrime', 'high', public.normalize_moderation_text('instagram hack')),
  ('whatsapp hack', 'cybercrime', 'high', public.normalize_moderation_text('whatsapp hack')),
  ('email hack', 'cybercrime', 'high', public.normalize_moderation_text('email hack')),
  ('phishing', 'cybercrime', 'critical', public.normalize_moderation_text('phishing')),
  ('carding', 'cybercrime', 'critical', public.normalize_moderation_text('carding')),
  ('malware', 'cybercrime', 'critical', public.normalize_moderation_text('malware')),
  ('ransomware', 'cybercrime', 'critical', public.normalize_moderation_text('ransomware')),
  ('spyware', 'cybercrime', 'critical', public.normalize_moderation_text('spyware')),
  ('ddos attack', 'cybercrime', 'critical', public.normalize_moderation_text('ddos attack')),
  ('bypass otp', 'cybercrime', 'critical', public.normalize_moderation_text('bypass otp')),
  ('crack software', 'cybercrime', 'critical', public.normalize_moderation_text('crack software')),
  ('stolen credentials', 'cybercrime', 'critical', public.normalize_moderation_text('stolen credentials')),
  ('keylogger', 'cybercrime', 'critical', public.normalize_moderation_text('keylogger')),
  ('fake documents', 'fraud', 'high', public.normalize_moderation_text('fake documents')),
  ('fake passport', 'fraud', 'critical', public.normalize_moderation_text('fake passport')),
  ('forged passport', 'fraud', 'critical', public.normalize_moderation_text('forged passport')),
  ('fake cnic', 'fraud', 'critical', public.normalize_moderation_text('fake cnic')),
  ('fake degree', 'fraud', 'high', public.normalize_moderation_text('fake degree')),
  ('money laundering', 'fraud', 'critical', public.normalize_moderation_text('money laundering')),
  ('ponzi scheme', 'fraud', 'critical', public.normalize_moderation_text('ponzi scheme')),
  ('scam investment', 'fraud', 'high', public.normalize_moderation_text('scam investment')),
  ('crypto scam', 'fraud', 'high', public.normalize_moderation_text('crypto scam')),
  ('fake reviews', 'fraud', 'high', public.normalize_moderation_text('fake reviews')),
  ('fake followers', 'fraud', 'high', public.normalize_moderation_text('fake followers')),
  ('bot traffic', 'fraud', 'high', public.normalize_moderation_text('bot traffic')),
  ('identity theft', 'fraud', 'critical', public.normalize_moderation_text('identity theft')),
  ('escort', 'adult', 'high', public.normalize_moderation_text('escort')),
  ('prostitution', 'adult', 'critical', public.normalize_moderation_text('prostitution')),
  ('nude content', 'adult', 'high', public.normalize_moderation_text('nude content')),
  ('explicit content', 'adult', 'high', public.normalize_moderation_text('explicit content')),
  ('adult services', 'adult', 'high', public.normalize_moderation_text('adult services')),
  ('webcam sex', 'adult', 'critical', public.normalize_moderation_text('webcam sex')),
  ('sexual services', 'adult', 'critical', public.normalize_moderation_text('sexual services')),
  ('sex services', 'adult', 'critical', public.normalize_moderation_text('sex services')),
  ('s3x services', 'adult', 'critical', public.normalize_moderation_text('s3x services')),
  ('pornography', 'adult', 'high', public.normalize_moderation_text('pornography')),
  ('onlyfans management', 'adult', 'high', public.normalize_moderation_text('onlyfans management')),
  ('erotic chat', 'adult', 'high', public.normalize_moderation_text('erotic chat')),
  ('nazi propaganda', 'hate', 'critical', public.normalize_moderation_text('nazi propaganda')),
  ('terrorist support', 'hate', 'critical', public.normalize_moderation_text('terrorist support')),
  ('isis support', 'hate', 'critical', public.normalize_moderation_text('isis support')),
  ('racial hatred', 'hate', 'critical', public.normalize_moderation_text('racial hatred')),
  ('hate speech', 'hate', 'critical', public.normalize_moderation_text('hate speech')),
  ('extremist content', 'hate', 'critical', public.normalize_moderation_text('extremist content')),
  ('white supremacy', 'hate', 'critical', public.normalize_moderation_text('white supremacy')),
  ('animal abuse', 'violence', 'critical', public.normalize_moderation_text('animal abuse')),
  ('torture', 'violence', 'critical', public.normalize_moderation_text('torture')),
  ('murder service', 'violence', 'critical', public.normalize_moderation_text('murder service')),
  ('self-harm promotion', 'violence', 'critical', public.normalize_moderation_text('self-harm promotion')),
  ('suicide encouragement', 'violence', 'critical', public.normalize_moderation_text('suicide encouragement')),
  ('fake medical certificate', 'medical', 'critical', public.normalize_moderation_text('fake medical certificate')),
  ('fake prescription', 'medical', 'critical', public.normalize_moderation_text('fake prescription')),
  ('miracle cure', 'medical', 'high', public.normalize_moderation_text('miracle cure')),
  ('guaranteed cancer cure', 'medical', 'critical', public.normalize_moderation_text('guaranteed cancer cure')),
  ('illegal medicine', 'medical', 'critical', public.normalize_moderation_text('illegal medicine')),
  ('prescription drugs', 'medical', 'high', public.normalize_moderation_text('prescription drugs')),
  ('impersonation exam', 'academic', 'critical', public.normalize_moderation_text('impersonation exam')),
  ('take exam for me', 'academic', 'critical', public.normalize_moderation_text('take exam for me')),
  ('fake visa', 'fraud', 'critical', public.normalize_moderation_text('fake visa')),
  ('fake immigration papers', 'fraud', 'critical', public.normalize_moderation_text('fake immigration papers')),
  ('plagiarism service', 'academic', 'critical', public.normalize_moderation_text('plagiarism service')),
  ('sell thesis', 'academic', 'critical', public.normalize_moderation_text('sell thesis')),
  ('academic cheating', 'academic', 'critical', public.normalize_moderation_text('academic cheating')),
  ('child abuse', 'child-safety', 'critical', public.normalize_moderation_text('child abuse')),
  ('child exploitation', 'child-safety', 'critical', public.normalize_moderation_text('child exploitation')),
  ('underage content', 'child-safety', 'critical', public.normalize_moderation_text('underage content')),
  ('minor sexual content', 'child-safety', 'critical', public.normalize_moderation_text('minor sexual content'))
on conflict do nothing;

insert into public.illegal_keywords (keyword, category, severity, normalized_keyword)
values
  ('drugs', 'drugs', 'high', public.normalize_moderation_text('drugs')),
  ('weapon', 'weapons', 'high', public.normalize_moderation_text('weapon')),
  ('weapons', 'weapons', 'high', public.normalize_moderation_text('weapons')),
  ('explosive', 'weapons', 'critical', public.normalize_moderation_text('explosive')),
  ('hack', 'cybercrime', 'high', public.normalize_moderation_text('hack')),
  ('hacking', 'cybercrime', 'high', public.normalize_moderation_text('hacking')),
  ('fraud', 'fraud', 'high', public.normalize_moderation_text('fraud')),
  ('scam', 'fraud', 'high', public.normalize_moderation_text('scam')),
  ('fake identity', 'fraud', 'critical', public.normalize_moderation_text('fake identity')),
  ('fake identities', 'fraud', 'critical', public.normalize_moderation_text('fake identities')),
  ('porn', 'adult', 'high', public.normalize_moderation_text('porn')),
  ('violence', 'violence', 'high', public.normalize_moderation_text('violence')),
  ('threat', 'violence', 'high', public.normalize_moderation_text('threat')),
  ('threats', 'violence', 'high', public.normalize_moderation_text('threats')),
  ('terrorism', 'terrorism', 'critical', public.normalize_moderation_text('terrorism')),
  ('illegal marketplace', 'illegal-marketplace', 'critical', public.normalize_moderation_text('illegal marketplace')),
  ('illegal marketplaces', 'illegal-marketplace', 'critical', public.normalize_moderation_text('illegal marketplaces')),
  ('black market', 'illegal-marketplace', 'critical', public.normalize_moderation_text('black market')),
  ('piracy', 'piracy', 'high', public.normalize_moderation_text('piracy')),
  ('copyright violation', 'piracy', 'high', public.normalize_moderation_text('copyright violation')),
  ('pirated software', 'piracy', 'high', public.normalize_moderation_text('pirated software'))
on conflict do nothing;

create or replace function public.contains_illegal_keyword(p_text text)
returns boolean
language plpgsql
as $$
declare
  normalized text := public.normalize_moderation_text(p_text);
  skeleton text := public.moderation_skeleton(p_text);
  raw_lower text := lower(coalesce(p_text, ''));
begin
  return exists (
    select 1
    from public.illegal_keywords k
    where raw_lower like '%' || k.keyword || '%'
       or normalized like '%' || k.normalized_keyword || '%'
       or skeleton like '%' || public.moderation_skeleton(k.keyword) || '%'
       or similarity(normalized, k.normalized_keyword) >= 0.92
  );
end;
$$;

create or replace function public.moderation_jsonb_text_values(p_value jsonb)
returns setof text
language sql
stable
as $$
  select p_value #>> '{}'
  where jsonb_typeof(p_value) = 'string'

  union all

  select nested.value
  from jsonb_array_elements(p_value) as item(value)
  cross join lateral public.moderation_jsonb_text_values(item.value) as nested(value)
  where jsonb_typeof(p_value) = 'array'

  union all

  select nested.value
  from jsonb_each(p_value) as item(key, value)
  cross join lateral public.moderation_jsonb_text_values(item.value) as nested(value)
  where jsonb_typeof(p_value) = 'object'
    and lower(item.key) not in (
      'id',
      'user_id',
      'userid',
      'client_id',
      'clientid',
      'mentor_id',
      'mentorid',
      'sender_id',
      'senderid',
      'receiver_id',
      'receiverid',
      'conversation_id',
      'conversationid',
      'project_id',
      'projectid',
      'course_id',
      'courseid',
      'payment_id',
      'paymentid',
      'email',
      'photo_url',
      'photourl',
      'avatar',
      'sender_avatar',
      'url',
      'thumbnail_url',
      'video_url',
      'file_url',
      'fileurl',
      'created_at',
      'createdat',
      'updated_at',
      'updatedat',
      'deadline',
      'status',
      'type'
    );
$$;

create or replace function public.block_prohibited_text_fields()
returns trigger
language plpgsql
as $$
declare
  combined text;
begin
  select string_agg(value, ' ')
  into combined
  from public.moderation_jsonb_text_values(to_jsonb(new)) as text_values(value);

  if public.contains_illegal_keyword(combined) then
    raise exception 'This content violates platform safety policies.';
  end if;

  return new;
end;
$$;

create or replace function public.block_illegal_gigs()
returns trigger
language plpgsql
as $$
declare
  combined text;
begin
  combined := concat_ws(
    ' ',
    new.title,
    new.description,
    coalesce(array_to_string(new.skills, ' '), ''),
    new.category,
    new.experience_level,
    coalesce(new.packages::text, '')
  );

  if public.contains_illegal_keyword(combined) then
    raise exception 'This content violates platform safety policies.';
  end if;

  return new;
end;
$$;

drop trigger if exists trg_block_illegal_gigs on public.mentor_gigs;
create trigger trg_block_illegal_gigs
before insert or update on public.mentor_gigs
for each row execute procedure public.block_illegal_gigs();

do $$
declare
  table_name text;
  guarded_tables text[] := array[
    'users',
    'projects',
    'mentor_gigs',
    'courses',
    'messages',
    'conversations',
    'project_applications',
    'reviews',
    'disputes',
    'notifications'
  ];
begin
  foreach table_name in array guarded_tables loop
    if to_regclass('public.' || table_name) is not null then
      execute format(
        'drop trigger if exists trg_block_prohibited_text_fields on public.%I',
        table_name
      );
      execute format(
        'create trigger trg_block_prohibited_text_fields before insert or update on public.%I for each row execute procedure public.block_prohibited_text_fields()',
        table_name
      );
    end if;
  end loop;
end $$;
