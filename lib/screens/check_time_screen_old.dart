import 'package:flutter/material.dart';
import 'dart:math';
import '../models/word.dart';
import '../widgets/handwriting_input.dart';
import '../services/audio_service.dart';
import '../services/database_helper.dart';

enum TestType { multipleChoice, listening, spelling }

class CheckTimeScreenV2 extends StatefulWidget {
  final String stageId;
  final List<Word> words;

  const CheckTimeScreenV2({
    super.key,
    required this.stageId,
    required this.words,
  });

  @override
  State<CheckTimeScreenV2> createState() => _CheckTimeScreenV2State();
}

class _CheckTimeScreenV2State extends State<CheckTimeScreenV2>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  final TextEditingController _controller = TextEditingController();
  String? feedbackMessage;
  Color? feedbackColor;
  List<bool> results = [];
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool isHandwritingMode = false;
  final AudioService _audioService = AudioService.instance;
  
  late List<TestType> testSequence;
  int? selectedChoiceIndex;
  List<String> currentChoices = [];
  bool hasPlayedListeningAudio = false;

  @override
  void initState() {
    super.initState();
    _generateTestSequence();
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
    
    if (testSequence[0] == TestType.multipleChoice) {
      _generateMultipleChoices();
    }
  }

  void _generateTestSequence() {
    testSequence = [];
    // 前半6問：意味選択問題（英単語→日本語訳）
    for (int i = 0; i < 6 && i < widget.words.length; i++) {
      testSequence.add(TestType.multipleChoice);
    }
    // 後半6問：スペリング入力（日本語→英単語入力）
    for (int i = 0; i < 6 && i < widget.words.length; i++) {
      testSequence.add(TestType.spelling);
    }
  }

  void _generateMultipleChoices() {
    final currentWord = widget.words[currentIndex];
    final allWords = widget.words.toList();
    allWords.shuffle();
    
    currentChoices = [currentWord.japanese];
    
    for (final word in allWords) {
      if (word.japanese != currentWord.japanese && currentChoices.length < 4) {
        currentChoices.add(word.japanese);
      }
    }
    
    while (currentChoices.length < 4) {
      final dummyOptions = ['読む', '書く', '見る', '聞く', '話す', '歩く', '走る', '食べる'];
      for (final option in dummyOptions) {
        if (!currentChoices.contains(option) && currentChoices.length < 4) {
          currentChoices.add(option);
        }
      }
    }
    
    currentChoices.shuffle();
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final currentWord = widget.words[currentIndex];
    final testType = testSequence[currentIndex];
    bool isCorrect = false;

    // リスニングテストの場合は常に正解扱いにして次に進む（ダミーデータのため）
    if (testType == TestType.listening) {
      isCorrect = true;  // 常に正解扱い
    } else if (testType == TestType.multipleChoice) {
      if (selectedChoiceIndex != null) {
        isCorrect = currentChoices[selectedChoiceIndex!] == currentWord.japanese;
      }
    } else {
      if (_controller.text.isNotEmpty) {
        isCorrect = _controller.text.toLowerCase() == 
                    currentWord.english.toLowerCase();
      }
    }

    if (isCorrect) {
      _audioService.playCorrectSound();
    } else {
      _audioService.playIncorrectSound();
    }

    setState(() {
      results.add(isCorrect);
      if (testType == TestType.multipleChoice) {
        feedbackMessage = isCorrect ? 'せいかい！' : 'ざんねん: ${currentWord.japanese}';
      } else {
        feedbackMessage = isCorrect ? 'せいかい！' : 'ざんねん: ${currentWord.english}';
      }
      feedbackColor = isCorrect ? Colors.green : Colors.red;
    });

    _updateWordProgress(currentWord, isCorrect);

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
            selectedChoiceIndex = null;
            hasPlayedListeningAudio = false;
            
            if (testSequence[currentIndex] == TestType.multipleChoice) {
              _generateMultipleChoices();
            }
          } else {
            _navigateToStageTest();
          }
        });
      }
    });
  }

  Future<void> _updateWordProgress(Word word, bool isCorrect) async {
    await DatabaseHelper.instance.updateWordProgressAfterAnswer(
      'default_user',
      int.parse(word.id),
      isCorrect,
    );
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
    final testType = testSequence[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTestTypeTitle(testType)),
        backgroundColor: _getTestTypeColor(testType),
        elevation: 0,
        actions: testType == TestType.spelling
            ? [
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
              ]
            : null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getTestTypeColor(testType),
              _getTestTypeColor(testType).withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildProgressBar(progress, testType),
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
                          child: _buildQuestionCard(currentWord, testType),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            if (testType == TestType.spelling)
              isHandwritingMode 
                  ? _buildHandwritingInput() 
                  : _buildKeyboard()
            else if (testType == TestType.multipleChoice)
              _buildMultipleChoiceButtons()
            else if (testType == TestType.listening)
              _buildListeningInput(),
          ],
        ),
      ),
    );
  }

  String _getTestTypeTitle(TestType type) {
    switch (type) {
      case TestType.multipleChoice:
        return '意味を選ぼう';
      case TestType.listening:
        return 'リスニング';
      case TestType.spelling:
        return 'スペリング';
    }
  }

  Color _getTestTypeColor(TestType type) {
    switch (type) {
      case TestType.multipleChoice:
        return Colors.blue.shade400;
      case TestType.listening:
        return Colors.purple.shade400;
      case TestType.spelling:
        return Colors.orange.shade400;
    }
  }

  Widget _buildProgressBar(double progress, TestType testType) {
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

  Widget _buildQuestionCard(Word word, TestType testType) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _getTestTypeColor(testType).withOpacity(0.2),
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
              color: _getTestTypeColor(testType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              word.partOfSpeech,
              style: TextStyle(
                color: _getTestTypeColor(testType),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          if (testType == TestType.multipleChoice) ...[
            Text(
              word.english,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '日本語の意味は？',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ] else if (testType == TestType.listening) ...[
            IconButton(
              icon: Icon(
                Icons.volume_up,
                size: 60,
                color: _getTestTypeColor(testType),
              ),
              onPressed: () {
                _audioService.playWordAudio(word.english);
                setState(() {
                  hasPlayedListeningAudio = true;
                });
              },
            ),
            const SizedBox(height: 10),
            Text(
              hasPlayedListeningAudio ? '聞こえた単語を入力してね' : 'タップして音声を聞こう',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ] else if (testType == TestType.spelling) ...[
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
          ],
          const SizedBox(height: 40),
          if (testType != TestType.multipleChoice)
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

  Widget _buildMultipleChoiceButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          for (int i = 0; i < currentChoices.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  Expanded(
                    child: _buildChoiceButton(i, currentChoices[i]),
                  ),
                  const SizedBox(width: 15),
                  if (i + 1 < currentChoices.length)
                    Expanded(
                      child: _buildChoiceButton(i + 1, currentChoices[i + 1]),
                    )
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: Text(
                'けってい',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: selectedChoiceIndex != null ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(int index, String text) {
    final isSelected = selectedChoiceIndex == index;
    return GestureDetector(
      onTap: feedbackMessage == null
          ? () {
              setState(() {
                selectedChoiceIndex = index;
              });
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListeningInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '聞こえた単語を入力',
                filled: true,
                fillColor: Colors.purple.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.edit,
                  color: Colors.purple.shade400,
                ),
              ),
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
              enabled: hasPlayedListeningAudio,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'けってい',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: hasPlayedListeningAudio && _controller.text.isNotEmpty
                        ? Colors.white
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
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
                color: hasLetter 
                    ? _getTestTypeColor(testSequence[currentIndex]).withOpacity(0.1) 
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasLetter 
                      ? _getTestTypeColor(testSequence[currentIndex]) 
                      : Colors.grey.shade300,
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
    final testType = testSequence[currentIndex];
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: _getTestTypeColor(testType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _getTestTypeColor(testType).withOpacity(0.3),
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
                    backgroundColor: _getTestTypeColor(testType),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final keysInRow = rowIndex == 0 ? 10 : (rowIndex == 1 ? 9 : 7);
    final totalPadding = 40.0;
    final keySpacing = 2.0;
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
    final testType = testSequence[currentIndex];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: label == 'けってい' ? _getTestTypeColor(testType) : Colors.grey.shade300,
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