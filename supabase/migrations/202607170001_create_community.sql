create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null check (char_length(nickname) between 2 and 20),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.community_posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  image_path text not null unique,
  image_url text not null,
  caption text not null default '' check (char_length(caption) <= 1000),
  preset_id text,
  preset_intensity double precision check (
    preset_intensity is null or preset_intensity between 0 and 1
  ),
  composition_id text,
  status text not null default 'published' check (
    status in ('published', 'hidden', 'removed')
  ),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.post_likes (
  post_id uuid not null references public.community_posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create table if not exists public.post_saves (
  post_id uuid not null references public.community_posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create table if not exists public.post_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.community_posts(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 500),
  status text not null default 'published' check (
    status in ('published', 'hidden', 'removed')
  ),
  created_at timestamptz not null default now()
);

create table if not exists public.post_reports (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.community_posts(id) on delete cascade,
  reporter_id uuid not null references auth.users(id) on delete cascade,
  reason text not null check (char_length(reason) between 1 and 300),
  status text not null default 'open' check (
    status in ('open', 'reviewing', 'resolved', 'dismissed')
  ),
  created_at timestamptz not null default now(),
  unique (post_id, reporter_id)
);

create table if not exists public.user_blocks (
  blocker_id uuid not null references auth.users(id) on delete cascade,
  blocked_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

create index if not exists community_posts_created_at_idx
  on public.community_posts(created_at desc)
  where status = 'published';
create index if not exists post_comments_post_created_idx
  on public.post_comments(post_id, created_at)
  where status = 'published';

alter table public.profiles enable row level security;
alter table public.community_posts enable row level security;
alter table public.post_likes enable row level security;
alter table public.post_saves enable row level security;
alter table public.post_comments enable row level security;
alter table public.post_reports enable row level security;
alter table public.user_blocks enable row level security;

create policy "authenticated profiles are readable"
  on public.profiles for select to authenticated using (true);
create policy "users create their profile"
  on public.profiles for insert to authenticated
  with check ((select auth.uid()) = id);
create policy "users update their profile"
  on public.profiles for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create policy "published posts are readable"
  on public.community_posts for select to authenticated
  using (status = 'published');
create policy "users create their posts"
  on public.community_posts for insert to authenticated
  with check ((select auth.uid()) = author_id and status = 'published');
create policy "users update their posts"
  on public.community_posts for update to authenticated
  using ((select auth.uid()) = author_id)
  with check ((select auth.uid()) = author_id);
create policy "users delete their posts"
  on public.community_posts for delete to authenticated
  using ((select auth.uid()) = author_id);

create policy "users read their like state"
  on public.post_likes for select to authenticated
  using ((select auth.uid()) = user_id);
create policy "users create their likes"
  on public.post_likes for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy "users delete their likes"
  on public.post_likes for delete to authenticated
  using ((select auth.uid()) = user_id);

create policy "users read their saved posts"
  on public.post_saves for select to authenticated
  using ((select auth.uid()) = user_id);
create policy "users save posts"
  on public.post_saves for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy "users remove their saved posts"
  on public.post_saves for delete to authenticated
  using ((select auth.uid()) = user_id);

create policy "published comments are readable"
  on public.post_comments for select to authenticated
  using (status = 'published');
create policy "users create their comments"
  on public.post_comments for insert to authenticated
  with check ((select auth.uid()) = author_id and status = 'published');
create policy "users delete their comments"
  on public.post_comments for delete to authenticated
  using ((select auth.uid()) = author_id);

create policy "users report as themselves"
  on public.post_reports for insert to authenticated
  with check ((select auth.uid()) = reporter_id);
create policy "users update their own open report"
  on public.post_reports for update to authenticated
  using ((select auth.uid()) = reporter_id and status = 'open')
  with check ((select auth.uid()) = reporter_id and status = 'open');

create policy "users read their blocks"
  on public.user_blocks for select to authenticated
  using ((select auth.uid()) = blocker_id);
create policy "users create their blocks"
  on public.user_blocks for insert to authenticated
  with check ((select auth.uid()) = blocker_id);
create policy "users remove their blocks"
  on public.user_blocks for delete to authenticated
  using ((select auth.uid()) = blocker_id);

create or replace function public.enforce_community_post_rate_limit()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if (
    select count(*) >= 5
    from public.community_posts
    where author_id = new.author_id
      and created_at > now() - interval '1 hour'
  ) then
    raise exception 'hourly community post limit exceeded';
  end if;
  return new;
end;
$$;

drop trigger if exists community_post_rate_limit on public.community_posts;
create trigger community_post_rate_limit
before insert on public.community_posts
for each row execute function public.enforce_community_post_rate_limit();

create or replace function public.get_community_feed(
  feed_sort text default 'recommended',
  page_limit integer default 30,
  page_offset integer default 0
)
returns table (
  id uuid,
  author_id uuid,
  author_nickname text,
  image_url text,
  caption text,
  preset_id text,
  preset_intensity double precision,
  composition_id text,
  like_count bigint,
  save_count bigint,
  comment_count bigint,
  liked_by_me boolean,
  saved_by_me boolean,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    p.id,
    p.author_id,
    pr.nickname,
    p.image_url,
    p.caption,
    p.preset_id,
    p.preset_intensity,
    p.composition_id,
    (select count(*) from public.post_likes l where l.post_id = p.id),
    (select count(*) from public.post_saves s where s.post_id = p.id),
    (select count(*) from public.post_comments c where c.post_id = p.id and c.status = 'published'),
    exists(select 1 from public.post_likes l where l.post_id = p.id and l.user_id = auth.uid()),
    exists(select 1 from public.post_saves s where s.post_id = p.id and s.user_id = auth.uid()),
    p.created_at
  from public.community_posts p
  join public.profiles pr on pr.id = p.author_id
  where p.status = 'published'
    and not exists (
      select 1 from public.user_blocks b
      where (b.blocker_id = auth.uid() and b.blocked_id = p.author_id)
         or (b.blocker_id = p.author_id and b.blocked_id = auth.uid())
    )
  order by
    case when feed_sort = 'newest' then extract(epoch from p.created_at) end desc,
    case when feed_sort <> 'newest' then
      (select count(*) * 3 from public.post_likes l where l.post_id = p.id)
      + (select count(*) * 2 from public.post_saves s where s.post_id = p.id)
      + (select count(*) from public.post_comments c where c.post_id = p.id)
      - extract(epoch from (now() - p.created_at)) / 86400
    end desc,
    p.created_at desc
  limit least(greatest(page_limit, 1), 50)
  offset greatest(page_offset, 0);
$$;

create or replace function public.get_post_comments(target_post_id uuid)
returns table (
  id uuid,
  author_nickname text,
  body text,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select c.id, p.nickname, c.body, c.created_at
  from public.post_comments c
  join public.profiles p on p.id = c.author_id
  where c.post_id = target_post_id and c.status = 'published'
  order by c.created_at asc
  limit 200;
$$;

revoke all on function public.get_community_feed(text, integer, integer) from public;
revoke all on function public.get_post_comments(uuid) from public;
grant execute on function public.get_community_feed(text, integer, integer) to authenticated;
grant execute on function public.get_post_comments(uuid) to authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'community-photos',
  'community-photos',
  true,
  8388608,
  array['image/jpeg']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "authenticated users upload community photos"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'community-photos'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
  );
create policy "upload owners can read object metadata"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'community-photos'
    and owner_id = (select auth.uid()::text)
  );
create policy "upload owners delete community photos"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'community-photos'
    and owner_id = (select auth.uid()::text)
  );
