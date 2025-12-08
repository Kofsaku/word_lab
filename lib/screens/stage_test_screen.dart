import 'package:flutter/material.dart';
import '../models/word.dart';
import '../theme/app_colors.dart';

enum StageTestType { englishToJapanese, japaneseToEnglish }

class StageTestScreen extends StatefulWidget {
  final String stageId;
  final List<Map<String, dynamic>> checkTimeResults;
  final String userInterest;

  const StageTestScreen({
    super.key,
    required this.stageId,
    required this.checkTimeResults,
    required this.userInterest,
  });

  @override
  State<StageTestScreen> createState() => _StageTestScreenState();
}

class _StageTestScreenState extends State<StageTestScreen>
    with TickerProviderStateMixin {
  late List<Map<String, dynamic>> questions;
  int currentIndex = 0;
  int? selectedChoiceIndex;
  List<bool> results = [];
  late AnimationController _animationController;
  late AnimationController _feedbackController;
  late Animation<double> _fadeAnimation;
  bool showFeedback = false;
  Color? feedbackColor;
  String feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    _generateQuestions();
    _initializeAnimations();
    _animationController.forward();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    // フィードバック用アニメーション（チェックタイムと同じ800ms）
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  void _generateQuestions() {
    questions = [];
    final words = _getWordsFromCheckTimeResults();

    // 前半2セット：英→日（3文×2）- 既存の構成を踏襲
    for (int set = 0; set < 2; set++) {
      for (int q = 0; q < 3; q++) {
        final wordIndex = (set * 3 + q) % words.length;
        final dialogueData = _generateDialogue(words[wordIndex], widget.userInterest, false);
        questions.add({
          'type': StageTestType.englishToJapanese,
          'sentence': _generateEnglishSentence(words[wordIndex], widget.userInterest),
          'dialogue': dialogueData['dialogue'],
          'translation': dialogueData['translation'],
          'targetWord': words[wordIndex],
          'choices': _generateJapaneseChoices(words[wordIndex]),
          'correctAnswer': words[wordIndex].japanese,
          'setNumber': set + 1,
          'questionInSet': q + 1,
        });
      }
    }

    // 後半2セット：日→英（3文×2）- ダイアログ形式
    for (int set = 0; set < 2; set++) {
      for (int q = 0; q < 3; q++) {
        final wordIndex = (set * 3 + q) % words.length;
        final dialogueData = _generateDialogue(words[wordIndex], widget.userInterest, true);
        questions.add({
          'type': StageTestType.japaneseToEnglish,
          'sentence': _generateJapaneseSentence(words[wordIndex], widget.userInterest),
          'dialogue': dialogueData['dialogue'],
          'translation': dialogueData['translation'],
          'targetWord': words[wordIndex],
          'choices': _generateEnglishChoices(words[wordIndex]),
          'correctAnswer': words[wordIndex].english,
          'setNumber': set + 3,
          'questionInSet': q + 1,
        });
      }
    }
  }

  List<Word> _getWordsFromCheckTimeResults() {
    // チェックタイム結果から単語を抽出
    return widget.checkTimeResults
        .map((result) => result['word'] as Word)
        .toList();
  }

  // ダイアログ形式のダミーデータを生成（実際はFirebase Functions + GPT API）
  Map<String, dynamic> _generateDialogue(Word word, String userInterest, bool isJapaneseToEnglish) {
    // ダミーダイアログデータ（6行の会話形式：A→B→A→B→A→B）
    final dialogueTemplates = [
      {
        'dialogue': [
          'A: Hello, ${isJapaneseToEnglish ? "(　　　)" : word.english} is my favorite word.',
          'B: Really? Why do you like ${isJapaneseToEnglish ? "(　　　)" : word.english}?',
          'A: Because it sounds interesting.',
          'B: I see. That makes sense.',
          'A: Yes, ${isJapaneseToEnglish ? "(　　　)" : word.english} is very useful.',
          'B: I want to learn it too.',
        ],
        'translation': [
          'A: こんにちは、${word.japanese}は私のお気に入りの言葉です。',
          'B: 本当？なぜ${word.japanese}が好きなの？',
          'A: 面白く聞こえるからです。',
          'B: なるほど。それは分かります。',
          'A: はい、${word.japanese}はとても便利です。',
          'B: 私も学びたいです。',
        ],
      },
      {
        'dialogue': [
          'A: Do you know about ${isJapaneseToEnglish ? "(　　　)" : word.english}?',
          'B: Yes, I learned it yesterday.',
          'A: ${isJapaneseToEnglish ? "(　　　)" : word.english} is important for us.',
          'B: I agree with you.',
          'A: Let\'s practice ${isJapaneseToEnglish ? "(　　　)" : word.english} together.',
          'B: That sounds great!',
        ],
        'translation': [
          'A: ${word.japanese}について知っていますか？',
          'B: はい、昨日学びました。',
          'A: ${word.japanese}は私たちにとって重要です。',
          'B: 同意します。',
          'A: 一緒に${word.japanese}を練習しましょう。',
          'B: いいですね！',
        ],
      },
      {
        'dialogue': [
          'A: I want to learn ${isJapaneseToEnglish ? "(　　　)" : word.english}.',
          'B: That is a good idea.',
          'A: ${isJapaneseToEnglish ? "(　　　)" : word.english} will help me.',
          'B: Yes, it is very useful.',
          'A: Thank you for your advice.',
          'B: You are welcome!',
        ],
        'translation': [
          'A: ${word.japanese}を学びたいです。',
          'B: それは良い考えですね。',
          'A: ${word.japanese}は私の役に立ちます。',
          'B: はい、とても便利です。',
          'A: アドバイスありがとうございます。',
          'B: どういたしまして！',
        ],
      },
    ];

    final templateIndex = word.english.length % dialogueTemplates.length;
    return dialogueTemplates[templateIndex];
  }

  String _generateEnglishSentence(Word word, String userInterest) {
    // ダミーGPT生成文章（実際はFirebase Functions + GPT API）
    final templates = [
      'The ${word.english} is very important in ${userInterest.isNotEmpty ? userInterest : "daily life"}.',
      'I want to ${word.english} more about ${userInterest.isNotEmpty ? userInterest : "this topic"}.',
      'Learning about ${word.english} helps us understand ${userInterest.isNotEmpty ? userInterest : "the world"}.',
    ];

    return templates[word.english.length % templates.length];
  }

  String _generateJapaneseSentence(Word word, String userInterest) {
    // ダミーGPT生成文章（実際はFirebase Functions + GPT API）
    final templates = [
      '${userInterest.isNotEmpty ? userInterest : "日常生活"}において、${word.japanese}はとても重要です。',
      '私は${userInterest.isNotEmpty ? userInterest : "このトピック"}について${word.japanese}したいと思います。',
      '${word.japanese}を学ぶことで、${userInterest.isNotEmpty ? userInterest : "世界"}をよりよく理解できます。',
    ];

    return templates[word.japanese.length % templates.length];
  }

  List<String> _generateJapaneseChoices(Word correctWord) {
    final choices = [correctWord.japanese, '選択肢2', '選択肢3', '選択肢4'];
    choices.shuffle();
    return choices;
  }

  List<String> _generateEnglishChoices(Word correctWord) {
    final choices = [correctWord.english, 'choice2', 'choice3', 'choice4'];
    choices.shuffle();
    return choices;
  }

  void _handleAnswer(int choiceIndex) {
    if (showFeedback) return;

    setState(() => selectedChoiceIndex = choiceIndex);

    final question = questions[currentIndex];
    final selectedAnswer = question['choices'][choiceIndex];
    final isCorrect = selectedAnswer == question['correctAnswer'];

    results.add(isCorrect);

    setState(() {
      showFeedback = true;
      feedbackColor = isCorrect ? AppColors.correct : AppColors.incorrect;
      feedbackMessage = isCorrect ? '正解' : '不正解';
    });

    // フィードバックアニメーションを開始（タップで次へ遷移するので自動遷移は削除）
    _feedbackController.forward();
  }

  void _moveToNext() {
    _feedbackController.reset();
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedChoiceIndex = null;
        showFeedback = false;
      });
    } else {
      _navigateToResult();
    }
  }

  void _navigateToResult() {
    final correctCount = results.where((r) => r).length;
    final totalCount = results.length;
    final score = ((correctCount / totalCount) * 100).round();
    
    Navigator.pushReplacementNamed(
      context,
      '/result',
      arguments: {
        'stageId': widget.stageId,
        'testScore': score,
        'testCorrectCount': correctCount,
        'testTotalCount': totalCount,
        'checkTimeCorrectCount': _getCheckTimeCorrectCount(),
        'checkTimeTotalCount': widget.checkTimeResults.length,
      },
    );
  }

  int _getCheckTimeCorrectCount() {
    return widget.checkTimeResults
        .where((result) => result['isCorrect'] == true)
        .length;
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildCharacterArea(),
                Expanded(child: _buildQuestionArea()),
                _buildProgress(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterArea() {
    final question = questions[currentIndex];
    final setNumber = question['setNumber'];
    final questionInSet = question['questionInSet'];
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // キャラクターエリア（new_req仕様）
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: AppColors.primary,
                width: 3,
              ),
            ),
            child: Icon(
              Icons.quiz,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ピコタン',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'セット$setNumber - 問題$questionInSet',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question['type'] == StageTestType.englishToJapanese
                      ? '英文の意味を選んでね！'
                      : '日本語に合う英語を選んでね！',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionArea() {
    final question = questions[currentIndex];
    final isJapToEng = question['type'] == StageTestType.japaneseToEnglish;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestionTypeIndicator(),
                const SizedBox(height: 16),
                _buildDialogueArea(),
                const SizedBox(height: 16),
                _buildChoicesSection(),
                if (isJapToEng) ...[
                  const SizedBox(height: 16),
                  _buildTranslationSection(),
                ],
              ],
            ),
          ),
          if (showFeedback) Positioned.fill(child: _buildFeedbackOverlay()),
        ],
      ),
    );
  }

  Widget _buildQuestionTypeIndicator() {
    final question = questions[currentIndex];
    final isEngToJap = question['type'] == StageTestType.englishToJapanese;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isEngToJap ? AppColors.accent.withOpacity(0.1) : AppColors.correct.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isEngToJap ? '英語 → 日本語' : '日本語 → 英語',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // 6行分のダイアログ表示エリア（ボックス背景なし、左右いっぱい）
  Widget _buildDialogueArea() {
    final question = questions[currentIndex];
    final dialogue = question['dialogue'] as List<dynamic>;
    final isEngToJap = question['type'] == StageTestType.englishToJapanese;
    final targetWord = question['targetWord'] as Word;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...dialogue.map((line) {
          if (isEngToJap) {
            // 英→日：ターゲット単語をハイライト
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildHighlightedLine(line.toString(), targetWord.english),
            );
          } else {
            // 日→英：空欄表示（既にダイアログに含まれている）
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                line.toString(),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildHighlightedLine(String line, String targetWord) {
    if (!line.contains(targetWord)) {
      return Text(
        line,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
      );
    }

    final parts = line.split(targetWord);
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: targetWord,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              backgroundColor: AppColors.primary.withOpacity(0.2),
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts.sublist(1).join(targetWord)),
        ],
      ),
    );
  }

  // 選択肢セクション
  Widget _buildChoicesSection() {
    final question = questions[currentIndex];
    final choices = question['choices'] as List<String>;
    final isJapToEng = question['type'] == StageTestType.japaneseToEnglish;

    // 日→英は2x2グリッド、英→日は縦1列
    if (isJapToEng) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildChoiceButton(0, choices)),
              const SizedBox(width: 8),
              Expanded(child: _buildChoiceButton(1, choices)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildChoiceButton(2, choices)),
              const SizedBox(width: 8),
              Expanded(child: _buildChoiceButton(3, choices)),
            ],
          ),
        ],
      );
    }

    // 英→日は縦1列表示（横幅いっぱい）
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildChoiceButton(0, choices),
        const SizedBox(height: 8),
        _buildChoiceButton(1, choices),
        const SizedBox(height: 8),
        _buildChoiceButton(2, choices),
        const SizedBox(height: 8),
        _buildChoiceButton(3, choices),
      ],
    );
  }

  Widget _buildChoiceButton(int index, List<String> choices) {
    if (index >= choices.length) return const SizedBox.shrink();

    final question = questions[currentIndex];
    final isSelected = selectedChoiceIndex == index;
    final isCorrect = showFeedback && choices[index] == question['correctAnswer'];
    final isWrong = showFeedback && isSelected && !isCorrect;

    Color backgroundColor = AppColors.background;
    Color textColor = AppColors.textPrimary;
    Color borderColor = AppColors.textPrimary.withOpacity(0.3);

    if (showFeedback) {
      if (isCorrect) {
        backgroundColor = AppColors.correct;
        textColor = AppColors.surface;
        borderColor = AppColors.correct;
      } else if (isWrong) {
        backgroundColor = AppColors.incorrect;
        textColor = AppColors.surface;
        borderColor = AppColors.incorrect;
      }
    } else if (isSelected) {
      backgroundColor = AppColors.primary.withOpacity(0.2);
      borderColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: showFeedback ? null : () => _handleAnswer(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Text(
          '${index + 1}. ${choices[index]}',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // 日本語訳セクション（日→英問題用）
  Widget _buildTranslationSection() {
    final question = questions[currentIndex];
    final translation = question['translation'] as List<dynamic>;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.correct.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.correct.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate, size: 16, color: AppColors.correct),
              const SizedBox(width: 4),
              Text(
                '日本語訳',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.correct,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...translation.map((line) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line.toString(),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '${currentIndex + 1}/${questions.length}問',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (currentIndex + 1) / questions.length,
            backgroundColor: AppColors.surface.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          _buildSetIndicator(),
        ],
      ),
    );
  }

  Widget _buildSetIndicator() {
    final question = questions[currentIndex];
    final setNumber = question['setNumber'];
    final questionInSet = question['questionInSet'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'セット$setNumber',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$questionInSet/3問',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackOverlay() {
    final question = questions[currentIndex];
    final word = question['targetWord'] as Word;
    final translation = question['translation'] as List<dynamic>;
    final isCorrect = feedbackColor == AppColors.correct;

    return GestureDetector(
      onTap: _moveToNext,
      child: Container(
        decoration: BoxDecoration(
          color: feedbackColor?.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _feedbackController,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
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
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // 単語情報（チェックタイムと同様）
                  Text(
                    word.english,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    word.japanese,
                    style: const TextStyle(
                      fontSize: 22,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.partOfSpeech,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // 全訳表示
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '全訳:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...translation.map((line) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            line.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary.withOpacity(0.9),
                              height: 1.3,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // タップで次へ進むヒント
                  Text(
                    'タップして次へ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}