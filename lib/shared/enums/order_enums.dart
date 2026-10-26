

enum KdsTab { completed, open, hold }

enum OrderType { dineIn, takeOut }
// enum OrderType1 { dineIn, takeOut, pickup, delivery, curbside }

enum OrderUrgency { fresh, caution, late }

extension OrderTypeX on OrderType {
  String get label {
    switch (this) {
      case OrderType.dineIn:  return 'DINE IN';
      case OrderType.takeOut:     return 'TAKEOUT';
    //   case OrderType.pickup:   return 'PICKUP';
    //   case OrderType.delivery: return 'DELIVERY';
    //   case OrderType.curbside: return 'CURBSIDE';
    }
  }
}
