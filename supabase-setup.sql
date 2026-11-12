-- ============================================================
--  Eve Metor - database setup
--  Run this ONCE in Supabase: SQL Editor -> New query -> Run
-- ============================================================

-- 1. Events (one row per registered event)
create table if not exists events (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  type text not null check (type in ('solo', 'group')),
  owner text not null,
  created_at timestamptz not null default now()
);

-- 2. Participants (one row per person in an event)
create table if not exists participants (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events(id) on delete cascade,
  name text not null,
  position int not null,
  created_at timestamptz not null default now()
);

-- 3. Attendance (one status per participant)
create table if not exists attendance (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events(id) on delete cascade,
  participant_id uuid not null unique references participants(id) on delete cascade,
  status text not null check (status in ('present', 'absent', 'disqualified')),
  recorded_at timestamptz not null default now()
);

-- 4. Row Level Security: lets the public (anon) key read and write.
--    This suits a demo. For real use, add Supabase Auth and restrict these.
alter table events enable row level security;
alter table participants enable row level security;
alter table attendance enable row level security;

create policy "anon read events"        on events       for select to anon using (true);
create policy "anon insert events"      on events       for insert to anon with check (true);

create policy "anon read participants"  on participants for select to anon using (true);
create policy "anon insert participants" on participants for insert to anon with check (true);

create policy "anon read attendance"    on attendance   for select to anon using (true);
create policy "anon insert attendance"  on attendance   for insert to anon with check (true);
create policy "anon update attendance"  on attendance   for update to anon using (true) with check (true);
