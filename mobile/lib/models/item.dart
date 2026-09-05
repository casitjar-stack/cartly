class Item {
  final String id;
  final String name;
  final int quantity;
  final bool bought;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.name,
    required this.quantity,
    required this.bought,
    required this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      bought: json['bought'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}