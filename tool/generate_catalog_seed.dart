import 'dart:io';

import 'package:my_coffee_shop/features/catalog/data/sample_catalog.dart';

// Run from the project root. Existing products retain merchant edits on re-run.
void main() {
  String quote(String value) => "'${value.replaceAll("'", "''")}'";
  final rows = <String>[];
  for (var i = 0; i < sampleCoffees.length; i++) {
    final c = sampleCoffees[i];
    rows.add(
      '(${[quote(c.id), quote(c.name), quote(c.subtitle), quote(c.description), c.priceCentsFor('S'), c.rating, quote(c.imagePath), quote(c.category), c.containsMilk, c.isIced, i].join(', ')})',
    );
  }
  File('supabase/migrations/202609230002_catalog.sql').writeAsStringSync(
    '-- Generated from sample_catalog.dart; preserves existing merchant edits.\n'
    'begin;\n'
    'insert into public.coffees (id, name, subtitle, description, price_cents, '
    'rating, image_path, category, contains_milk, is_iced, sort_order) values\n'
    '${rows.join(',\n')}\non conflict (id) do nothing;\ncommit;\n',
  );
}
