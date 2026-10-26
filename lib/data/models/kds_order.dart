// import '../../shared/enums/order_enums.dart';

// // ── Modifier ──────────────────────────────────────────────────
// class KdsModifier {
//   final String name;
//   bool isReady;

//   KdsModifier({required this.name, this.isReady = false});
// }

// // ── Order item ────────────────────────────────────────────────
// class KdsOrderItem {
//   final String name;
//   final int qty;
//   final String category;
//   final List<KdsModifier> modifiers;
//   final String kitchenNote; // API থেকে — chef এর জন্য note
//   bool isReady;

//   KdsOrderItem({
//     required this.name,
//     required this.qty,
//     this.category = 'Unassigned',
//     this.modifiers = const [],
//     this.kitchenNote = '',
//     this.isReady = false,
//   });

//   factory KdsOrderItem.fromJson(Map<String, dynamic> json) {
//     // modifiers — API তে string এর array: ["EXTRA-SAUS"]
//     final modsRaw = json['modifiers'] ?? [];
//     final mods = (modsRaw is List)
//         ? modsRaw.map((m) {
//             if (m is Map<String, dynamic>) {
//               return KdsModifier(name: m['name']?.toString() ?? '');
//             }
//             return KdsModifier(name: m.toString());
//           }).toList()
//         : <KdsModifier>[];

//     // quantity int/double দুটোই হতে পারে
//     final q = json['quantity'] ?? 1;
//     final qty = q is int ? q : (q as num).toInt();

//     return KdsOrderItem(
//       name: json['name']?.toString() ?? 'Item',
//       qty: qty,
//       category: json['itemType']?.toString() ?? 'Unassigned',
//       modifiers: mods,
//       kitchenNote: json['kitchenNote']?.toString() ?? '',
//     );
//   }
// }

// // ── Order ─────────────────────────────────────────────────────
// class KdsOrder {
//   final String id;
//   final String orderNumber; // ORD-10010 — card এ দেখানোর জন্য
//   final String customerName;
//   OrderType type;
//   final String source;
//   final DateTime placedAt;
//   final List<KdsOrderItem> items;
//   final String orderNote; // পুরো order এর note
//   final String tableName;
//   bool isCompleted;
//   bool isOnHold;
//   DateTime? holdUntil;
//   DateTime? completedAt;

//   KdsOrder({
//     required this.id,
//     this.orderNumber = '',
//     required this.customerName,
//     required this.type,
//     this.source = 'POS',
//     required this.placedAt,
//     required this.items,
//     this.orderNote = '',
//     this.tableName = '',
//     this.isCompleted = false,
//     this.isOnHold = false,
//     this.holdUntil,
//     this.completedAt,
//   });

//   // ── From API ────────────────────────────────────────────────
//   factory KdsOrder.fromJson(Map<String, dynamic> json) {
//     final cartsRaw = json['carts'] ?? [];
//     final items = (cartsRaw is List)
//         ? cartsRaw
//             .map((c) => KdsOrderItem.fromJson(c as Map<String, dynamic>))
//             .toList()
//         : <KdsOrderItem>[];

//     final status = json['orderStatus']?.toString() ?? '';

//     return KdsOrder(
//       id: json['id']?.toString() ?? json['orderId']?.toString() ?? '',
//       orderNumber: json['orderId']?.toString() ?? '',
//       customerName: json['guestName']?.toString() ?? 'Guest',
//       type: _typeFromApi(json['orderType']?.toString()),
//       source: 'POS',
//       placedAt:
//           DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal() ??
//               DateTime.now(),
//       items: items,
//       orderNote: json['orderNote']?.toString() ?? '',
//       tableName: json['tableName']?.toString() ?? '',
//       isCompleted: status == 'COMPLETED',
//     );
//   }

