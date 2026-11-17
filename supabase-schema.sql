-- MEU PAINEL — Supabase schema
-- Execute uma vez no SQL Editor do projeto.
create extension if not exists pgcrypto;

create table if not exists public.workouts (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 performed_on date not null default current_date,
 muscle_group text not null,
 exercise text not null,
 sets integer not null check (sets > 0),
 reps integer not null check (reps > 0),
 load_kg numeric(8,2) not null default 0 check (load_kg >= 0),
 note text,
 created_at timestamptz not null default now()
);
create table if not exists public.meals (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 eaten_on date not null default current_date,
 meal_type text not null,
 description text not null,
 calories numeric(8,2) not null default 0 check (calories >= 0),
 protein_g numeric(8,2) not null default 0 check (protein_g >= 0),
 carbs_g numeric(8,2) not null default 0 check (carbs_g >= 0),
 fat_g numeric(8,2) not null default 0 check (fat_g >= 0),
 body_weight_kg numeric(7,2) check (body_weight_kg is null or body_weight_kg > 0),
 created_at timestamptz not null default now()
);
create table if not exists public.finance_entries (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 entry_date date not null default current_date,
 entry_type text not null check (entry_type in ('income','expense')),
 category text not null,
 description text,
 payment_method text,
 amount numeric(12,2) not null check (amount > 0),
 created_at timestamptz not null default now()
);
create table if not exists public.tasks (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 title text not null,
 due_date date,
 priority text not null default 'Normal' check (priority in ('Baixa','Normal','Alta','Urgente')),
 is_done boolean not null default false,
 created_at timestamptz not null default now()
);

create index if not exists workouts_user_date_idx on public.workouts(user_id, performed_on);
create index if not exists workouts_user_exercise_idx on public.workouts(user_id, exercise, performed_on);
create index if not exists meals_user_date_idx on public.meals(user_id, eaten_on);
create index if not exists finance_user_date_idx on public.finance_entries(user_id, entry_date);
create index if not exists finance_user_category_idx on public.finance_entries(user_id, category, entry_date);
create index if not exists tasks_user_due_idx on public.tasks(user_id, due_date);

alter table public.workouts enable row level security;
alter table public.meals enable row level security;
alter table public.finance_entries enable row level security;
alter table public.tasks enable row level security;

drop policy if exists workouts_select_own on public.workouts;
drop policy if exists workouts_insert_own on public.workouts;
drop policy if exists workouts_update_own on public.workouts;
drop policy if exists workouts_delete_own on public.workouts;
create policy workouts_select_own on public.workouts for select to authenticated using (auth.uid() = user_id);
create policy workouts_insert_own on public.workouts for insert to authenticated with check (auth.uid() = user_id);
create policy workouts_update_own on public.workouts for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy workouts_delete_own on public.workouts for delete to authenticated using (auth.uid() = user_id);

drop policy if exists meals_select_own on public.meals;
drop policy if exists meals_insert_own on public.meals;
drop policy if exists meals_update_own on public.meals;
drop policy if exists meals_delete_own on public.meals;
create policy meals_select_own on public.meals for select to authenticated using (auth.uid() = user_id);
create policy meals_insert_own on public.meals for insert to authenticated with check (auth.uid() = user_id);
create policy meals_update_own on public.meals for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy meals_delete_own on public.meals for delete to authenticated using (auth.uid() = user_id);

drop policy if exists finance_select_own on public.finance_entries;
drop policy if exists finance_insert_own on public.finance_entries;
drop policy if exists finance_update_own on public.finance_entries;
drop policy if exists finance_delete_own on public.finance_entries;
create policy finance_select_own on public.finance_entries for select to authenticated using (auth.uid() = user_id);
create policy finance_insert_own on public.finance_entries for insert to authenticated with check (auth.uid() = user_id);
create policy finance_update_own on public.finance_entries for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy finance_delete_own on public.finance_entries for delete to authenticated using (auth.uid() = user_id);

drop policy if exists tasks_select_own on public.tasks;
drop policy if exists tasks_insert_own on public.tasks;
drop policy if exists tasks_update_own on public.tasks;
drop policy if exists tasks_delete_own on public.tasks;
create policy tasks_select_own on public.tasks for select to authenticated using (auth.uid() = user_id);
create policy tasks_insert_own on public.tasks for insert to authenticated with check (auth.uid() = user_id);
create policy tasks_update_own on public.tasks for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy tasks_delete_own on public.tasks for delete to authenticated using (auth.uid() = user_id);

grant select, insert, update, delete on public.workouts, public.meals, public.finance_entries, public.tasks to authenticated;
