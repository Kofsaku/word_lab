import 'package:flutter/material.dart';

class HandwritingInput extends StatefulWidget {
  final Function(String) onTextChanged;
  final VoidCallback onClear;
  final VoidCallback? onSwitchToKeyboard;

  const HandwritingInput({
    super.key,
    required this.onTextChanged,
    required this.onClear,
    this.onSwitchToKeyboard,
  });

  @override
  State<HandwritingInput> createState() => _HandwritingInputState();
}

class _HandwritingInputState extends State<HandwritingInput> {
  List<List<Offset>> strokes = [];
  List<Offset> currentStroke = [];
  
  // new_req仕様：ペン機能の強化
  double penWidth = 3.0;
  Color penColor = Colors.black87;
  String recognizedText = '';

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
      // 簡易的な文字認識のシミュレーション
      _simulateCharacterRecognition();
    }
  }

  void _clear() {
    setState(() {
      strokes.clear();
      currentStroke.clear();
      recognizedText = '';
    });
    widget.onTextChanged('');
    widget.onClear();
  }

  void _undo() {
    if (strokes.isNotEmpty) {
      setState(() {
        strokes.removeLast();
      });
      _simulateCharacterRecognition();
    }
  }

  void _simulateCharacterRecognition() {
    // new_req仕様：Google ML Kit風の手書き認識シミュレーション
    if (strokes.isEmpty) {
      recognizedText = '';
      widget.onTextChanged('');
      return;
    }
    
    // ダミー認識ロジック（実際はGoogle ML Kit使用）
    final Map<int, List<String>> strokePatterns = {
      1: ['i', 'l', 'I', 'j', '1'],
      2: ['t', 'f', 'x', 'v', '7'],
      3: ['a', 'h', 'k', 'n', 'r', 'd', 'b', 'p'],
      4: ['e', 'm', 'w', 'A', 'H', 'M', 'W'],
      5: ['s', 'g', 'S', 'G', '5', '8'],
      6: ['o', 'O', '0', '6', '9'],
    };
    
    // 認識処理のシミュレーション
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final strokeCount = strokes.length;
        final letters = strokePatterns[strokeCount.clamp(1, 6)] ?? ['?'];
        final newChar = letters[strokeCount % letters.length];
        
        setState(() {
          recognizedText += newChar;
        });
        
        widget.onTextChanged(recognizedText);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.orange.shade300,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Stack(
              children: [
                // グリッド線
                CustomPaint(
                  size: const Size(double.infinity, 220),
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
                    size: const Size(double.infinity, 220),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.draw,
                          size: 40,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'ここに文字を書いてね',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 認識結果表示
        if (recognizedText.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.text_fields, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '認識結果: ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Expanded(
                  child: Text(
                    recognizedText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 16),
        // ペン設定
        _buildPenControls(),
        const SizedBox(height: 16),
        
        // 操作ボタン
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: _buildControlButton(
                icon: Icons.undo,
                label: 'もどす',
                color: Colors.grey,
                onPressed: _undo,
              ),
            ),
            Flexible(
              child: _buildControlButton(
                icon: Icons.clear_all,
                label: 'クリア',
                color: Colors.red,
                onPressed: _clear,
              ),
            ),
            if (widget.onSwitchToKeyboard != null)
              Flexible(
                child: _buildControlButton(
                  icon: Icons.keyboard,
                  label: 'キーボード',
                  color: Colors.green,
                  onPressed: widget.onSwitchToKeyboard!,
                ),
              ),
          ],
        ),
      ],
      ),
    );
  }

  Widget _buildPenControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ペン設定',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          // ペン太さ調整
          Row(
            children: [
              const Icon(Icons.line_weight, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              const Text('太さ: '),
              Expanded(
                child: Slider(
                  value: penWidth,
                  min: 1.0,
                  max: 8.0,
                  divisions: 7,
                  onChanged: (value) {
                    setState(() => penWidth = value);
                  },
                ),
              ),
              Text(
                penWidth.toInt().toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          
          // ペン色選択
          Row(
            children: [
              const Icon(Icons.palette, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              const Text('色: '),
              const SizedBox(width: 12),
              ...Colors.accents.take(5).map((color) {
                final isSelected = penColor == color;
                return GestureDetector(
                  onTap: () => setState(() => penColor = color),
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected 
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: color, width: 2),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
        canvas.drawCircle(stroke[0], 2, paint);
      }
    }

    // 現在のストロークを描画
    if (currentStroke.length > 1) {
      final path = Path();
      path.moveTo(currentStroke[0].dx, currentStroke[0].dy);
      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }
      canvas.drawPath(path, paint..color = penColor);
    } else if (currentStroke.length == 1) {
      canvas.drawCircle(currentStroke[0], penWidth/2, paint..color = penColor);
    }
  }

  @override
  bool shouldRepaint(HandwritingPainter oldDelegate) {
    return true;
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;

    // 横線
    final horizontalSpacing = size.height / 4;
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(0, horizontalSpacing * i),
        Offset(size.width, horizontalSpacing * i),
        paint,
      );
    }

    // 中央の縦線
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint..color = Colors.grey.shade300,
    );
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}