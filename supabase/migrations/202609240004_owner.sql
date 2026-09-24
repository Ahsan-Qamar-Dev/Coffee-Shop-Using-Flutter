begin;
create function public.is_store_owner() returns boolean
language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.store_staff where user_id=auth.uid() and role='owner');
$$;
create function public.owner_menu() returns setof jsonb
language plpgsql security definer set search_path = '' as $$
begin
 if not public.is_store_owner() then raise exception 'Owner access required.'; end if;
 return query select to_jsonb(c) from public.coffees c order by c.sort_order,c.id;
end; $$;
create function public.owner_update_coffee(p_id text,p_name text,p_description text,p_price integer,p_available boolean)
returns void language plpgsql security definer set search_path = '' as $$
begin
 if not public.is_store_owner() then raise exception 'Owner access required.'; end if;
 if p_name is null or length(trim(p_name)) not between 2 and 80 or p_description is null
   or length(trim(p_description)) not between 10 and 2000 or p_price is null
   or p_price not between 1 and 100000 or p_available is null then raise exception 'Check the product fields.'; end if;
 update public.coffees set name=trim(p_name),description=trim(p_description),price_cents=p_price,available=p_available where id=p_id;
 if not found then raise exception 'Coffee unavailable.'; end if;
end; $$;
create function public.owner_team() returns table(user_id uuid,email text,role text)
language plpgsql security definer set search_path = '' as $$
begin
 if not public.is_store_owner() then raise exception 'Owner access required.'; end if;
 return query select s.user_id,u.email::text,s.role from public.store_staff s join auth.users u on u.id=s.user_id order by s.created_at;
end; $$;
create function public.owner_set_staff(p_email text,p_enabled boolean) returns void
language plpgsql security definer set search_path = '' as $$
declare target uuid;
begin
 if not public.is_store_owner() then raise exception 'Owner access required.'; end if;
 if p_enabled is null then raise exception 'Choose staff access.'; end if;
 select id into target from auth.users where lower(email)=lower(trim(p_email)) and email_confirmed_at is not null;
 if target is null then raise exception 'Ask this person to register and confirm their account first.'; end if;
 if exists(select 1 from public.store_staff where user_id=target and role='owner') then raise exception 'Owner access must be managed by the project administrator.'; end if;
 if p_enabled then insert into public.store_staff(user_id,role) values(target,'staff') on conflict(user_id) do nothing;
 else delete from public.store_staff where user_id=target and role='staff'; end if;
end; $$;
revoke all on function public.is_store_owner() from public,anon;
revoke all on function public.owner_menu() from public,anon;
revoke all on function public.owner_update_coffee(text,text,text,integer,boolean) from public,anon;
revoke all on function public.owner_team() from public,anon;
revoke all on function public.owner_set_staff(text,boolean) from public,anon;
grant execute on function public.is_store_owner() to authenticated;
grant execute on function public.owner_menu() to authenticated;
grant execute on function public.owner_update_coffee(text,text,text,integer,boolean) to authenticated;
grant execute on function public.owner_team() to authenticated;
grant execute on function public.owner_set_staff(text,boolean) to authenticated;
commit;
