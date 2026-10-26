


// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';

// // Central place for all locally-stored values
// class Preferences {
//   static late SharedPreferences _prefs;

//   static const _kDeviceId = 'device_id';
//   static const _kToken = 'auth_token';
//   static const _kUserId = 'user_id';
//   static const _kDeviceName = 'device_name';
//   static const _kPaired = 'is_paired';

//   static Future<void> init() async {
//     _prefs = await SharedPreferences.getInstance();
//   }

//   // ── Device ID — generated once, reused forever ──────────────
//   static String get deviceId => _prefs.getString(_kDeviceId) ?? '';
//   static set deviceId(String v) => _prefs.setString(_kDeviceId, v);

//   // ── Auth token ──────────────────────────────────────────────
//   static String get token => _prefs.getString(_kToken) ?? '';
//   static set token(String v) => _prefs.setString(_kToken, v);

//   // ── User id ─────────────────────────────────────────────────
//   static String get userId => _prefs.getString(_kUserId) ?? '';
//   static set userId(String v) => _prefs.setString(_kUserId, v);

//   // ── Device name ─────────────────────────────────────────────
//   static String get deviceName => _prefs.getString(_kDeviceName) ?? '';
//   static set deviceName(String v) => _prefs.setString(_kDeviceName, v);

//   // ── Paired flag ─────────────────────────────────────────────
//   static bool get isPaired => _prefs.getBool(_kPaired) ?? false;
//   static set isPaired(bool v) => _prefs.setBool(_kPaired, v);

//     // ── Generic int helpers (settings persistence) ──────────────
//   static int? getInt(String key) => _prefs.getInt(key);
//   static Future<void> setInt(String key, int v) => _prefs.setInt(key, v);

//     static const _kStationId = 'station_id';

//   // ── Station ID (ei screen er id) ────────────────────────────
//   static String get stationId => _prefs?.getString(_kStationId) ?? '';
//   static set stationId(String v) => _prefs?.setString(_kStationId, v);

//   // app open er somoy call koro — khali thakle ekbar UUID generate kore save
//   static void ensureStationId() {
//     final existing = _prefs?.getString(_kStationId);
//     if (existing == null || existing.trim().isEmpty) {
//       final id = const Uuid().v4();
//       _prefs?.setString(_kStationId, id);
//     }
//   }
  

//   // ── Clear everything on logout/unpair ───────────────────────
//   static Future<void> clearAuth() async {
//     await _prefs.remove(_kToken);
//     await _prefs.remove(_kUserId);
//     await _prefs.remove(_kDeviceName);
//     await _prefs.setBool(_kPaired, false);
//   }
// }










import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// Central place for all locally-stored values
class Preferences {
  static late SharedPreferences _prefs;

  static const _kDeviceId = 'device_id';
  static const _kToken = 'auth_token';
  static const _kUserId = 'user_id';
  static const _kDeviceName = 'device_name';
  static const _kPaired = 'is_paired';
  static const _kDeviceDbId = 'device_db_id'; // ← NEW: backend Mongo _id

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Device ID — local UUID, reused forever ──────────────────
  static String get deviceId => _prefs.getString(_kDeviceId) ?? '';
  static set deviceId(String v) => _prefs.setString(_kDeviceId, v);

  // ── Backend device Mongo _id (used for device APIs: rename) ──
  static String get deviceDbId => _prefs.getString(_kDeviceDbId) ?? '';
  static set deviceDbId(String v) => _prefs.setString(_kDeviceDbId, v);

  // ── Auth token ──────────────────────────────────────────────
  static String get token => _prefs.getString(_kToken) ?? '';
  static set token(String v) => _prefs.setString(_kToken, v);

  // ── User id ─────────────────────────────────────────────────
  static String get userId => _prefs.getString(_kUserId) ?? '';
  static set userId(String v) => _prefs.setString(_kUserId, v);

  // ── Device name ─────────────────────────────────────────────
  static String get deviceName => _prefs.getString(_kDeviceName) ?? '';
  static set deviceName(String v) => _prefs.setString(_kDeviceName, v);

  // ── Paired flag ─────────────────────────────────────────────
  static bool get isPaired => _prefs.getBool(_kPaired) ?? false;
  static set isPaired(bool v) => _prefs.setBool(_kPaired, v);

  // ── Generic int helpers (settings persistence) ──────────────
  static int? getInt(String key) => _prefs.getInt(key);
  static Future<void> setInt(String key, int v) => _prefs.setInt(key, v);

  static const _kStationId = 'station_id';

  // ── Station ID (ei screen er id) ────────────────────────────
  static String get stationId => _prefs.getString(_kStationId) ?? '';
  static set stationId(String v) => _prefs.setString(_kStationId, v);

  // app open er somoy call koro — khali thakle ekbar UUID generate kore save
  static void ensureStationId() {
    final existing = _prefs.getString(_kStationId);
    if (existing == null || existing.trim().isEmpty) {
      final id = const Uuid().v4();
      _prefs.setString(_kStationId, id);
    }
  }

  // ── Clear everything on logout/unpair ───────────────────────
  static Future<void> clearAuth() async {
    await _prefs.remove(_kToken);
    await _prefs.remove(_kUserId);
    await _prefs.remove(_kDeviceName);
    await _prefs.remove(_kDeviceDbId); // ← NEW: unpair e Mongo id o muche jabe
    await _prefs.setBool(_kPaired, false);
  }
}