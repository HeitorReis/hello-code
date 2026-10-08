-- Hello Code 2026 - schema simples para rodar no SQL Editor do Supabase.
-- Depois de executar este arquivo, preencha url e anonKey nos dois HTMLs.
-- Nao use a service_role key no navegador.

create extension if not exists pgcrypto;

create or replace function public.hello_code_normalize_juror_name(p_name text)
returns text
language sql
immutable
as $$
  select lower(regexp_replace(btrim(coalesce(p_name, '')), '\s+', ' ', 'g'));
$$;

create or replace function public.hello_code_scores_valid(p_scores integer[])
returns boolean
language sql
immutable
as $$
  select coalesce(array_length(p_scores, 1), 0) = 7
    and coalesce(p_scores[1] between 0 and 15, false)
    and coalesce(p_scores[2] between 0 and 15, false)
    and coalesce(p_scores[3] between 0 and 20, false)
    and coalesce(p_scores[4] between 0 and 15, false)
    and coalesce(p_scores[5] between 0 and 10, false)
    and coalesce(p_scores[6] between 0 and 15, false)
    and coalesce(p_scores[7] between 0 and 10, false);
$$;

create table if not exists public.hello_code_evaluations (
  id uuid primary key default gen_random_uuid(),
  evaluator_id text not null,
  juror_name text not null,
  team_id text not null,
  mode text not null check (mode in ('test', 'official')),
  scores integer[] not null check (public.hello_code_scores_valid(scores)),
  comments text[] not null default array['', '', '', '', '', '', '']::text[] check (coalesce(array_length(comments, 1), 0) = 7),
  total integer generated always as (scores[1] + scores[2] + scores[3] + scores[4] + scores[5] + scores[6] + scores[7]) stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (evaluator_id, team_id, mode)
);

alter table public.hello_code_evaluations enable row level security;

drop policy if exists "hello_code_public_read" on public.hello_code_evaluations;
drop policy if exists "hello_code_public_insert" on public.hello_code_evaluations;
drop policy if exists "hello_code_public_update" on public.hello_code_evaluations;
drop policy if exists "hello_code_public_delete_test" on public.hello_code_evaluations;

-- Politicas propositalmente simples para uso direto por HTML no evento.
create policy "hello_code_public_read"
on public.hello_code_evaluations
for select
to anon
using (true);

create policy "hello_code_public_insert"
on public.hello_code_evaluations
for insert
to anon
with check (true);

create policy "hello_code_public_update"
on public.hello_code_evaluations
for update
to anon
using (true)
with check (true);

create policy "hello_code_public_delete_test"
on public.hello_code_evaluations
for delete
to anon
using (mode = 'test');

create or replace function public.hello_code_evaluation_json(p_row public.hello_code_evaluations)
returns jsonb
language sql
stable
as $$
  select jsonb_build_object(
    'evaluatorId', p_row.evaluator_id,
    'jurorName', p_row.juror_name,
    'teamId', p_row.team_id,
    'mode', p_row.mode,
    'scores', p_row.scores,
    'comments', p_row.comments,
    'total', p_row.total,
    'createdAt', to_jsonb(p_row.created_at),
    'updatedAt', to_jsonb(p_row.updated_at)
  );
$$;

create or replace function public.hello_code_save_evaluation(
  p_juror_name text,
  p_team_id text,
  p_mode text,
  p_scores integer[],
  p_comments text[] default array[]::text[]
)
returns jsonb
language plpgsql
as $$
declare
  v_name text := btrim(coalesce(p_juror_name, ''));
  v_evaluator_id text;
  v_team_id text := btrim(coalesce(p_team_id, ''));
  v_mode text := case when p_mode = 'test' or p_team_id = 'test-team' then 'test' else 'official' end;
  v_comments text[] := coalesce(p_comments, array[]::text[]);
  v_record public.hello_code_evaluations;
  v_edited boolean;
  i integer;
