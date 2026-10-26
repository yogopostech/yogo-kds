

import 'package:audioplayers/audioplayers.dart';

/// Plays the KDS notification sound (new order).
class NotificationSoundService {
  NotificationSoundService._();
  static final NotificationSoundService instance =
      NotificationSoundService._();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playNewOrder() async {
    try {
      await _player.stop(); // overlap na
      await _player.play(AssetSource('sounds/notification_4.mp3'));
    } catch (_) {
      // sound fail korle app atkabe na
    }
  }
}