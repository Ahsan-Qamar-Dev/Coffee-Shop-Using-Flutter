begin;
-- Membership is managed only by the project owner, never by a client app.
create table public.store_staff (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'staff' check (role in ('staff','owner')),
  created_at timestamptz not null default now()
);
alter table public.store_staff enable row level security;
revoke all on public.store_staff from public, anon, authenticated;

create function public.is_store_staff() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists(select 1 from public.store_staff where user_id = auth.uid());
$$;

create function public.staff_orders() returns setof jsonb
language plpgsql security definer set search_path = '' as $$
begin
  if not public.is_store_staff() then raise exception 'Staff access required.'; end if;
  return query select to_jsonb(o) - 'user_id' - 'request_id'
    from public.orders o order by o.created_at desc limit 200;
end; $$;

create function public.staff_set_order_status(p_order_id uuid, p_status text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare o public.orders;
begin
  if not public.is_store_staff() then raise exception 'Staff access required.'; end if;
  select * into o from public.orders where id = p_order_id for update;
  if not found then raise exception 'Order unavailable.'; end if;
  if p_status is null or not (
    p_status = o.status or
    (o.status = 'confirmed' and p_status in ('preparing','cancelled')) or
    (o.status = 'preparing' and p_status in ('ready','cancelled')) or
    (o.status = 'ready' and p_status in ('completed','cancelled'))
  ) then raise exception 'Invalid order status change. Refresh the order.'; end if;
  update public.orders set status = p_status where id = p_order_id returning * into o;
  return to_jsonb(o) - 'user_id' - 'request_id';
end; $$;

revoke all on function public.is_store_staff() from public, anon;
revoke all on function public.staff_orders() from public, anon;
revoke all on function public.staff_set_order_status(uuid,text) from public, anon;
grant execute on function public.is_store_staff() to authenticated;
grant execute on function public.staff_orders() to authenticated;
grant execute on function public.staff_set_order_status(uuid,text) to authenticated;
commit;
