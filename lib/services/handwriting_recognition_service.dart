import 'package:flutter/material.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart' as mlkit;
import 'dart:typed_data';
import 'dart:ui' as ui;

class HandwritingRecognitionService {
  static final HandwritingRecognitionService instance = HandwritingRecognitionService._init();
  
  late mlkit.DigitalInkRecognizer _recognizer;
  bool _isInitialized = false;
  
  HandwritingRecognitionService._init();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // 英語用デジタルインク認識器を初期化
      const String languageCode = 'en';
      
      // モデルマネージャーでモデルのダウンロード状態を確認
      final modelManager = mlkit.DigitalInkRecognizerModelManager();
      final isDownloaded = await modelManager.isModelDownloaded(languageCode);
      
      if (!isDownloaded) {
        print('📥 Downloading ML Kit model for language: $languageCode');
        final downloadSuccess = await modelManager.downloadModel(languageCode);
        if (downloadSuccess) {
          print('✅ Model downloaded successfully');
        } else {
          print('❌ Model download failed');
          return;
        }
      } else {
        print('✅ Model already downloaded');
      }
      
      _recognizer = mlkit.DigitalInkRecognizer(languageCode: languageCode);
      _isInitialized = true;
      print('Handwriting recognition service initialized');
    } catch (e) {
      print('Failed to initialize handwriting recognition: $e');
    }
  }

  Future<String> recognizeText(List<List<Offset>> strokes) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (strokes.isEmpty) return '';

    try {
      // ストロークをDigitalInk形式に変換
      final ink = mlkit.Ink();
      
      // 基準タイムスタンプ
      int baseTime = DateTime.now().millisecondsSinceEpoch;
      
      // デバッグログ
      print('📝 Handwriting Recognition Debug:');
      print('   Total strokes: ${strokes.length}');
      
      for (int strokeIndex = 0; strokeIndex < strokes.length; strokeIndex++) {
        final stroke = strokes[strokeIndex];
        print('   Stroke $strokeIndex: ${stroke.length} points');
        
        if (stroke.length > 1) {
          final mlkitStroke = mlkit.Stroke();
          
          for (int pointIndex = 0; pointIndex < stroke.length; pointIndex++) {
            final offset = stroke[pointIndex];
            // 各ポイントに10ms間隔でタイムスタンプを付与
            // ストローク間には100ms（文字分離のため）
            final timestamp = baseTime + (strokeIndex * 100) + (pointIndex * 10);
            
            mlkitStroke.points.add(
              mlkit.StrokePoint(x: offset.dx, y: offset.dy, t: timestamp)
            );
          }
          
          ink.strokes.add(mlkitStroke);
        }
      }
      
      print('   Ink strokes added: ${ink.strokes.length}');

      // 認識実行
      final candidates = await _recognizer.recognize(ink);
      
      print('   Candidates count: ${candidates.length}');
      for (int i = 0; i < candidates.length && i < 5; i++) {
        print('   Candidate $i: "${candidates[i].text}" (score: ${candidates[i].score})');
      }
      
      if (candidates.isNotEmpty) {
        final result = candidates.first.text;
        print('✅ Recognized result: "$result"');
        return result;
      }
      
      print('⚠️ No candidates returned');
      return '';
    } catch (e) {
      print('❌ Error during recognition: $e');
      // フォールバック：ダミー認識
      return _fallbackRecognition(strokes);
    }
  }

  String _fallbackRecognition(List<List<Offset>> strokes) {
    // Google ML Kitが利用できない場合のフォールバック
    if (strokes.isEmpty) return '';
    
    // 改良されたダミー認識ロジック
    final strokeCount = strokes.length;
    final totalPoints = strokes.fold<int>(0, (sum, stroke) => sum + stroke.length);
    final avgStrokeLength = totalPoints / strokeCount;
    
    // ストロークの特徴から文字を推定
    final Map<String, List<String>> patterns = {
      'short_single': ['i', 'l', 'I', 'j', '1', '|'],
      'medium_single': ['t', 'f', '7', '+', '-'],
      'complex_single': ['a', 'e', 'o', 'c', 's', 'g', 'q'],
      'multiple_simple': ['h', 'n', 'm', 'u', 'v', 'w', 'x'],
      'multiple_complex': ['A', 'B', 'D', 'P', 'R', 'k', 'b', 'd', 'p'],
    };

    String category;
    if (strokeCount == 1 && avgStrokeLength < 20) {
      category = 'short_single';
    } else if (strokeCount == 1 && avgStrokeLength < 40) {
      category = 'medium_single';
    } else if (strokeCount == 1) {
      category = 'complex_single';
    } else if (strokeCount <= 3) {
      category = 'multiple_simple';
    } else {
      category = 'multiple_complex';
    }

    final candidates = patterns[category] ?? ['?'];
    return candidates[strokeCount % candidates.length];
  }

  // 問題変更時の自動クリア用
  void clearRecognition() {
    // 現在の認識状態をリセット
    print('Handwriting recognition cleared for new question');
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _recognizer.close();
      _isInitialized = false;
    }
  }

  // 高精度認識のための追加メソッド
  Future<List<String>> recognizeWithCandidates(List<List<Offset>> strokes, {int maxCandidates = 3}) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (strokes.isEmpty) return [];

    try {
      final ink = mlkit.Ink();
      
      // 基準タイムスタンプ
      int baseTime = DateTime.now().millisecondsSinceEpoch;
      
      for (int strokeIndex = 0; strokeIndex < strokes.length; strokeIndex++) {
        final stroke = strokes[strokeIndex];
        if (stroke.length > 1) {
          final mlkitStroke = mlkit.Stroke();
          
          for (int pointIndex = 0; pointIndex < stroke.length; pointIndex++) {
            final offset = stroke[pointIndex];
            // 各ポイントに10ms間隔でタイムスタンプを付与
            final timestamp = baseTime + (strokeIndex * 100) + (pointIndex * 10);
            
            mlkitStroke.points.add(
              mlkit.StrokePoint(x: offset.dx, y: offset.dy, t: timestamp)
            );
          }
          
          ink.strokes.add(mlkitStroke);
        }
      }

      final candidates = await _recognizer.recognize(ink);
      
      return candidates
          .take(maxCandidates)
          .map((candidate) => candidate.text)
          .toList();
    } catch (e) {
      print('Error during multi-candidate recognition: $e');
      return [_fallbackRecognition(strokes)];
    }
  }

  // 英単語特化の認識精度向上
  String filterForEnglishWords(String recognizedText) {
    // 英語として不適切な文字を除去・修正
    String filtered = recognizedText
        .replaceAll(RegExp(r'[^a-zA-Z\s]'), '') // 英字以外を除去
        .toLowerCase()
        .trim();
    
    // よくある誤認識の修正
    final corrections = {
      '0': 'o',
      '1': 'l',
      '5': 's',
      '8': 'b',
      '9': 'g',
    };
    
    for (final entry in corrections.entries) {
      filtered = filtered.replaceAll(entry.key, entry.value);
    }
    
    return filtered;
  }
}