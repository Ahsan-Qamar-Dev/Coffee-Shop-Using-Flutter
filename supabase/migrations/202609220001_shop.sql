-- Apply to a new Supabase project. All prices are integer USD cents.
begin;
create table public.coffees (
  id text primary key,
  name text not null,
  subtitle text not null,
  description text not null,
  price_cents integer not null check (price_cents between 1 and 100000),
  rating numeric(2,1) not null check (rating between 0 and 5),
  image_path text not null,
  category text not null,
  contains_milk boolean not null,
  is_iced boolean not null default false,
  available boolean not null default true,
  sort_order integer not null default 0
);
create table public.customer_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint state_size check (octet_length(state::text) <= 65536),
  constraint state_object check (jsonb_typeof(state) = 'object')
);
create table public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  request_id uuid not null,
  created_at timestamptz not null default now(),
  status text not null default 'confirmed'
    check (status in ('confirmed','preparing','ready','completed','cancelled')),
  payload jsonb not null,
  unique(user_id, request_id)
);
create index orders_customer_date on public.orders(user_id, created_at desc);

alter table public.coffees enable row level security;
alter table public.customer_state enable row level security;
alter table public.orders enable row level security;
revoke all on public.coffees, public.customer_state, public.orders from anon, authenticated;
grant select on public.coffees to authenticated;
grant select, insert, update on public.customer_state to authenticated;
grant select on public.orders to authenticated;
create policy catalog_read on public.coffees for select to authenticated using (available);
create policy state_read on public.customer_state for select to authenticated using (user_id = (select auth.uid()));
create policy state_insert on public.customer_state for insert to authenticated with check (user_id = (select auth.uid()));
create policy state_update on public.customer_state for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy orders_read on public.orders for select to authenticated using (user_id = (select auth.uid()));

-- The server owns timestamps; device clocks must not affect sync metadata.
create function public.touch_customer_state()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end; $$;
create trigger customer_state_timestamp before insert or update on public.customer_state
  for each row execute function public.touch_customer_state();
revoke all on function public.touch_customer_state() from public, anon, authenticated;

create function public.place_order(p_request_id uuid, p_lines jsonb,
  p_delivery boolean, p_customer_name text, p_address jsonb, p_note text,
  p_expected_total integer)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
  row_order public.orders;
  item jsonb;
  product public.coffees;
  snapshot jsonb := '[]'::jsonb;
  subtotal integer := 0;
  unit_price integer;
  qty integer;
  cup_size text;
  fee integer;
begin
  if uid is null then raise exception 'Please sign in again.'; end if;
  if p_request_id is null then raise exception 'Missing request ID.'; end if;
  -- Serialize each customer's checkout; retrying the same request is safe.
  perform pg_advisory_xact_lock(hashtextextended(uid::text, 0));
  select * into row_order from public.orders where user_id=uid and request_id=p_request_id;
  if found then return to_jsonb(row_order) - 'user_id' - 'request_id'; end if;
  if (select count(*) from public.orders where user_id=uid and created_at > now()-interval '1 minute') >= 5
    then raise exception 'Please wait a minute before placing another order.'; end if;
  if p_lines is null or jsonb_typeof(p_lines) <> 'array' then raise exception 'Invalid cart.'; end if;
  if jsonb_array_length(p_lines) not between 1 and 50 then raise exception 'Choose between 1 and 50 cart lines.'; end if;
  if p_customer_name is null or length(trim(p_customer_name)) not between 2 and 100
    then raise exception 'Enter your name.'; end if;
  if p_note is null or length(p_note)>500 then raise exception 'Keep the order note under 500 characters.'; end if;
  if p_delivery is null then raise exception 'Choose pickup or delivery.'; end if;
  if p_delivery and (p_address is null or jsonb_typeof(p_address)<>'object'
      or coalesce(length(trim(p_address->>'street')),0) not between 3 and 200
      or coalesce(length(trim(p_address->>'city')),0) not between 2 and 100
      or coalesce(length(trim(p_address->>'phone')),0) not between 6 and 30
      or coalesce(length(trim(p_address->>'label')),0) not between 1 and 50)
    then raise exception 'Add a complete delivery address.'; end if;
  for item in select value from jsonb_array_elements(p_lines) loop
    if jsonb_typeof(item) <> 'object' or jsonb_typeof(item->'quantity') <> 'number'
      or (item->>'quantity') !~ '^[0-9]{1,2}$' then raise exception 'Invalid quantity.'; end if;
    qty := (item->>'quantity')::integer;
    cup_size := item->>'size';
    if qty is null or qty not between 1 and 20 or cup_size is null or cup_size not in ('S','M','L')
      then raise exception 'Choose a valid size and quantity (1–20).'; end if;
    select * into product from public.coffees where id=item->>'coffee_id' and available for share;
    if not found then raise exception 'A coffee is no longer available. Refresh your menu.'; end if;
    unit_price := product.price_cents + case cup_size when 'M' then 50 when 'L' then 100 else 0 end;
    subtotal := subtotal + unit_price*qty;
    snapshot := snapshot || jsonb_build_array(jsonb_build_object(
      'coffee', to_jsonb(product), 'size',cup_size,'quantity',qty,'unit_price_cents',unit_price));
  end loop;
  fee := case when p_delivery then 150 else 0 end;
  if p_expected_total is null or p_expected_total <> subtotal+fee
    then raise exception 'Prices changed. Refresh your cart before ordering.'; end if;
  insert into public.orders(user_id, request_id, payload) values (uid,p_request_id,
    jsonb_build_object('lines',snapshot,'delivery',p_delivery,'payment','cash',
      'customer_name',trim(p_customer_name),'address',case when p_delivery then p_address else null end,
      'note',p_note,'delivery_cents',fee,'total_cents',subtotal+fee)) returning * into row_order;
  return to_jsonb(row_order) - 'user_id' - 'request_id';
end; $$;

create function public.cancel_order(p_order_id uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare row_order public.orders;
begin
  if auth.uid() is null then raise exception 'Please sign in again.'; end if;
  select * into row_order from public.orders where id=p_order_id and user_id=auth.uid() for update;
  if not found then raise exception 'Order unavailable.'; end if;
  if row_order.status not in ('confirmed','cancelled') then raise exception 'This order is already being prepared and cannot be cancelled.'; end if;
  update public.orders set status='cancelled' where id=p_order_id returning * into row_order;
  return to_jsonb(row_order) - 'user_id' - 'request_id';
end; $$;
revoke all on function public.place_order(uuid,jsonb,boolean,text,jsonb,text,integer) from public, anon;
revoke all on function public.cancel_order(uuid) from public, anon;
grant execute on function public.place_order(uuid,jsonb,boolean,text,jsonb,text,integer) to authenticated;
grant execute on function public.cancel_order(uuid) to authenticated;
commit;
