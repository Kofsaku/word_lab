import 'package:flutter/material.dart';
import '../models/word.dart';
import '../widgets/handwriting_input.dart';
import '../widgets/recognition_candidates.dart';
import '../services/audio_service.dart';
import '../services/handwriting_recognition_service.dart';
import '../theme/app_colors.dart';

enum AnswerConfidence { confident, uncertain }
enum QuestionType { englishToJapanese, japaneseToEnglish }

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
  final TextEditingController _textController = TextEditingController();
  List<Map<String, dynamic>> results = [];
  
  // new_req仕様のフィールド
  late List<Map<String, dynamic>> questions;
  QuestionType get currentQuestionType => questions[currentIndex]['type'];
  bool isHandwritingMode = false;
  AnswerConfidence? selectedConfidence;
  int? selectedChoiceIndex;
  String feedbackMessage = '';
  Color? feedbackColor;
  bool showFeedback = false;
  late AnimationController _feedbackController;
  final AudioService _audioService = AudioService.instance;
  final HandwritingRecognitionService _recognitionService = 
      HandwritingRecognitionService.instance;
  
  // リアルタイム認識用
  List<String> recognitionCandidates = [];
  String? selectedCandidate;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
    _initializeAnimations();
    if (currentQuestionType == QuestionType.englishToJapanese) {
      _playQuestionAudio();
    }
  }

  void _initializeAnimations() {
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  void _generateQuestions() {
    questions = [];
    
    // 英→日（6問）
    for (int i = 0; i < widget.words.length; i++) {
      questions.add({
        'type': QuestionType.englishToJapanese,
        'word': widget.words[i],
        'choices': _generateChoices(widget.words[i], true),
        'correctAnswer': widget.words[i].japanese,
      });
    }
    
    // 日→英（6問）
    for (int i = 0; i < widget.words.length; i++) {
      questions.add({
        'type': QuestionType.japaneseToEnglish,
        'word': widget.words[i],
        'correctAnswer': widget.words[i].english,
      });
    }
  }

  List<String> _generateChoices(Word correctWord, bool isJapanese) {
    final choices = <String>[
      isJapanese ? correctWord.japanese : correctWord.english
    ];
    
    // ダミー選択肢を追加（実際は類似単語から生成）
    final dummyChoices = isJapanese 
        ? ['間違い1', '間違い2', '間違い3']
        : ['wrong1', 'wrong2', 'wrong3'];
    
    choices.addAll(dummyChoices);
    choices.shuffle();
    
    return choices;
  }

  void _playQuestionAudio() {
    final currentQuestion = questions[currentIndex];
    if (currentQuestion['type'] == QuestionType.englishToJapanese) {
      _audioService.playWordAudio(currentQuestion['word'].english);
    }
  }

  void _handleAnswer() {
    if (selectedConfidence == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('自信度を選択してください')),
      );
      return;
    }

    final question = questions[currentIndex];
    bool isCorrect = false;
    String userAnswer = '';

    if (currentQuestionType == QuestionType.englishToJapanese) {
      if (selectedChoiceIndex != null) {
        userAnswer = question['choices'][selectedChoiceIndex!];
        isCorrect = userAnswer == question['correctAnswer'];
      }
    } else {
      userAnswer = _textController.text.trim().toLowerCase();
      isCorrect = userAnswer == question['correctAnswer'].toLowerCase();
    }

    // 音声再生（答え合わせ時）
    if (currentQuestionType == QuestionType.japaneseToEnglish) {
      _audioService.playWordAudio(question['word'].english);
    }

    // 結果を保存
    results.add({
      'word': question['word'],
      'isCorrect': isCorrect,
      'confidence': selectedConfidence,
      'userAnswer': userAnswer,
      'questionType': currentQuestionType,
    });

    // フィードバック表示
    _showAnswerFeedback(isCorrect);
  }

  void _showAnswerFeedback(bool isCorrect) {
    setState(() {
      feedbackMessage = isCorrect ? '正解！' : '不正解...';
      feedbackColor = isCorrect ? AppColors.correct : AppColors.incorrect;
      showFeedback = true;
    });

    _feedbackController.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        _moveToNext();
      });
    });
  }

  void _moveToNext() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedConfidence = null;
        selectedChoiceIndex = null;
        _textController.clear();
        showFeedback = false;
        
        // リアルタイム認識状態もリセット
        recognitionCandidates = [];
        selectedCandidate = null;
      });
      _feedbackController.reset();
      
      // 手書き認識サービスのクリア
      _recognitionService.clearRecognition();
      
      if (currentQuestionType == QuestionType.englishToJapanese) {
        _playQuestionAudio();
      }
    } else {
      _navigateToInterestInput();
    }
  }

  void _navigateToInterestInput() {
    Navigator.pushReplacementNamed(
      context,
      '/interest-input',
      arguments: {
        'stageId': widget.stageId,
        'checkTimeResults': results,
      },
    );
  }

  void _handleGiveUp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('降参しますか？'),
        content: const Text('この問題をスキップして次に進みます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 不正解として処理
              results.add({
                'word': questions[currentIndex]['word'],
                'isCorrect': false,
                'confidence': AnswerConfidence.uncertain,
                'userAnswer': '',
                'questionType': currentQuestionType,
              });
              _moveToNext();
            },
            child: const Text('降参する'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildQuestionArea()),
              _buildConfidenceButtons(),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 28),
          ),
          const Spacer(),
          Column(
            children: [
              const Text(
                'チェックタイム',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${currentIndex + 1}/${questions.length}問',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildQuestionArea() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildQuestionTypeIndicator(),
                const SizedBox(height: 30),
                _buildQuestionContent(),
                const SizedBox(height: 40),
                _buildAnswerSection(),
              ],
            ),
          ),
          if (showFeedback) _buildFeedbackOverlay(),
        ],
      ),
    );
  }

  Widget _buildQuestionTypeIndicator() {
    final isEngToJap = currentQuestionType == QuestionType.englishToJapanese;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isEngToJap ? Colors.blue.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isEngToJap ? '英語 → 日本語' : '日本語 → 英語',
        style: TextStyle(
          color: isEngToJap ? Colors.blue.shade700 : Colors.green.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    final question = questions[currentIndex];
    final word = question['word'] as Word;
    
    if (currentQuestionType == QuestionType.englishToJapanese) {
      return Column(
        children: [
          const Icon(Icons.volume_up, color: Colors.blue, size: 32),
          const SizedBox(height: 16),
          Text(
            word.english,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            word.partOfSpeech,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Text(
            word.japanese,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            word.partOfSpeech,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildAnswerSection() {
    if (currentQuestionType == QuestionType.englishToJapanese) {
      return _buildChoiceButtons();
    } else {
      return _buildInputSection();
    }
  }

  Widget _buildChoiceButtons() {
    final question = questions[currentIndex];
    final choices = question['choices'] as List<String>;
    
    return Column(
      children: List.generate(choices.length, (index) {
        final isSelected = selectedChoiceIndex == index;
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton(
            onPressed: showFeedback ? null : () {
              setState(() => selectedChoiceIndex = index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected 
                  ? Colors.blue.shade400 
                  : Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              choices[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInputSection() {
    return Column(
      children: [
        _buildCardBox(),
        const SizedBox(height: 20),
        if (isHandwritingMode) 
          _buildHandwritingArea()
        else
          _buildKeyboardInput(),
        
        // 認識候補表示（手書きモード時のみ）
        if (isHandwritingMode && recognitionCandidates.isNotEmpty)
          RecognitionCandidates(
            candidates: recognitionCandidates,
            selectedText: selectedCandidate,
            onCandidateSelected: (candidate) {
              setState(() {
                selectedCandidate = candidate;
                _textController.text = candidate;
              });
            },
          ),
        
        const SizedBox(height: 16),
        _buildInputModeToggle(),
      ],
    );
  }

  Widget _buildCardBox() {
    final word = questions[currentIndex]['word'] as Word;
    final targetLength = word.english.length;
    final currentText = _textController.text;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 40; // パディング分を除く
        final boxCount = targetLength;
        final totalMargin = (boxCount - 1) * 4; // 2 * 2 (左右マージン)
        final maxBoxWidth = (availableWidth - totalMargin) / boxCount;
        final boxWidth = maxBoxWidth.clamp(20.0, 40.0); // 最小20px、最大40px
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(targetLength, (index) {
            final hasChar = index < currentText.length;
            return Container(
              width: boxWidth,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: hasChar ? Colors.blue.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasChar ? Colors.blue.shade300 : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  hasChar ? currentText[index].toUpperCase() : '',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHandwritingArea() {
    return SizedBox(
      height: 200,
      child: HandwritingInput(
        currentQuestion: 'question_${currentIndex}', // 問題変更検知用
        onTextChanged: (text) async {
          setState(() {
            _textController.text = text;
          });
          
          // リアルタイム認識候補の取得
          if (text.isNotEmpty) {
            try {
              final candidates = await _recognitionService.recognizeWithCandidates(
                [], // 実際のストロークデータが必要
                maxCandidates: 3,
              );
              setState(() {
                recognitionCandidates = candidates;
              });
            } catch (e) {
              print('Recognition candidates error: $e');
            }
          } else {
            setState(() {
              recognitionCandidates = [];
            });
          }
        },
        onClear: () {
          setState(() {
            _textController.clear();
          });
        },
        onSwitchToKeyboard: () {
          setState(() {
            isHandwritingMode = false;
          });
        },
      ),
    );
  }

  Widget _buildKeyboardInput() {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        hintText: '英単語を入力してください',
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: const TextStyle(fontSize: 18),
      onChanged: (text) => setState(() {}),
    );
  }

  Widget _buildInputModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => isHandwritingMode = !isHandwritingMode),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isHandwritingMode ? Icons.keyboard : Icons.draw,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isHandwritingMode ? 'キーボード' : '手書き',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: _handleDeleteChar,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.backspace,
                  color: Colors.red.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '１文字消去',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            '自信度を選択してください',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildConfidenceButton(
                  confidence: AnswerConfidence.confident,
                  text: '自信をもって回答する',
                  color: Colors.green,
                  icon: Icons.thumb_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildConfidenceButton(
                  confidence: AnswerConfidence.uncertain,
                  text: 'あやしいけど回答する',
                  color: Colors.yellow.shade700,
                  icon: Icons.help_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceButton({
    required AnswerConfidence confidence,
    required String text,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = selectedConfidence == confidence;
    return ElevatedButton.icon(
      onPressed: showFeedback ? null : () {
        setState(() => selectedConfidence = confidence);
      },
      icon: Icon(icon, color: isSelected ? Colors.white : color),
      label: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 降参ボタン
          Expanded(
            child: ElevatedButton.icon(
              onPressed: showFeedback ? null : _handleGiveUp,
              icon: const Icon(Icons.flag, color: Colors.red),
              label: const Text(
                '降参する',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // 回答ボタン
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canAnswer() && !showFeedback ? _handleAnswer : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canAnswer() ? Colors.orange : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '回答する',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: feedbackColor?.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: ScaleTransition(
          scale: _feedbackController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                feedbackColor == Colors.green ? Icons.check_circle : Icons.cancel,
                size: 80,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 16),
              Text(
                feedbackMessage,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (feedbackColor == Colors.red) ...[
                const SizedBox(height: 12),
                Text(
                  '正解: ${questions[currentIndex]['correctAnswer']}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _canAnswer() {
    if (currentQuestionType == QuestionType.englishToJapanese) {
      return selectedChoiceIndex != null;
    } else {
      return _textController.text.trim().isNotEmpty;
    }
  }

  void _handleDeleteChar() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _textController.text = _textController.text.substring(
          0, 
          _textController.text.length - 1,
        );
      });
    }
  }
}