import 'package:flutter/material.dart';
import '../models/word.dart';
import '../widgets/handwriting_input.dart';
import '../theme/app_colors.dart';

class CheckTimeScreen extends StatefulWidget {
  final String stageId;
  final List<Word> words;

  const CheckTimeScreen({
    super.key,
    required this.stageId,
    required this.words,
  });

  @override
  State<CheckTimeScreen> createState() => _CheckTimeScreenState();
}

class _CheckTimeScreenState extends State<CheckTimeScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  final TextEditingController _controller = TextEditingController();
  String? feedbackMessage;
  Color? feedbackColor;
  List<bool> results = [];
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool isHandwritingMode = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    if (_controller.text.isEmpty) return;

    final currentWord = widget.words[currentIndex];
    final isCorrect = _controller.text.toLowerCase() == 
                      currentWord.english.toLowerCase();

    setState(() {
      results.add(isCorrect);
      feedbackMessage = isCorrect ? 'せいかい！' : 'ざんねん: ${currentWord.english}';
      feedbackColor = isCorrect ? Colors.green : Colors.red;
    });

    if (!isCorrect) {
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          if (currentIndex < widget.words.length - 1) {
            currentIndex++;
            _controller.clear();
            feedbackMessage = null;
            feedbackColor = null;
          } else {
            _navigateToStageTest();
          }
        });
      }
    });
  }

  void _navigateToStageTest() {
    Navigator.pushReplacementNamed(
      context,
      '/interest-input',
      arguments: {
        'stageId': widget.stageId,
        'checkTimeResults': results,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= widget.words.length) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentWord = widget.words[currentIndex];
    final progress = (currentIndex + 1) / widget.words.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('チェックタイム'),
        backgroundColor: Colors.orange.shade400,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  isHandwritingMode = !isHandwritingMode;
                });
              },
              icon: Icon(
                isHandwritingMode ? Icons.keyboard : Icons.draw,
                color: Colors.white,
              ),
              label: Text(
                isHandwritingMode ? 'キーボード' : 'てがき',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Column(
          children: [
            _buildProgressBar(progress),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: _buildQuestionCard(currentWord),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            isHandwritingMode 
                ? _buildHandwritingInput() 
                : _buildKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'もんだい ${currentIndex + 1} / ${widget.words.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Word word) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              word.partOfSpeech,
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            word.japanese,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'えいごでなんていう？',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),
          _buildInputField(word),
          if (feedbackMessage != null) ...[
            const SizedBox(height: 20),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: feedbackColor?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: feedbackColor ?? Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    feedbackColor == Colors.green 
                        ? Icons.check_circle 
                        : Icons.cancel,
                    color: feedbackColor,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    feedbackMessage!,
                    style: TextStyle(
                      color: feedbackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField(Word word) {
    final letterCount = word.english.length;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(letterCount, (index) {
            final hasLetter = _controller.text.length > index;
            return Container(
              width: 42,
              height: 52,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: hasLetter ? Colors.orange.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasLetter ? Colors.orange : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  hasLetter ? _controller.text[index].toUpperCase() : '',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Text(
          '${letterCount}もじ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHandwritingInput() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 認識された文字を表示
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.orange.shade300,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'にんしきされた文字',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _controller.text.isEmpty ? '---' : _controller.text.toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _controller.text.isEmpty ? Colors.grey.shade400 : Colors.black87,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
              HandwritingInput(
                onTextChanged: (text) {
                  setState(() {
                    _controller.text = text;
                  });
                },
                onClear: () {
                  setState(() {
                    _controller.clear();
                  });
                },
              ),
              const SizedBox(height: 15),
              // 説明テキスト
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'アルファベットを1文字ずつ書いてね',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'けってい',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    final keys = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...keys.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((key) => _buildKey(key, index)).toList(),
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSpecialKey('⌫', () {
                    if (_controller.text.isNotEmpty) {
                      setState(() {
                        _controller.text = _controller.text
                            .substring(0, _controller.text.length - 1);
                      });
                    }
                  }),
                  const SizedBox(width: 8),
                  _buildSpecialKey('けってい', _checkAnswer, width: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String letter, int rowIndex) {
    // Calculate key width based on screen width and row
    final screenWidth = MediaQuery.of(context).size.width;
    final keysInRow = rowIndex == 0 ? 10 : (rowIndex == 1 ? 9 : 7);
    final totalPadding = 40.0; // Container padding + margins
    final keySpacing = 2.0; // Spacing between keys
    final availableWidth = screenWidth - totalPadding - (keySpacing * keysInRow * 2);
    final keyWidth = (availableWidth / keysInRow).clamp(25.0, 38.0);
    
    return Flexible(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _controller.text += letter.toLowerCase();
          });
        },
        child: Container(
          width: keyWidth,
          height: 48,
          margin: EdgeInsets.symmetric(horizontal: keySpacing),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade400,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: keyWidth < 30 ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String label, VoidCallback onTap, {double width = 60}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: label == 'けってい' ? Colors.orange : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: label == 'けってい' ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: label == 'けってい' ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}