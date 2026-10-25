-- Race Hub: sosyal medya / Discord linkleri tablosu
-- ÖNCE Crescent'in schema.sql dosyasını çalıştır (admin_users tablosu orada). Tekrar çalıştırılabilir.
create extension if not exists pgcrypto;

create table if not exists public.site_links (
  id uuid primary key default gen_random_uuid(),
  kind text not null default 'other'
    check (kind in ('instagram','tiktok','youtube','steam','twitch','x','discord','other')),
  name text not null check (char_length(name) between 1 and 60),
  url text not null check (url ~* '^https?://'),
  sort integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.site_links enable row level security;
grant select on public.site_links to anon, authenticated;
grant insert, update, delete on public.site_links to authenticated;

drop policy if exists "Anyone can read site links" on public.site_links;
drop policy if exists "Admins manage site links"   on public.site_links;

create policy "Anyone can read site links" on public.site_links
  for select to anon, authenticated using (true);
create policy "Admins manage site links" on public.site_links
  for all to authenticated
  using (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())))
  with check (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));