//   static OrderType _typeFromApi(String? apiType) {
//     switch (apiType) {
//       case 'DINE_IN':
//         return OrderType.dineIn;
//       case 'TAKEOUT':
//       case 'TAKE_OUT':
//       case 'DELIVERY':
//         return OrderType.takeOut;
//       default:
//         return OrderType.dineIn;
//     }
//   }

//   // ── Timing ──────────────────────────────────────────────────
//   Duration get elapsed => DateTime.now().difference(placedAt);

//   String get elapsedLabel {
//     final d = elapsed;
//     final h = d.inHours.toString().padLeft(2, '0');
//     final m = (d.inMinutes % 60).toString().padLeft(2, '0');
//     final s = (d.inSeconds % 60).toString().padLeft(2, '0');
//     return '$h:$m:$s';
//   }

//   String get placedAtLabel => _formatTime(placedAt);

//   String get completedAtLabel =>
//       completedAt == null ? '' : _formatDateTime(completedAt!);

//   String _formatTime(DateTime t) {
//     final h = (t.hour % 12 == 0 ? 12 : t.hour % 12).toString().padLeft(2, '0');
//     final m = t.minute.toString().padLeft(2, '0');
//     final s = t.second.toString().padLeft(2, '0');
//     final period = t.hour >= 12 ? 'PM' : 'AM';
//     return '$h:$m:$s $period';
//   }

//   String _formatDateTime(DateTime t) {
//     final mo = t.month.toString().padLeft(2, '0');
//     final da = t.day.toString().padLeft(2, '0');
//     return '$mo/$da/${t.year} ${_formatTime(t)}';
//   }

//   OrderUrgency get urgency {
//     final mins = elapsed.inMinutes;
//     if (mins < 3) return OrderUrgency.fresh;
//     if (mins < 7) return OrderUrgency.caution;
//     return OrderUrgency.late;
//   }

//   String get holdRemainingLabel {
//     if (holdUntil == null) return '';
//     final remaining = holdUntil!.difference(DateTime.now());
//     if (remaining.isNegative) return '00:00';
//     final m = remaining.inMinutes.toString().padLeft(2, '0');
//     final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
//     return '$m:$s';
//   }

//   bool get allItemsReady => items.every((i) => i.isReady);
// }

// import '../../shared/enums/order_enums.dart';

// // ── Modifier ──────────────────────────────────────────────────
// class KdsModifier {
//   final String id;
//   final String name;
//   bool isReady;

//   KdsModifier({this.id = '', required this.name, this.isReady = false});

//   factory KdsModifier.fromJson(Map<String, dynamic> json) {
//     return KdsModifier(
//       id: json['id']?.toString() ?? '',
//       name: json['title']?.toString() ?? json['name']?.toString() ?? '',
//       isReady: json['ready'] == true,
//     );
//   }
// }

// // ── Order item ────────────────────────────────────────────────
// class KdsOrderItem {
//   final String id;
//   final String name;
//   final int qty;
//   final String category;
//   final List<KdsModifier> modifiers;
//   final String kitchenNote;
//   bool isReady;

//   KdsOrderItem({
//     this.id = '',
//     required this.name,
//     required this.qty,
//     this.category = 'Unassigned',
//     this.modifiers = const [],
//     this.kitchenNote = '',
//     this.isReady = false,
//   });

//   factory KdsOrderItem.fromJson(Map<String, dynamic> json) {
//     final modsRaw = json['modifiers'] ?? [];
//     final mods = (modsRaw is List)
//         ? modsRaw.map((m) {
//             if (m is Map<String, dynamic>) return KdsModifier.fromJson(m);
//             return KdsModifier(name: m.toString());
//           }).toList()
//         : <KdsModifier>[];

//     final q = json['quantity'] ?? 1;
//     final qty = q is int ? q : (q as num).toInt();

//     return KdsOrderItem(
//       id: json['id']?.toString() ?? '',
//       name: json['name']?.toString() ?? 'Item',
//       qty: qty,
//       category: json['itemType']?.toString() ?? 'Unassigned',
//       modifiers: mods,
//       kitchenNote: json['kitchenNote']?.toString() ?? '',
//       isReady: json['ready'] == true,
//     );
//   }
// }

