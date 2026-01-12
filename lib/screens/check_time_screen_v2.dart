import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
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
    // 自信度がなければデフォルトで uncertain を設定
    if (selectedConfidence == null) {
      selectedConfidence = AnswerConfidence.uncertain;
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
      feedbackMessage = isCorrect ? '正解' : '不正解';
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
              // 正解を表示してから次へ
              _showGiveUpFeedback();
            },
            child: const Text('降参する'),
          ),
        ],
      ),
    );
  }

  void _showGiveUpFeedback() {
    final question = questions[currentIndex];

    // 音声再生（日→英問題の場合）
    if (currentQuestionType == QuestionType.japaneseToEnglish) {
      _audioService.playWordAudio(question['word'].english);
    }

    setState(() {
      feedbackMessage = '正解は...';
      feedbackColor = AppColors.warning;
      showFeedback = true;
    });

    _feedbackController.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        _moveToNext();
      });
    });
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
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 左側の閉じるボタン
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 28),
            ),
          ),
          // 中央のタイトル
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
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          // 右側のキャラクター
          Align(
            alignment: Alignment.centerRight,
            child: _buildCharacterAnimation(),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterAnimation() {
    return _ContinuousBouncingWidget(
      child: SizedBox(
        width: 100, // 120から100へ微調整
        height: 100,
        child: RiveAnimation.asset(
          'assets/animations/pikotan_animation.riv',
          animations: const ['idle', 'walk_L', 'walk_R', 'sleep_A', 'flag_idle'],
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildQuestionArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 利用可能な高さから他の要素の高さを引いて手書きエリアの高さを計算
        // 他の要素：問題タイプ(40)+問題内容(100)+カードボックス(70)+ボタン類(100)+余白(30)=340px
        final availableHeight = constraints.maxHeight - 340;
        final handwritingHeight = availableHeight.clamp(120.0, 350.0);
        
        return Container(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
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
                physics: isHandwritingMode 
                    ? const NeverScrollableScrollPhysics() 
                    : const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildQuestionTypeIndicator(),
                    const SizedBox(height: 10),
                    _buildQuestionContent(),
                    const SizedBox(height: 10),
                    _buildAnswerSectionWithHeight(handwritingHeight),
                  ],
                ),
              ),
              if (showFeedback) Positioned.fill(child: _buildFeedbackOverlay()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionTypeIndicator() {
    final isEngToJap = currentQuestionType == QuestionType.englishToJapanese;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isEngToJap ? AppColors.accent.withOpacity(0.3) : AppColors.correct.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isEngToJap ? '英語 → 日本語' : '日本語 → 英語',
        style: TextStyle(
          color: isEngToJap ? AppColors.accent : AppColors.correct,
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
          const Icon(Icons.volume_up, color: AppColors.accent, size: 32),
          const SizedBox(height: 16),
          Text(
            word.english,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            word.partOfSpeech,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary.withOpacity(0.3).withOpacity(0.6),
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
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            word.partOfSpeech,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary.withOpacity(0.3).withOpacity(0.6),
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

  Widget _buildAnswerSectionWithHeight(double handwritingHeight) {
    if (currentQuestionType == QuestionType.englishToJapanese) {
      return _buildChoiceButtons();
    } else {
      return _buildInputSectionWithHeight(handwritingHeight);
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
              // 選択したら即座に回答処理
              _handleAnswer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected
                  ? AppColors.accent.withOpacity(0.7)
                  : AppColors.surface.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              choices[index],
              style: TextStyle(
                color: AppColors.textPrimary,
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
        const SizedBox(height: 15),
        
        // 入力エリア（常に表示）
        Container(
          child: isHandwritingMode 
              ? _buildHandwritingArea()
              : _buildKeyboardInput(),
        ),
        
        // 認識候補表示（手書きモード時のみ）
        if (isHandwritingMode && recognitionCandidates.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: RecognitionCandidates(
              candidates: recognitionCandidates,
              selectedText: selectedCandidate,
              onCandidateSelected: (candidate) {
                setState(() {
                  selectedCandidate = candidate;
                  _textController.text = candidate;
                });
              },
            ),
          ),
        
        const SizedBox(height: 15),
        _buildInputModeToggle(),
      ],
    );
  }

  Widget _buildInputSectionWithHeight(double handwritingHeight) {
    return Column(
      children: [
        _buildCardBox(),
        const SizedBox(height: 15),
        
        // 入力エリア（動的高さ）
        Container(
          child: isHandwritingMode 
              ? _buildHandwritingAreaWithHeight(handwritingHeight)
              : _buildKeyboardInput(),
        ),
        
        // 認識候補表示（手書きモード時のみ）
        if (isHandwritingMode && recognitionCandidates.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: RecognitionCandidates(
              candidates: recognitionCandidates,
              selectedText: selectedCandidate,
              onCandidateSelected: (candidate) {
                setState(() {
                  selectedCandidate = candidate;
                  _textController.text = candidate;
                });
              },
            ),
          ),
        
        const SizedBox(height: 15),
        _buildInputModeToggle(),
      ],
    );
  }

  Widget _buildCardBox() {
    final word = questions[currentIndex]['word'] as Word;
    final question = questions[currentIndex];
    final correctAnswer = question['correctAnswer'] as String;
    final targetLength = correctAnswer.length;
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
                border: Border(
                  bottom: BorderSide(
                    color: hasChar ? AppColors.accent : AppColors.textPrimary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  hasChar ? currentText[index].toUpperCase() : '',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
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
      height: (MediaQuery.of(context).size.height * 0.32).clamp(140.0, 350.0),
      child: HandwritingInput(
        currentQuestion: 'question_${currentIndex}', // 問題変更検知用
        onTextChanged: (text) {
          Future.microtask(() {
            setState(() {
              _textController.text = text;
            });
            
            // リアルタイム認識候補の取得
            if (text.isNotEmpty) {
              _recognitionService.recognizeWithCandidates(
                [], // 実際のストロークデータが必要
                maxCandidates: 3,
              ).then((candidates) {
                if (mounted) {
                  setState(() {
                    recognitionCandidates = candidates;
                  });
                }
              }).catchError((e) {
                print('Recognition candidates error: $e');
              });
            } else {
              setState(() {
                recognitionCandidates = [];
              });
            }
          });
        },
        onClear: () {
          Future.microtask(() {
            setState(() {
              _textController.clear();
            });
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

  Widget _buildHandwritingAreaWithHeight(double height) {
    return SizedBox(
      height: height,
      child: HandwritingInput(
        currentQuestion: 'question_${currentIndex}',
        onTextChanged: (text) {
          Future.microtask(() {
            setState(() {
              _textController.text = text;
            });
            
            if (text.isNotEmpty) {
              _recognitionService.recognizeWithCandidates(
                [],
                maxCandidates: 3,
              ).then((candidates) {
                if (mounted) {
                  setState(() {
                    recognitionCandidates = candidates;
                  });
                }
              }).catchError((e) {
                print('Recognition candidates error: $e');
              });
            } else {
              setState(() {
                recognitionCandidates = [];
              });
            }
          });
        },
        onClear: () {
          Future.microtask(() {
            setState(() {
              _textController.clear();
            });
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
    return Container(
      height: 60,
      child: TextField(
        controller: _textController,
        decoration: InputDecoration(
          hintText: '回答を入力してください',
          filled: true,
          fillColor: AppColors.surface.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        style: const TextStyle(fontSize: 18),
        onChanged: (text) => setState(() {}),
        autofocus: false,
      ),
    );
  }

  Widget _buildInputModeToggle() {
    // 手書きモード時はhandwriting_input内にボタンがあるため非表示
    if (isHandwritingMode) {
      return const SizedBox.shrink();
    }
    
    // キーボードモード時のみ表示
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 手書きモードへの切り替えボタン（テキスト付き、枠線なし）
        GestureDetector(
          onTap: () => setState(() => isHandwritingMode = true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.draw,
                  color: Colors.blue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '手書き',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 1文字消去ボタン（アイコンのみ、枠線なし）
        Tooltip(
          message: '1文字消去',
          child: GestureDetector(
            onTap: _handleDeleteChar,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.backspace,
                color: Colors.red,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildConfidenceButton(
                  confidence: AnswerConfidence.confident,
                  text: '自信をもって回答する',
                  color: AppColors.correct,
                  icon: Icons.thumb_up,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildConfidenceButton(
                  confidence: AnswerConfidence.uncertain,
                  text: 'あやしいけど回答する',
                  color: AppColors.warning,
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
      icon: Icon(icon, color: AppColors.textPrimary),
      label: Text(
        text,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : AppColors.surface,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    // 4択問題（英→日）では下部ボタンを非表示
    if (currentQuestionType == QuestionType.englishToJapanese) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // 降参ボタン
          Expanded(
            child: ElevatedButton.icon(
              onPressed: showFeedback ? null : _handleGiveUp,
              icon: Icon(Icons.flag, color: AppColors.incorrect),
              label: Text(
                '降参する',
                style: TextStyle(
                  color: AppColors.incorrect,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 回答ボタン
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canAnswer() && !showFeedback ? _handleAnswer : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canAnswer() ? AppColors.warning : AppColors.surface.withOpacity(0.6),
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
    final word = questions[currentIndex]['word'] as Word;

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // メッセージ（正解/不正解）は上部に控えめに
              Text(
                feedbackMessage,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // アイコンも重ならない程度に
              Icon(
                feedbackColor == AppColors.correct ? Icons.check_circle : Icons.cancel,
                size: 60,
                color: AppColors.textPrimary.withOpacity(0.8),
              ),
              const SizedBox(height: 30),
              // 単語情報を「主役」として巨大化
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Text(
                      word.english,
                      style: const TextStyle(
                        fontSize: 40, // 48から40へ調整
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      word.japanese,
                      style: const TextStyle(
                        fontSize: 28, // 36から28へ調整
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                word.partOfSpeech,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
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

class _ContinuousBouncingWidget extends StatefulWidget {
  final Widget child;

  const _ContinuousBouncingWidget({required this.child});

  @override
  State<_ContinuousBouncingWidget> createState() => _ContinuousBouncingWidgetState();
}

class _ContinuousBouncingWidgetState extends State<_ContinuousBouncingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: -6.0,
      end: 6.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, _floatAnimation.value * 0.3),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}