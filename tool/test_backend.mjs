import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { PGlite } from '../.backend-test/node_modules/@electric-sql/pglite/dist/index.js';

// Disposable PostgreSQL instance. auth.uid() emulates Supabase's JWT identity.
const db = new PGlite();
const alice = '11111111-1111-4111-8111-111111111111';
const bob = '22222222-2222-4222-8222-222222222222';
let checks = 0;
async function rejected(sql, params = []) {
  await assert.rejects(db.query(sql, params)); checks++;
}
try {
  await db.exec(`create role anon; create role authenticated;
    create schema auth; create table auth.users(id uuid primary key, email text, email_confirmed_at timestamptz);
    create function auth.uid() returns uuid language sql stable as
    $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
    grant usage on schema auth to authenticated, anon;
    grant execute on function auth.uid() to authenticated, anon;
    insert into auth.users values ('${alice}','alice@example.test',now()), ('${bob}','bob@example.test',now());`);
  for (const name of ['202609220001_shop.sql', '202609230002_catalog.sql', '202609230003_staff.sql', '202609240004_owner.sql']) {
    await db.exec(await readFile(new URL('../supabase/migrations/' + name, import.meta.url), 'utf8'));
  }
  async function login(id) {
    await db.exec('reset role; set role authenticated;');
    await db.query("select set_config('request.jwt.claim.sub', $1, false)", [id]);
  }
  await login(alice);
  assert.equal((await db.query('select * from public.coffees')).rows.length, 11); checks++;
  await db.query('insert into public.customer_state(user_id,state) values ($1,$2)', [alice, {phone:'123456'}]);
  await rejected('insert into public.customer_state(user_id,state) values ($1,$2)', [bob, {}]);
  await rejected('update public.coffees set price_cents=1');
  const call = 'select public.place_order($1,$2,$3,$4,$5,$6,$7) as result';
  const args = ['33333333-3333-4333-8333-333333333333', JSON.stringify([{coffee_id:'c1',size:'M',quantity:2}]), false, 'Alice', null, '', 940];
  const first = (await db.query(call,args)).rows[0].result;
  assert.equal(first.payload.total_cents,940); checks++;
  assert.equal((await db.query(call,args)).rows[0].result.id,first.id); checks++;
  assert.equal((await db.query('select * from orders')).rows.length,1); checks++;
  const fresh = () => ['44444444-4444-4444-8444-444444444444', ...args.slice(1)];
  let bad = fresh(); bad[6]=1; await rejected(call,bad);
  for (const quantity of [0,21,-1,1.5,null,'2']) {
    bad=fresh(); bad[1]=JSON.stringify([{coffee_id:'c1',size:'M',quantity}]); await rejected(call,bad);
  }
  bad=fresh(); bad[2]=true; bad[6]=1090; await rejected(call,bad);
  await rejected('insert into orders(user_id,request_id,payload) values ($1,$2,$3)',[alice,args[0],{}]);
  await login(bob);
  assert.equal((await db.query('select * from orders')).rows.length,0); checks++;
  assert.equal((await db.query('select * from customer_state')).rows.length,0); checks++;
  await rejected('select public.cancel_order($1)',[first.id]);
  await login(alice);
  assert.equal((await db.query('select public.cancel_order($1) as result',[first.id])).rows[0].result.status,'cancelled'); checks++;
  await rejected('select public.staff_orders()');
  await rejected('insert into public.store_staff(user_id) values ($1)',[alice]);
  await db.exec('reset role;');
  await db.query('insert into public.store_staff(user_id) values ($1)',[alice]);
  await login(alice);
  assert.equal((await db.query('select public.is_store_staff() as member')).rows[0].member,true); checks++;
  const next = (await db.query(call,fresh())).rows[0].result;
  await rejected("select public.staff_set_order_status($1,'completed')",[next.id]);
  for (const status of ['preparing','ready','completed']) {
    assert.equal((await db.query('select public.staff_set_order_status($1,$2) as result',[next.id,status])).rows[0].result.status,status); checks++;
  }
  await rejected("select public.staff_set_order_status($1,'confirmed')",[next.id]);
  await rejected('select public.owner_menu()');
  await rejected("select public.owner_set_staff('bob@example.test',true)");
  await db.exec("reset role; update public.store_staff set role='owner';");
  await login(alice);
  assert.equal((await db.query('select public.owner_menu()')).rows.length,11); checks++;
  await rejected("select public.owner_update_coffee('c1','Coffee','A test coffee description',0,true)");
  await db.query("select public.owner_update_coffee('c1','Coffee','A test coffee description',500,true)");
  assert.equal((await db.query("select price_cents from coffees where id='c1'")).rows[0].price_cents,500); checks++;
  await db.query("select public.owner_set_staff('bob@example.test',true)");
  assert.equal((await db.query('select * from public.owner_team()')).rows.length,2); checks++;
  await rejected("select public.owner_set_staff('alice@example.test',false)");
  await db.query("select public.owner_set_staff('bob@example.test',false)");
  await login(bob);
  await rejected('select public.staff_orders()');
  await rejected("select public.staff_set_order_status($1,'cancelled')",[next.id]);
  await db.exec('reset role; set role anon;');
  await rejected('select * from public.customer_state');
  await rejected(call,args);
  console.log(`PASS: ${checks} database checks (pricing, retries, validation, ownership, cancellation, anonymous access).`);
} finally { await db.close(); }
