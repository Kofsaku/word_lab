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
    with SingleTickerProviderStateMixin {
  late List<Map<String, dynamic>> questions;
  int currentIndex = 0;
  int? selectedChoiceIndex;
  List<bool> results = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool showFeedback = false;
  Color? feedbackColor;

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
  }

  void _generateQuestions() {
    questions = [];
    final words = _getWordsFromCheckTimeResults();
    
    // 前半2セット：英→日（3文×2）
    for (int set = 0; set < 2; set++) {
      for (int q = 0; q < 3; q++) {
        final wordIndex = (set * 3 + q) % words.length;
        questions.add({
          'type': StageTestType.englishToJapanese,
          'sentence': _generateEnglishSentence(words[wordIndex], widget.userInterest),
          'targetWord': words[wordIndex],
          'choices': _generateJapaneseChoices(words[wordIndex]),
          'correctAnswer': words[wordIndex].japanese,
          'setNumber': set + 1,
          'questionInSet': q + 1,
        });
      }
    }
    
    // 後半2セット：日→英（3文×2）
    for (int set = 0; set < 2; set++) {
      for (int q = 0; q < 3; q++) {
        final wordIndex = (set * 3 + q) % words.length;
        questions.add({
          'type': StageTestType.japaneseToEnglish,
          'sentence': _generateJapaneseSentence(words[wordIndex], widget.userInterest),
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
    });
    
    Future.delayed(const Duration(seconds: 1), () {
      _moveToNext();
    });
  }

  void _moveToNext() {
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
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question['type'] == StageTestType.englishToJapanese
                      ? '英文の意味を選んでね！'
                      : '日本語に合う英語を選んでね！',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
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
          Column(
            children: [
              _buildQuestionTypeIndicator(),
              const SizedBox(height: 30),
              _buildSentence(),
              const SizedBox(height: 30),
              Expanded(child: _buildChoices()),
            ],
          ),
          if (showFeedback) _buildFeedbackOverlay(),
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

  Widget _buildSentence() {
    final question = questions[currentIndex];
    final sentence = question['sentence'] as String;
    final targetWord = question['targetWord'] as Word;
    
    if (question['type'] == StageTestType.englishToJapanese) {
      // 英→日：単語を色付き表示
      return _buildHighlightedSentence(sentence, targetWord.english);
    } else {
      // 日→英：通常表示
      return Text(
        sentence,
        style: const TextStyle(
          fontSize: 20,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _buildHighlightedSentence(String sentence, String targetWord) {
    final parts = sentence.split(targetWord);
    
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 20,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: targetWord,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              backgroundColor: AppColors.primary.withOpacity(0.3),
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildChoices() {
    final question = questions[currentIndex];
    final choices = question['choices'] as List<String>;
    
    return Column(
      children: List.generate(choices.length, (index) {
        final isSelected = selectedChoiceIndex == index;
        final isCorrect = showFeedback && choices[index] == question['correctAnswer'];
        final isWrong = showFeedback && isSelected && !isCorrect;
        
        Color backgroundColor = AppColors.background;
        Color textColor = AppColors.textPrimary;
        
        if (showFeedback) {
          if (isCorrect) {
            backgroundColor = AppColors.correct;
            textColor = AppColors.surface;
          } else if (isWrong) {
            backgroundColor = AppColors.incorrect;
            textColor = AppColors.surface;
          }
        } else if (isSelected) {
          backgroundColor = AppColors.primary;
          textColor = AppColors.surface;
        }
        
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton(
            onPressed: showFeedback ? null : () => _handleAnswer(index),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isSelected ? 4 : 1,
            ),
            child: Text(
              choices[index],
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '${currentIndex + 1}/${questions.length}問',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.surface,
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
              color: AppColors.surface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$questionInSet/3問',
          style: const TextStyle(
            color: AppColors.surface,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: feedbackColor?.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              feedbackColor == AppColors.correct ? Icons.check_circle : Icons.cancel,
              size: 80,
              color: AppColors.surface,
            ),
            const SizedBox(height: 16),
            Text(
              feedbackColor == AppColors.correct ? '正解！' : '不正解...',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.surface,
              ),
            ),
            if (feedbackColor == AppColors.incorrect) ...[
              const SizedBox(height: 12),
              Text(
                '正解: ${questions[currentIndex]['correctAnswer']}',
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.surface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

}