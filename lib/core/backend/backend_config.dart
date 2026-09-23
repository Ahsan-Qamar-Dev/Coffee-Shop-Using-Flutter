class BackendConfig {
  static bool live = false;
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://sxduvqxceyawunjonqaj.supabase.co',
  );
  // Publishable client key. Security is enforced by PostgreSQL RLS and RPC grants.
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_zMCtX3krK7B9BreIbtGcSw_L14P-80Q',
  );
}
