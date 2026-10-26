class ItemSummary {
  final String name;
  final int quantity;
  final String itemId;

  const ItemSummary({
    required this.name,
    required this.quantity,
    required this.itemId,
  });

  factory ItemSummary.fromJson(Map<String, dynamic> json) => ItemSummary(
        name: (json['name'] ?? '').toString(),
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        itemId: (json['itemId'] ?? '').toString(),
      );
}