-- =====================================================================
--  Dino Runner · base de datos en Supabase
--  Pegar entero en Supabase → SQL Editor → New query → Run.
--  Crea: perfiles (apodo), puntuaciones (ranking) y guardado en la nube.
--  Cada jugador solo puede escribir lo suyo (Row Level Security).
-- =====================================================================

-- Perfiles: un apodo por jugador (el id es el del inicio de sesión anónimo)
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nickname text not null check (char_length(nickname) between 3 and 16 and nickname ~ '^[A-Za-z0-9ÁÉÍÓÚÜÑáéíóúüñ _.-]+$'),
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
drop policy if exists "perfiles visibles" on public.profiles;
create policy "perfiles visibles" on public.profiles for select using (true);
drop policy if exists "crear mi perfil" on public.profiles;
create policy "crear mi perfil" on public.profiles for insert with check (auth.uid() = id);
drop policy if exists "cambiar mi perfil" on public.profiles;
create policy "cambiar mi perfil" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

-- Puntuaciones: la mejor de cada jugador por modo y día (mode = daily | normal | easy | hard | random)
create table if not exists public.scores (
  user_id uuid not null references auth.users (id) on delete cascade,
  mode text not null check (mode in ('daily', 'normal', 'easy', 'hard', 'random')),
  day date not null,
  score integer not null check (score between 0 and 5000000),
  level integer not null default 1 check (level between 1 and 99),
  seconds real not null default 0,
  updated_at timestamptz not null default now(),
  primary key (user_id, mode, day)
);
alter table public.scores enable row level security;
drop policy if exists "puntuaciones visibles" on public.scores;
create policy "puntuaciones visibles" on public.scores for select using (true);
-- No hay políticas de escritura directa: solo se escribe con la función submit_score (que comprueba los datos)

-- Enviar una puntuación: valida que sea posible, limita la frecuencia y guarda solo si mejora
create or replace function public.submit_score(p_mode text, p_day date, p_score integer, p_level integer, p_seconds real)
returns integer language plpgsql security definer set search_path = public as $$
declare uid uuid := auth.uid(); best integer; last timestamptz;
begin
  if uid is null then raise exception 'sin sesión'; end if;
  if p_mode not in ('daily', 'normal', 'easy', 'hard', 'random') then raise exception 'modo no válido'; end if;
  if p_day < current_date - 1 or p_day > current_date + 1 then raise exception 'día no válido'; end if;
  if p_seconds < 1 or p_score < 0 or p_score > p_seconds * 150 + 3000 then raise exception 'puntuación imposible'; end if;
  select max(updated_at) into last from scores where user_id = uid;
  if last is not null and last > now() - interval '15 seconds' then raise exception 'demasiado rápido'; end if;
  insert into scores (user_id, mode, day, score, level, seconds) values (uid, p_mode, p_day, p_score, p_level, p_seconds)
  on conflict (user_id, mode, day) do update set
    score = greatest(scores.score, excluded.score),
    level = case when excluded.score > scores.score then excluded.level else scores.level end,
    seconds = case when excluded.score > scores.score then excluded.seconds else scores.seconds end,
    updated_at = now()
  returning score into best;
  return best;
end $$;
grant execute on function public.submit_score(text, date, integer, integer, real) to authenticated;

-- Ranking: top N de un modo y un día (para la diaria) o de toda la historia (p_day = null)
create or replace function public.leaderboard(p_mode text, p_day date, p_limit integer default 100)
returns table (rank bigint, nickname text, score integer, level integer, is_me boolean)
language sql stable security definer set search_path = public as $$
  with best as (
    select s.user_id, max(s.score) as score, max(s.level) as level
    from scores s where s.mode = p_mode and (p_day is null or s.day = p_day) group by s.user_id
  )
  select rank() over (order by b.score desc), coalesce(p.nickname, 'Raptor anónimo'), b.score, b.level, b.user_id = auth.uid()
  from best b left join profiles p on p.id = b.user_id
  order by b.score desc limit least(greatest(p_limit, 1), 200);
$$;
grant execute on function public.leaderboard(text, date, integer) to anon, authenticated;

-- Mi puesto (aunque no esté en el top)
create or replace function public.my_rank(p_mode text, p_day date)
returns table (rank bigint, score integer, total bigint)
language sql stable security definer set search_path = public as $$
  with best as (
    select s.user_id, max(s.score) as score from scores s
    where s.mode = p_mode and (p_day is null or s.day = p_day) group by s.user_id
  ), mine as (select score from best where user_id = auth.uid())
  select (select count(*) + 1 from best where score > (select score from mine)), (select score from mine), (select count(*) from best)
  where exists (select 1 from mine);
$$;
grant execute on function public.my_rank(text, date) to authenticated;

-- Guardado en la nube: una copia del progreso por jugador
create table if not exists public.saves (
  user_id uuid primary key references auth.users (id) on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  check (pg_column_size(data) < 400000)
);
alter table public.saves enable row level security;
drop policy if exists "leer mi guardado" on public.saves;
create policy "leer mi guardado" on public.saves for select using (auth.uid() = user_id);
drop policy if exists "crear mi guardado" on public.saves;
create policy "crear mi guardado" on public.saves for insert with check (auth.uid() = user_id);
drop policy if exists "cambiar mi guardado" on public.saves;
create policy "cambiar mi guardado" on public.saves for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