begin
  if v_name = '' then
    raise exception 'Informe o nome da jurada.';
  end if;

  if v_mode = 'official' and v_team_id not in ('1','2','3','4','5','6','7','8','9') then
    raise exception 'Equipe oficial invalida.';
  end if;

  if v_mode = 'test' and v_team_id not in ('test-team','1','2','3','4','5','6','7','8','9') then
    raise exception 'Equipe de teste invalida.';
  end if;

  if not coalesce(public.hello_code_scores_valid(p_scores), false) then
    raise exception 'As notas precisam seguir os sete criterios e seus limites.';
  end if;

  for i in 1..7 loop
    v_comments[i] := left(coalesce(v_comments[i], ''), 2000);
  end loop;
  v_comments := array[
    v_comments[1], v_comments[2], v_comments[3], v_comments[4],
    v_comments[5], v_comments[6], v_comments[7]
  ];

  v_evaluator_id := public.hello_code_normalize_juror_name(v_name);

  select exists (
    select 1
    from public.hello_code_evaluations
    where evaluator_id = v_evaluator_id
      and team_id = v_team_id
      and mode = v_mode
  ) into v_edited;

  insert into public.hello_code_evaluations (
    evaluator_id, juror_name, team_id, mode, scores, comments
  )
  values (
    v_evaluator_id, v_name, v_team_id, v_mode, p_scores, v_comments
  )
  on conflict (evaluator_id, team_id, mode)
  do update set
    juror_name = excluded.juror_name,
    scores = excluded.scores,
    comments = excluded.comments,
    updated_at = now()
  returning * into v_record;

  return jsonb_build_object(
    'ok', true,
    'edited', v_edited,
    'record', public.hello_code_evaluation_json(v_record)
  );
end;
$$;

create or replace function public.hello_code_list_evaluations(
  p_juror_name text default '',
  p_evaluator_id text default '',
  p_mode text default 'official'
)
returns jsonb
language plpgsql
stable
as $$
declare
  v_mode text := case when p_mode = 'test' then 'test' else 'official' end;
  v_evaluator_id text := public.hello_code_normalize_juror_name(p_juror_name);
  v_items jsonb;
begin
  if v_evaluator_id = '' then
    v_evaluator_id := btrim(coalesce(p_evaluator_id, ''));
  end if;

  select coalesce(jsonb_agg(public.hello_code_evaluation_json(e) order by e.updated_at desc), '[]'::jsonb)
  into v_items
  from public.hello_code_evaluations e
  where e.mode = v_mode
    and v_evaluator_id <> ''
    and e.evaluator_id = v_evaluator_id;

  return jsonb_build_object('items', v_items);
end;
$$;

create or replace function public.hello_code_admin(p_mode text default 'test')
returns jsonb
language plpgsql
stable
as $$
declare
  v_mode text := case when p_mode = 'official' then 'official' else 'test' end;
  v_payload jsonb;
