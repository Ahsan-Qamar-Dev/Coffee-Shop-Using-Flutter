import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_coffee_shop/core/backend/backend_config.dart';

// Read-only checks using the same publishable key shipped with the app.
Future<void> main() async {
  final headers = {'apikey': BackendConfig.publishableKey};
  final settings = await http.get(Uri.parse('${BackendConfig.url}/auth/v1/settings'), headers: headers);
  if (settings.statusCode != 200 || (jsonDecode(settings.body) as Map)['external']?['email'] != true) {
    stderr.writeln('Auth connectivity check failed (${settings.statusCode}).');
    exitCode = 1; return;
  }
  for (final table in ['coffees','customer_state','orders']) {
    final response = await http.get(Uri.parse('${BackendConfig.url}/rest/v1/$table?select=*&limit=1'),headers:headers);
    if (response.statusCode != 401 && response.statusCode != 403) {
      stderr.writeln('Unexpected anonymous access result for $table: ${response.statusCode}.');
      exitCode = 1; return;
    }
  }
  stdout.writeln('PASS: app project/key reaches Auth; all three tables reject anonymous reads.');
}
