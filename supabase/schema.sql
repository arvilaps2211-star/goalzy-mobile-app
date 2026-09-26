-- GOALZY — reference schema for Supabase Auth + a `profiles` table
-- matching lib/shared/domain/entities/user_profile.dart exactly.
--
-- This is a REFERENCE file only. Nothing in this project runs it
-- automatically — review it and run it yourself in the Supabase SQL
-- editor (Dashboard → SQL Editor → New query) for your own project.
-- Per the working rules for this stage: no migrations are applied
-- automatically, no schema is touched without you reviewing it first.
--
-- Only covers Auth + the user profile, matching what's actually wired up
-- in Stage 3 (see BACKEND_SETUP.md). Tasks/Habits/Goals/Calendar/
-- Analytics/Notifications/Focus still run on their own in-memory mock
-- data — none of those have real tables yet; that's future work, one
-- feature at a time, each genuinely tested against a real project rather
-- than guessed at here.

-- 1. Profile table — one row per authenticated user, mirroring UserProfile.
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  display_name text not null default '',
  avatar_url text,
  level integer not null default 1,
  xp integer not null default 0,
  credits integer not null default 100,
  streak_days integer not null default 0,
  is_premium boolean not null default false,
  created_at timestamptz not null default now()
);

-- 2. Row Level Security — required. The Flutter app only ever holds the
-- anon/publishable key (never a secret key — see backend_config.dart),
-- so RLS is what actually enforces "a user can only read/write their own
-- profile," not anything in the client.
alter table public.profiles enable row level security;

create policy "Users can view their own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

create policy "Users can insert their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

-- 3. Auto-create a profile row whenever a new auth user signs up, so the
-- app never has to do that step itself client-side (and so the insert
-- policy above is only ever exercised by this trusted, server-side path).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name)
  values (new.id, new.email, coalesce(new.raw_user_meta_data ->> 'display_name', ''));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
