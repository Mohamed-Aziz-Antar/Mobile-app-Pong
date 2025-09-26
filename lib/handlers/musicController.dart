import 'package:flame_audio/flame_audio.dart';

class MusicController {
  static bool _isPlaying = false;

  static void playMusic() {
    if (!_isPlaying) {
      FlameAudio.bgm.initialize();
      FlameAudio.bgm.play('background.mp3', volume: 0.5);
      _isPlaying = true;
    }
  }

  static void stopMusic() {
    FlameAudio.bgm.stop();
    _isPlaying = false;
  }
}
