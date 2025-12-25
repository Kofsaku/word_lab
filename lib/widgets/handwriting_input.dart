import 'package:flutter/material.dart';
import 'dart:async';
import '../services/handwriting_recognition_service.dart';

class HandwritingInput extends StatefulWidget {
  final Function(String) onTextChanged;
  final VoidCallback onClear;
  final VoidCallback? onSwitchToKeyboard;
  final String? currentQuestion; // 問題変更検知用

  const HandwritingInput({
    super.key,
    required this.onTextChanged,
    required this.onClear,
    this.onSwitchToKeyboard,
    this.currentQuestion,
  });

  @override
  State<HandwritingInput> createState() => _HandwritingInputState();
}

class _HandwritingInputState extends State<HandwritingInput> {
  List<List<Offset>> strokes = [];
  List<Offset> currentStroke = [];
  
  double penWidth = 3.0;
  Color penColor = Colors.black87;
  String recognizedText = '';
  String? previousQuestion;
  Timer? _recognitionTimer;
  bool _isRecognizing = false;
  
  final HandwritingRecognitionService _recognitionService = 
      HandwritingRecognitionService.instance;

  @override
  void initState() {
    super.initState();
    _recognitionService.initialize();
    previousQuestion = widget.currentQuestion;
  }

  @override
  void didUpdateWidget(HandwritingInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 問題が変更された場合、自動的にクリア
    if (widget.currentQuestion != previousQuestion) {
      _autoClearForNewQuestion();
      previousQuestion = widget.currentQuestion;
    }
  }

  void _autoClearForNewQuestion() {
    setState(() {
      strokes.clear();
      currentStroke.clear();
      recognizedText = '';
      _isRecognizing = false;
    });
    _recognitionTimer?.cancel();
    _recognitionService.clearRecognition();
    widget.onTextChanged('');
    print('🔄 Auto-cleared handwriting for new question');
  }

  void _startStroke(Offset point) {
    setState(() {
      currentStroke = [point];
    });
  }

  void _updateStroke(Offset point) {
    setState(() {
      currentStroke.add(point);
    });
  }

  void _endStroke() {
    if (currentStroke.isNotEmpty) {
      setState(() {
        strokes.add(List.from(currentStroke));
        currentStroke = [];
      });
      _scheduleRecognition();
    }
  }

  void _scheduleRecognition() {
    // 認識処理のデバウンス（連続する手書きをまとめて処理）
    _recognitionTimer?.cancel();
    _recognitionTimer = Timer(const Duration(milliseconds: 500), () {
      _performRecognition();
    });
  }

  Future<void> _performRecognition() async {
    if (strokes.isEmpty || _isRecognizing) return;

    setState(() => _isRecognizing = true);

    try {
      // Google ML Kit手書き認識を実行
      final result = await _recognitionService.recognizeText(strokes);
      final filteredResult = _recognitionService.filterForEnglishWords(result);
      
      setState(() {
        recognizedText = filteredResult;
        _isRecognizing = false;
      });
      
      widget.onTextChanged(recognizedText);
      print('✅ Recognized: "$filteredResult"');
      
    } catch (e) {
      setState(() => _isRecognizing = false);
      print('❌ Recognition failed: $e');
    }
  }

  void _clear() {
    setState(() {
      strokes.clear();
      currentStroke.clear();
      recognizedText = '';
      _isRecognizing = false;
    });
    _recognitionTimer?.cancel();
    widget.onTextChanged('');
    widget.onClear();
  }

  void _undo() {
    if (strokes.isNotEmpty) {
      setState(() {
        strokes.removeLast();
        recognizedText = ''; // 認識結果もリセット
      });
      
      // ストロークが残っている場合は再認識、空の場合は空文字を通知
      if (strokes.isNotEmpty) {
        _scheduleRecognition();
      } else {
        widget.onTextChanged('');
      }
    }
  }

