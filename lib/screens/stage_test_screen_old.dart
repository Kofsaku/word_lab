import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/test_question.dart';

class StageTestScreen extends StatefulWidget {
  final String stageId;
  final List<bool> checkTimeResults;
  final String? userInterest;

  const StageTestScreen({
    super.key,
    required this.stageId,
    required this.checkTimeResults,
    this.userInterest,
  });

  @override
  State<StageTestScreen> createState() => _StageTestScreenState();
}

class _StageTestScreenState extends State<StageTestScreen>
    with SingleTickerProviderStateMixin {
  late List<TestQuestion> questions;
  int currentQuestionIndex = 0;
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    final stage = DummyData.getStageById(widget.stageId);
    questions = DummyData.generateTestQuestions(stage?.wordIds ?? []);
    
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
    
    _animationController.forward();
  }

  String _generateExampleSentence(String word) {
    // ユーザーの興味関心に基づいて例文を生成
    if (widget.userInterest != null && widget.userInterest!.isNotEmpty) {
      // 興味関心に関連するキーワードを抽出
      if (widget.userInterest!.contains('テクノロジー') || 
          widget.userInterest!.contains('AI')) {
        return 'The $word is essential for modern technology.';
      } else if (widget.userInterest!.contains('ビジネス')) {
        return 'Our $word strategy improved business performance.';
      } else if (widget.userInterest!.contains('旅行')) {
        return 'The $word made our travel experience memorable.';
      } else if (widget.userInterest!.contains('映画') || 
                 widget.userInterest!.contains('音楽')) {
        return 'This $word reminds me of my favorite movie.';
      } else if (widget.userInterest!.contains('グローバル') || 
                 widget.userInterest!.contains('チーム')) {
        return 'The global team values this $word highly.';
      }
    }
    
    // デフォルトの例文
    final defaultSentences = [
      'The $word is very interesting.',
      'I need to understand this $word better.',
      'This $word is important for learning.',
      'The $word helps us communicate effectively.',
    ];
    
    return defaultSentences[currentQuestionIndex % defaultSentences.length];
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submitAnswer(String answer) {
    setState(() {
      questions[currentQuestionIndex].userAnswer = answer;
      questions[currentQuestionIndex].isCorrect = 
          answer.toLowerCase() == 
          questions[currentQuestionIndex].correctAnswer.toLowerCase();
    });

    _nextQuestion();
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      _animationController.reverse().then((_) {
        setState(() {
          currentQuestionIndex++;
          _textController.clear();
        });
        _animationController.forward();
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final correctCount = questions.where((q) => q.isCorrect == true).length;
    final checkTimeCorrectCount = 
        widget.checkTimeResults.where((r) => r).length;
    final totalScore = ((correctCount / questions.length) * 100).round();

    Navigator.pushReplacementNamed(
      context,
      '/result',
      arguments: {
        'stageId': widget.stageId,
        'testScore': totalScore,
        'testCorrectCount': correctCount,
        'testTotalCount': questions.length,
        'checkTimeCorrectCount': checkTimeCorrectCount,
        'checkTimeTotalCount': widget.checkTimeResults.length,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ステージクリアテスト'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple,
              Colors.deepPurple.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildProgressSection(progress),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildQuestionSection(question),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (widget.userInterest != null && widget.userInterest!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.userInterest!.length > 30
                          ? '${widget.userInterest!.substring(0, 30)}...'
                          : widget.userInterest!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '問題 ${currentQuestionIndex + 1} / ${questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${(questions.length - currentQuestionIndex) * 10}秒',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(TestQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildQuestionCard(question),
          const SizedBox(height: 30),
          if (question.type == QuestionType.multipleChoice)
            _buildMultipleChoiceOptions(question)
          else
            _buildTextInput(question),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(TestQuestion question) {
    final word = DummyData.getWordById(question.wordId);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: question.type == QuestionType.multipleChoice
                  ? Colors.blue.shade100
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              question.type == QuestionType.multipleChoice
                  ? '意味選択問題'
                  : '英単語入力問題',
              style: TextStyle(
                color: question.type == QuestionType.multipleChoice
                    ? Colors.blue.shade700
                    : Colors.green.shade700,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (word != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                word.partOfSpeech,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (question.type == QuestionType.multipleChoice && word != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  if (widget.userInterest != null && widget.userInterest!.isNotEmpty) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: Colors.deepPurple.shade400,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'カスタム例文',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.deepPurple.shade400,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    _generateExampleSentence(word.english.toLowerCase()),
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
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

  Widget _buildMultipleChoiceOptions(TestQuestion question) {
    return Column(
      children: question.options.map((option) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _submitAnswer(option),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.deepPurple.shade200,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.deepPurple.shade300,
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextInput(TestQuestion question) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.deepPurple.shade200,
              width: 2,
            ),
          ),
          child: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: '英単語を入力',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(20),
            ),
            style: const TextStyle(
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
            onSubmitted: _submitAnswer,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              _submitAnswer(_textController.text);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
          ),
          child: const Text(
            '回答する',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}