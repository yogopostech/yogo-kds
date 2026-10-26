


// class Urls {
//   static const String baseUrl = 'https://yogo-kds-backend.onrender.com/api';
//   // Socket.IO server (no /api path — baseUrl theke /api baad)
// static const String socketServer = 'https://squelchily-phylic-tamala.ngrok-free.dev';

//   // Auth
//   static const String pair = '/kds/pair';

//   // Orders
//   static const String orders = '/orders';

//   // KDS order actions — pass the order id
//   static String bump(String id) => '/kds/orders/$id/bump';
//   static String recall(String id) => '/kds/orders/$id/recall';
//   static String hold(String id) => '/kds/orders/$id/hold';
//   static String release(String id) => '/kds/orders/$id/release';
//   // Item summary (aggregated open-order items)
// static const String itemSummary = '$baseUrl/kds/orders/summary';
// // Mark an item ready / not-ready
// static String itemReady(String orderId, String itemId) =>
//     '$baseUrl/kds/orders/$orderId/items/$itemId/ready';
//     // Rename this KDS device — PATCH /api/kds-devices/:deviceId  { name }
// static String renameDevice(String deviceId) => '$baseUrl/kds-devices/$deviceId';
// static const String deviceMe = '$baseUrl/kds/me';
// static const String unpair = '$baseUrl/kds/unpair';
// static const String clearCompleted = '$baseUrl/kds/orders/completed/clear';

//     // Mark a single modifier ready / not-ready
// static String modifierReady(
//   String orderId,
//   String itemId,
//   String modifierId,
// ) =>
//     '$baseUrl/kds/orders/$orderId/items/$itemId/modifiers/$modifierId/ready';
// }



class Urls {
  // static const String baseUrl = 'https://squelchily-phylic-tamala.ngrok-free.dev/api/v1';
  static const String baseUrl = 'https://yogopos.onrender.com/api/v1';



  // Socket.IO server (no /api path)
  static const String socketServer =
      'https://s1.yogoeats.com';

  // ── Auth ─────────────────────────────────────────────
  // static const String pair = '/sessions/pair';
  static const String deviceMe = '/kds/me';
  static const String unpair = '/kds/unpair';

  // ── Orders ───────────────────────────────────────────
  static const String orders = '/kds/orders';
  static const String itemSummary = '/kds/orders/summary';
  static const String clearCompleted = '/kds/orders/completed/clear';

  // ── KDS order actions — pass the order id ────────────
  static String bump(String id) => '/kds/orders/$id';
  static String recall(String id) => '/kds/orders/$id';
  static String hold(String id) => '/kds/orders/$id';
  static String release(String id) => '/kds/orders/$id';
  static String orderType(String id) => '/kds/orders/$id';
  static String move(String id) => '/kds/orders/$id';


  // ── Item / modifier ready ────────────────────────────
  static String itemReady(String orderId) =>
      '/kds/orders/$orderId';

  static String modifierReady(
    String orderId,
    String itemId,
    String modifierId,
  ) =>
      '/kds/orders/$orderId/items/$itemId/modifiers/$modifierId/ready';

  // ── Device ───────────────────────────────────────────
  // PATCH /api/kds-devices/:deviceId  { name }
  static String renameDevice(String deviceId) => '/kds-devices/$deviceId';
}