  @override
  void dispose() {
    _recognitionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 手書きエリア
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.blue.shade300,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Stack(
                children: [
                  // グリッド線
                  CustomPaint(
                    size: Size.infinite,
                    painter: GridPainter(),
                  ),
                  // 手書き入力エリア
                  GestureDetector(
                    onPanStart: (details) {
                      _startStroke(details.localPosition);
                    },
                    onPanUpdate: (details) {
                      _updateStroke(details.localPosition);
                    },
                    onPanEnd: (_) {
                      _endStroke();
                    },
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: HandwritingPainter(
                        strokes: strokes,
                        currentStroke: currentStroke,
                        penWidth: penWidth,
                        penColor: penColor,
                      ),
                    ),
                  ),
                  // ヒントテキスト
                  if (strokes.isEmpty && currentStroke.isEmpty)
                    Center(
                      child: Text(
                        'ここに英語を書いてね',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  // 認識中インジケーター
                  if (_isRecognizing)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 6),
                            Text(
                              '認識中',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        
        const SizedBox(height: 8),
        
        // 操作ボタン（キーボード + 1画消去 + 全消去）
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // キーボードボタン（テキスト付き）
            if (widget.onSwitchToKeyboard != null)
              _buildTextButton(
                icon: Icons.keyboard,
                label: 'キーボード',
                color: Colors.blue,
                onPressed: widget.onSwitchToKeyboard!,
              ),
            if (widget.onSwitchToKeyboard != null)
              const SizedBox(width: 12),
            // 1画消去（アイコンのみ）
            _buildIconButton(
              icon: Icons.undo,
              color: Colors.orange,
              onPressed: _undo,
              tooltip: '1画消去',
            ),
            const SizedBox(width: 8),
            // 全消去（アイコンのみ）
            _buildIconButton(
              icon: Icons.delete_outline,
              color: Colors.red,
              onPressed: _clear,
              tooltip: '全消去',
            ),
          ],
        ),
      ],
    );
  }

  // テキスト付きボタン
  Widget _buildTextButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
    );
  }

  // アイコンのみボタン
  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 22, color: color),
          ),
        ),
      ),
    );
  }
}

class HandwritingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final double penWidth;
  final Color penColor;

  HandwritingPainter({
    required this.strokes,
    required this.currentStroke,
    this.penWidth = 3.0,
    this.penColor = Colors.black87,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = penColor
      ..strokeWidth = penWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // 保存済みのストロークを描画
    for (final stroke in strokes) {
      if (stroke.length > 1) {
        final path = Path();
        path.moveTo(stroke[0].dx, stroke[0].dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      } else if (stroke.length == 1) {
        canvas.drawCircle(stroke[0], penWidth/2, paint);
      }
    }

    // 現在のストロークを描画
    if (currentStroke.length > 1) {
      final path = Path();
      path.moveTo(currentStroke[0].dx, currentStroke[0].dy);
      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }
      canvas.drawPath(path, paint);
    } else if (currentStroke.length == 1) {
      canvas.drawCircle(currentStroke[0], penWidth/2, paint);
    }
  }

  @override
  bool shouldRepaint(HandwritingPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
           oldDelegate.currentStroke != currentStroke ||
           oldDelegate.penWidth != penWidth ||
           oldDelegate.penColor != penColor;
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;

    // 横線（英語書字用の4線）
    final horizontalSpacing = size.height / 4;
    for (int i = 1; i < 4; i++) {
      final lineOpacity = i == 2 ? 0.8 : 0.3; // 中央線を強調
      canvas.drawLine(
        Offset(0, horizontalSpacing * i),
        Offset(size.width, horizontalSpacing * i),
        paint..color = Colors.grey.shade300.withOpacity(lineOpacity),
      );
    }

    // 縦線（文字分離用）
    final verticalSpacing = size.width / 6; // 6文字分
    for (int i = 1; i < 6; i++) {
      canvas.drawLine(
        Offset(verticalSpacing * i, 0),
        Offset(verticalSpacing * i, size.height),
        paint..color = Colors.grey.shade200.withOpacity(0.5),
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}