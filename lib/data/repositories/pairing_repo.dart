import 'dart:io';
import 'package:dio/dio.dart';
import 'package:yogo_kds/shared/services/socket_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/preferences.dart';

class PairingResult {
  final bool success;
  final String? error;

  PairingResult({required this.success, this.error});
}

class PairingRepository {
  // Detect device type for the request body
  static String _deviceType() {
    if (Platform.isWindows) return 'WINDOWS';
    if (Platform.isAndroid) return 'ANDROID';
    if (Platform.isIOS) return 'IOS';
    if (Platform.isMacOS) return 'MACOS';
    if (Platform.isLinux) return 'LINUX';
    return 'UNKNOWN';
  }

  Future<PairingResult> pair(String pairingCode) async {
    try {
      final response = await DioClient.instance.post(
        '/kds/sessions/pair',
        data: {
          'pairingCode': pairingCode,
          // 'deviceId': Preferences.deviceId, // our generated UUID
          'deviceType': _deviceType(),
        },
      );

      final body = response.data;
      if (body['success'] == true && body['data'] != null) {
        final data = body['data'];
        final device = data['device'];

        // Save token + user + device info locally
        Preferences.token = data['token'] ?? '';
        Preferences.userId = device['user'] ?? '';
        Preferences.deviceName = device['name'] ?? '';
        //  Preferences.deviceDbId = (device['_id'] ?? device['id'] ?? '').toString();
         Preferences.deviceDbId = (device['id'] ?? '').toString();
        Preferences.isPaired = true;
        //socket ke notun ids diye re-register ↓↓↓
        SocketService.instance.reRegister();

        return PairingResult(success: true);
      }

      return PairingResult(
        success: false,
        error: body['message'] ?? 'Pairing failed. Please try again.',
      );
    } on DioException catch (e) {
      // Server sent an error response
      if (e.response != null) {
        final msg = e.response?.data is Map
            ? (e.response?.data['message'] ?? 'Invalid pairing code')
            : 'Invalid pairing code';
        return PairingResult(success: false, error: msg.toString());
      }
      // Network / timeout
      return PairingResult(
        success: false,
        error: 'Cannot reach server. Check your connection.',
      );
    } catch (e) {
      return PairingResult(
        success: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }
}

final pairingRepository = PairingRepository();




///Are you sure you want to continue? You will be logged out completely and will need a new pairing code to log in again.