import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/item.dart';

void main() {
  test('Item.fromJson creates an Item correctly', () {
    final item = Item.fromJson({
      'id': 'item-1',
      'name': 'Milk',
      'quantity': 2,
      'bought': false,
      'createdAt': '2026-09-05T06:54:08.060Z',
    });

    expect(item.id, 'item-1');
    expect(item.name, 'Milk');
    expect(item.quantity, 2);
    expect(item.bought, false);
    expect(
      item.createdAt,
      DateTime.parse('2026-09-05T06:54:08.060Z'),
    );
  });
}