// // ── Order ─────────────────────────────────────────────────────
// class KdsOrder {
//   final String id;
//   final String orderNumber;
//   final String customerName;
//   OrderType type;
//   final String source;
//   final DateTime placedAt;
//   final List<KdsOrderItem> items;
//   final String orderNote;
//   final String tableName;
//   bool isCompleted;
//   bool isOnHold;
//   DateTime? holdUntil;
//   DateTime? completedAt;

//   KdsOrder({
//     required this.id,
//     this.orderNumber = '',
//     required this.customerName,
//     required this.type,
//     this.source = 'POS',
//     required this.placedAt,
//     required this.items,
//     this.orderNote = '',
//     this.tableName = '',
//     this.isCompleted = false,
//     this.isOnHold = false,
//     this.holdUntil,
//     this.completedAt,
//   });

//   factory KdsOrder.fromJson(Map<String, dynamic> json) {
//     final cartsRaw = json['carts'] ?? [];
//     final items = (cartsRaw is List)
//         ? cartsRaw
//             .map((c) => KdsOrderItem.fromJson(c as Map<String, dynamic>))
//             .toList()
//         : <KdsOrderItem>[];

//     final kdsStatus = json['kdsStatus']?.toString() ?? 'OPEN';

//     return KdsOrder(
//       id: json['id']?.toString() ?? '',
//       orderNumber: json['orderId']?.toString() ?? '',
//       customerName: json['guestName']?.toString() ?? 'Guest',
//       type: _typeFromApi(json['orderType']?.toString()),
//       placedAt:
//           DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal() ??
//               DateTime.now(),
//       items: items,
//       orderNote: json['orderNote']?.toString() ?? '',
//       tableName: json['tableName']?.toString() ?? '',
//       isCompleted: kdsStatus == 'COMPLETED',
//       isOnHold: kdsStatus == 'HOLD',
//       holdUntil:
//           DateTime.tryParse(json['holdUntil']?.toString() ?? '')?.toLocal(),
//       completedAt:
//           DateTime.tryParse(json['bumpedAt']?.toString() ?? '')?.toLocal(),
//     );
//   }

//   static OrderType _typeFromApi(String? apiType) {
//     switch (apiType) {
//       case 'DINE_IN':
//         return OrderType.dineIn;
//       case 'TAKEOUT':
//       case 'TAKE_OUT':
//       case 'DELIVERY':
//         return OrderType.takeOut;
//       default:
//         return OrderType.dineIn;
//     }
//   }

//   // ── Timing ──────────────────────────────────────────────────
//   Duration get elapsed => DateTime.now().difference(placedAt);

//   String get elapsedLabel {
//     final d = elapsed;
//     final h = d.inHours.toString().padLeft(2, '0');
//     final m = (d.inMinutes % 60).toString().padLeft(2, '0');
//     final s = (d.inSeconds % 60).toString().padLeft(2, '0');
//     return '$h:$m:$s';
//   }

//   String get placedAtLabel => _formatTime(placedAt);

//   String get completedAtLabel =>
//       completedAt == null ? '' : _formatDateTime(completedAt!);

//   String _formatTime(DateTime t) {
//     final h = (t.hour % 12 == 0 ? 12 : t.hour % 12).toString().padLeft(2, '0');
//     final m = t.minute.toString().padLeft(2, '0');
//     final s = t.second.toString().padLeft(2, '0');
//     final period = t.hour >= 12 ? 'PM' : 'AM';
//     return '$h:$m:$s $period';
//   }

//   String _formatDateTime(DateTime t) {
//     final mo = t.month.toString().padLeft(2, '0');
//     final da = t.day.toString().padLeft(2, '0');
//     return '$mo/$da/${t.year} ${_formatTime(t)}';
//   }

