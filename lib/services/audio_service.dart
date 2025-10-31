import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  static final AudioService instance = AudioService._init();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  
  AudioService._init() {
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    // TTS設定を初期化
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5); // 少しゆっくり読む
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> playWordAudio(String word) async {
    try {
      // 実際は5000語の音声ファイルを再生
      final audioFileName = 'audio/words/${word.toLowerCase()}.mp3';
      
      try {
        await _audioPlayer.play(AssetSource(audioFileName));
        print('Playing audio file for: $word');
      } catch (e) {
        print('Audio file not found for: $word, using TTS instead');
        // 音声ファイルがない場合、TTSで英語音声を再生
        await _playWordTts(word);
      }
    } catch (e) {
      print('Word audio unavailable for: $word, using TTS fallback');
      await _playWordTts(word);
    }
  }

  Future<void> _playWordTts(String word) async {
    try {
      print('Playing TTS for word: $word');
      await _flutterTts.speak(word);
    } catch (e) {
      print('TTS failed for: $word, using sound effect fallback');
      await _playWordEffect(word);
    }
  }

  Future<void> _playWordEffect(String word) async {
    // 単語の長さに応じて異なる効果音パターン
    try {
      print('Playing word effect for: $word (length: ${word.length})');
      
      if (word.length <= 4) {
        await SystemSound.play(SystemSoundType.click);
        await HapticFeedback.lightImpact();
      } else if (word.length <= 7) {
        await SystemSound.play(SystemSoundType.click);
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 150));
        await SystemSound.play(SystemSoundType.click);
        await HapticFeedback.lightImpact();
      } else {
        await SystemSound.play(SystemSoundType.click);
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 150));
        await SystemSound.play(SystemSoundType.click);
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 150));
        await SystemSound.play(SystemSoundType.click);
        await HapticFeedback.lightImpact();
      }
      
      print('Completed audio effect for: $word');
    } catch (e) {
      print('Error with audio effect: $e');
    }
  }

  Future<void> playTTS(String text) async {
    try {
      print('Playing TTS for text: $text');
      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS failed for: $text');
      await _playWordEffect(text);
    }
  }

  Future<void> playCorrectSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/correct.mp3'));
    } catch (e) {
      // 正解効果音のダミー実装
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 150));
      await SystemSound.play(SystemSoundType.click);
      print('Playing correct sound effect');
    }
  }

  Future<void> playIncorrectSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/incorrect.mp3'));
    } catch (e) {
      // 不正解効果音のダミー実装
      await HapticFeedback.heavyImpact();
      print('Playing incorrect sound effect');
    }
  }

  Future<void> playButtonSound() async {
    await SystemSound.play(SystemSoundType.click);
  }

  // new_req仕様の追加効果音
  Future<void> playSwipeSound() async {
    await SystemSound.play(SystemSoundType.click);
    print('Playing swipe sound effect');
  }

  Future<void> playCardStackSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/card_stack.mp3'));
    } catch (e) {
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 50));
      await SystemSound.play(SystemSoundType.click);
      print('Playing card stack sound effect');
    }
  }

  Future<void> playLevelUpSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/levelup.mp3'));
    } catch (e) {
      // レベルアップ効果音のダミー実装
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 100));
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 100));
      await SystemSound.play(SystemSoundType.click);
      print('Playing level up sound effect');
    }
  }

  Future<void> playCompletionSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/completion.mp3'));
    } catch (e) {
      // 完了効果音のダミー実装
      for (int i = 0; i < 5; i++) {
        await SystemSound.play(SystemSoundType.click);
        await Future.delayed(const Duration(milliseconds: 120));
      }
      print('Playing completion sound effect');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
  }
}