begin
  with teams(team_id, team_name) as (
    values
      ('1','EEEI Professor Nelson do Nascimento Monteiro'),
      ('2','EE Professor Dorival Monteiro de Oliveira - Equipe 1'),
      ('3','EE Professora Ilza Irma Moeller Cóppio - Equipe 1'),
      ('4','EEEMI Professor Joaquim de Moura Candelária'),
      ('5','EE Professor Dorival Monteiro de Oliveira - Equipe 2'),
      ('6','EE Professora Elídia Tedesco de Oliveira'),
      ('7','EE Professora Ilza Irma Moeller Cóppio - Equipe 2'),
      ('8','EEEI Professora Ana Cândida de Barros Molina'),
      ('9','EE Professor Dorival Monteiro de Oliveira - Equipe 3')
  ),
  rows as (
    select e.*
    from public.hello_code_evaluations e
    where e.mode = v_mode
      and e.team_id in ('1','2','3','4','5','6','7','8','9')
  ),
  stats as (
    select
      t.team_id,
      t.team_name,
      count(r.id)::integer as count,
      coalesce(sum(r.total), 0)::integer as total,
      array[
        coalesce(sum(r.scores[1]), 0)::integer,
        coalesce(sum(r.scores[2]), 0)::integer,
        coalesce(sum(r.scores[3]), 0)::integer,
        coalesce(sum(r.scores[4]), 0)::integer,
        coalesce(sum(r.scores[5]), 0)::integer,
        coalesce(sum(r.scores[6]), 0)::integer,
        coalesce(sum(r.scores[7]), 0)::integer
      ] as criterion_sums,
      coalesce(
        jsonb_agg(jsonb_build_object(
          'evaluatorId', r.evaluator_id,
          'jurorName', r.juror_name,
          'teamId', r.team_id,
          'mode', r.mode,
          'scores', r.scores,
          'comments', r.comments,
          'total', r.total,
          'createdAt', to_jsonb(r.created_at),
          'updatedAt', to_jsonb(r.updated_at)
        ) order by r.juror_name)
          filter (where r.id is not null),
        '[]'::jsonb
      ) as jurors
    from teams t
    left join rows r on r.team_id = t.team_id
    group by t.team_id, t.team_name
  ),
  ranked as (
    select
      row_number() over (order by total desc, count desc, team_name asc)::integer as rank,
      *
    from stats
  )
  select jsonb_build_object(
    'mode', v_mode,
    'teams', coalesce(jsonb_agg(jsonb_build_object(
      'teamId', team_id,
      'teamName', team_name,
      'jurors', jurors,
      'criterionSums', criterion_sums,
      'total', total,
      'count', count,
      'rank', rank
    ) order by rank), '[]'::jsonb),
    'grandTotal', (select coalesce(sum(total), 0)::integer from rows),
    'evaluations', (select count(*)::integer from rows),
    'uniqueJurors', (select count(distinct evaluator_id)::integer from rows)
  )
  into v_payload
  from ranked;

  return v_payload;
end;
$$;

create or replace function public.hello_code_seed_test(
  p_juror_count integer default 3,
  p_profile text default 'balanced'
)
returns jsonb
language plpgsql
as $$
declare
  v_juror_count integer := greatest(1, least(10, coalesce(p_juror_count, 3)));
  v_profile text := coalesce(p_profile, 'balanced');
  v_floor numeric;
  v_max integer[] := array[15,15,20,15,10,15,10];
  v_scores integer[];
  v_rows integer := 0;
  team integer;
  juror integer;
  i integer;
begin
  v_floor := case v_profile when 'wide' then 0.35 when 'high' then 0.72 else 0.55 end;

  delete from public.hello_code_evaluations
  where mode = 'test'
    and evaluator_id like 'jurada simulada %';

  for team in 1..9 loop
    for juror in 1..v_juror_count loop
      v_scores := array[]::integer[];
      for i in 1..7 loop
        v_scores := array_append(v_scores, greatest(0, least(v_max[i], round(v_max[i] * (v_floor + random() * (1 - v_floor)))::integer)));
      end loop;

      perform public.hello_code_save_evaluation(
        'Jurada Simulada ' || juror,
        team::text,
        'test',
        v_scores,
        array_fill('Simulacao automatica'::text, array[7])
      );
      v_rows := v_rows + 1;
    end loop;
  end loop;

  return jsonb_build_object(
    'ok', true,
    'message', 'Nova simulacao criada: ' || v_rows || ' avaliacoes (' || v_juror_count || ' juradas x 9 equipes).'
  );
end;
$$;

create or replace function public.hello_code_reset_test()
returns jsonb
language plpgsql
as $$
declare
  v_count integer;
begin
  delete from public.hello_code_evaluations
  where mode = 'test';

  get diagnostics v_count = row_count;

  return jsonb_build_object(
    'ok', true,
    'message', v_count || ' avaliacoes de teste apagadas.'
  );
end;
$$;

grant usage on schema public to anon;
grant select, insert, update, delete on table public.hello_code_evaluations to anon;
grant execute on function public.hello_code_save_evaluation(text, text, text, integer[], text[]) to anon;
grant execute on function public.hello_code_list_evaluations(text, text, text) to anon;
grant execute on function public.hello_code_admin(text) to anon;
grant execute on function public.hello_code_seed_test(integer, text) to anon;
grant execute on function public.hello_code_reset_test() to anon;