//   OrderUrgency get urgency {
//     final mins = elapsed.inMinutes;
//     if (mins < 3) return OrderUrgency.fresh;
//     if (mins < 7) return OrderUrgency.caution;
//     return OrderUrgency.late;
//   }

//   String get holdRemainingLabel {
//     if (holdUntil == null) return '';
//     final remaining = holdUntil!.difference(DateTime.now());
//     if (remaining.isNegative) return '00:00';
//     final m = remaining.inMinutes.toString().padLeft(2, '0');
//     final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
//     return '$m:$s';
//   }

//   bool get allItemsReady => items.every((i) => i.isReady);
// }

import '../../shared/enums/order_enums.dart';

// ── Modifier ──────────────────────────────────────────────────
class KdsModifier {
  final String id;
  final String modifierId;
  final String name; // from `title`
  bool isReady;

  KdsModifier({
    this.id = '',
    this.modifierId = '',
    required this.name,
    this.isReady = false,
  });

  factory KdsModifier.fromJson(Map<String, dynamic> json) {
    return KdsModifier(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      modifierId: json['modifierId']?.toString() ?? '',
      name: json['title']?.toString() ?? json['name']?.toString() ?? '',
      isReady: json['ready'] == true,
    );
  }
}

// ── Variation option ──────────────────────────────────────────
class KdsVariation {
  final String id;
  final String name;
  final double price;
  final int quantity;

  KdsVariation({
    this.id = '',
    required this.name,
    this.price = 0,
    this.quantity = 1,
  });

  factory KdsVariation.fromJson(Map<String, dynamic> json) {
    final p = json['price'] ?? 0;
    final q = json['quantity'] ?? 1;
    return KdsVariation(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: p is num ? p.toDouble() : 0,
      quantity: q is int ? q : (q as num?)?.toInt() ?? 1,
    );
  }
}

// ── Order item ────────────────────────────────────────────────
class KdsOrderItem {
  final String id;
  final String itemId;
  final String name;
  final int qty;
  final String category; // from `itemType`
  final List<KdsModifier> modifiers;
  final List<KdsVariation> variations;
  final String kitchenNote;
  bool isReady;

  KdsOrderItem({
    this.id = '',
    this.itemId = '',
    required this.name,
    required this.qty,
    this.category = 'Unassigned',
    this.modifiers = const [],
    this.variations = const [],
    this.kitchenNote = '',
    this.isReady = false,
  });

  factory KdsOrderItem.fromJson(Map<String, dynamic> json) {
    // modifiers — object array { title, ready, modifierId }
    final modsRaw = json['modifiers'] ?? [];
    final mods = (modsRaw is List)
        ? modsRaw.map((m) {
            if (m is Map<String, dynamic>) return KdsModifier.fromJson(m);
            return KdsModifier(name: m.toString());
          }).toList()
        : <KdsModifier>[];

    // variationOptions — can be objects {name,...} OR plain strings ("Large")
    final varsRaw = json['variationOptions'] ?? [];
    final vars = (varsRaw is List)
        ? varsRaw
              .map((v) {
                if (v is Map<String, dynamic>) return KdsVariation.fromJson(v);
                // plain string like "Large" / "Medium"
                return KdsVariation(name: v.toString());
              })
              .where((v) => v.name.isNotEmpty)
              .toList()
        : <KdsVariation>[];

    final q = json['quantity'] ?? 1;
    final qty = q is int ? q : (q as num).toInt();

    return KdsOrderItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      itemId: json['itemId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Item',
      qty: qty,
      category: json['itemType']?.toString() ?? 'Unassigned',
      modifiers: mods,
      variations: vars,
      kitchenNote: json['kitchenNote']?.toString() ?? '',
      // isReady: json['ready'] == true,
      isReady: (json['kdsReady'] ?? json['ready']) == true,
    );
  }

  // variation names joined — for display, e.g. "Large" or "Large, Extra"
  String get variationLabel => variations.map((v) => v.name).join(', ');
}

