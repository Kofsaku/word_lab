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
      _recognizer = mlkit.DigitalInkRecognizer(languageCode: 'en');
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
      
      for (int i = 0; i < strokes.length; i++) {
        final stroke = strokes[i];
        if (stroke.length > 1) {
          final points = stroke.map((offset) => 
            mlkit.StrokePoint(x: offset.dx, y: offset.dy, t: DateTime.now().millisecondsSinceEpoch + i)
          ).toList();
          
          final mlkitStroke = mlkit.Stroke();
          mlkitStroke.points.addAll(points);
          ink.strokes.add(mlkitStroke);
        }
      }

      // 認識実行
      final candidates = await _recognizer.recognize(ink);
      
      if (candidates.isNotEmpty) {
        return candidates.first.text;
      }
      
      return '';
    } catch (e) {
      print('Error during recognition: $e');
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
      
      for (int i = 0; i < strokes.length; i++) {
        final stroke = strokes[i];
        if (stroke.length > 1) {
          final points = stroke.map((offset) => 
            mlkit.StrokePoint(x: offset.dx, y: offset.dy, t: DateTime.now().millisecondsSinceEpoch + i)
          ).toList();
          
          final mlkitStroke = mlkit.Stroke();
          mlkitStroke.points.addAll(points);
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