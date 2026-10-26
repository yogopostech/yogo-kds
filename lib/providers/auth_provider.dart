// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class AuthNotifier extends StateNotifier<bool> {
//   AuthNotifier() : super(false);

//   // Pairing via activation code — later replace with backend verification
//   // Backend: POST /kds/pair { code } → returns { deviceId, tenantId, token }
//   Future<bool> pairDevice(String code) async {
//     if (code.length < 8) return false;
//     await Future.delayed(const Duration(milliseconds: 800)); // fake network
//     // For now any 6-digit code works; wire real API here
//     state = true;
//     return true;
//   }

//   void logout() => state = false;
// }

// final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
//   return AuthNotifier();
// });

// // The device's generated activation code (shown to user, entered on backoffice)
// // In production this comes from backend when device first boots
// final activationCodeProvider = StateProvider<String>((ref) {
//   return 'A4K9-2X'; // placeholder; backend will assign a real one
// });







import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yogo_kds/data/repositories/pairing_repo.dart';
import '../core/storage/preferences.dart';


class AuthNotifier extends StateNotifier<bool> {
  // Initial state read from storage — already paired devices skip pairing
  AuthNotifier() : super(Preferences.isPaired);

  Future<PairingResult> pairDevice(String code) async {
    final result = await pairingRepository.pair(code);
    if (result.success) {
      state = true;
    }
    return result;
  }

  Future<void> logout() async {
    await Preferences.clearAuth();
    state = false;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});