// ── Order ─────────────────────────────────────────────────────
class KdsOrder {
  final String id;
  final String orderNumber; // from `orderId`
  final String customerName; // from `guestName`
  OrderType type;
  final String source;
  final DateTime placedAt;
  final List<KdsOrderItem> items;
  final String orderNote;
  final String tableName;
  final String tokenId;
  final bool isCancelled;
  bool isCompleted;
  bool isOnHold;
  DateTime? holdUntil;
  DateTime? completedAt;

  KdsOrder({
    required this.id,
    this.orderNumber = '',
    required this.customerName,
    required this.type,
    this.source = 'POS',
    required this.placedAt,
    required this.items,
    this.orderNote = '',
    this.tableName = '',
    this.tokenId = '',
    this.isCompleted = false,
    this.isOnHold = false,
    this.holdUntil,
    this.completedAt,
    this.isCancelled = false,
  });

  factory KdsOrder.fromJson(Map<String, dynamic> json) {
    // items come under `items` or `carts`
    final itemsRaw = json['items'] ?? json['carts'] ?? [];
    final items = (itemsRaw is List)
        ? itemsRaw
              .map((c) => KdsOrderItem.fromJson(c as Map<String, dynamic>))
              .toList()
        : <KdsOrderItem>[];

    final kdsStatus = json['kdsStatus']?.toString() ?? 'OPEN';

    return KdsOrder(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      orderNumber: json['orderId']?.toString() ?? '',
      customerName: json['guestName']?.toString() ?? 'Guest',
      type: _typeFromApi(json['orderType']?.toString()),
      placedAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      items: items,
      orderNote: json['orderNote']?.toString() ?? '',
      tableName: json['tableName']?.toString() ?? '',
      tokenId: json['tokenId']?.toString() ?? '',
      isCompleted: kdsStatus == 'COMPLETED',
      isOnHold: kdsStatus == 'HOLD',
      isCancelled: (json['orderStatus']?.toString().toUpperCase() == 'CANCELLED'),
      holdUntil: DateTime.tryParse(
        json['holdUntil']?.toString() ?? '',
      )?.toLocal(),
      completedAt: DateTime.tryParse(
        json['bumpedAt']?.toString() ?? '',
      )?.toLocal(),
    );
  }

  static OrderType _typeFromApi(String? apiType) {
    switch (apiType) {
      case 'DINE_IN':
        return OrderType.dineIn;
      case 'TAKEOUT':
      case 'TAKE_OUT':
      case 'DELIVERY':
        return OrderType.takeOut;
      default:
        return OrderType.dineIn;
    }
  }

  // ── Timing ──────────────────────────────────────────────────
  Duration get elapsed => DateTime.now().difference(placedAt);

  String get elapsedLabel {
    final d = elapsed;
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get placedAtLabel => _formatTime(placedAt);

  String get completedAtLabel =>
      completedAt == null ? '' : _formatDateTime(completedAt!);

  String _formatTime(DateTime t) {
    final h = (t.hour % 12 == 0 ? 12 : t.hour % 12).toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m:$s $period';
  }

  String _formatDateTime(DateTime t) {
    final mo = t.month.toString().padLeft(2, '0');
    final da = t.day.toString().padLeft(2, '0');
    return '$mo/$da/${t.year} ${_formatTime(t)}';
  }

  OrderUrgency get urgency {
    final mins = elapsed.inMinutes;
    if (mins < 3) return OrderUrgency.fresh;
    if (mins < 7) return OrderUrgency.caution;
    return OrderUrgency.late;
  }

  String get holdRemainingLabel {
    if (holdUntil == null) return '';
    final remaining = holdUntil!.difference(DateTime.now());
    if (remaining.isNegative) return '00:00';
    final m = remaining.inMinutes.toString().padLeft(2, '0');
    final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get allItemsReady => items.every((i) => i.isReady);
}
