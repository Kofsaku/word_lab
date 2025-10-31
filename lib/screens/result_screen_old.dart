import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../data/dummy_data.dart';

class ResultScreen extends StatefulWidget {
  final String stageId;
  final int testScore;
  final int testCorrectCount;
  final int testTotalCount;
  final int checkTimeCorrectCount;
  final int checkTimeTotalCount;

  const ResultScreen({
    super.key,
    required this.stageId,
    required this.testScore,
    required this.testCorrectCount,
    required this.testTotalCount,
    required this.checkTimeCorrectCount,
    required this.checkTimeTotalCount,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;
  late AnimationController _starController;
  late Animation<double> _starAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _scoreController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.testScore.toDouble(),
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutCubic,
    ));
    
    _starController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _starAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.elasticOut,
    ));

    _bounceController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
    
    _scoreController.forward();
    _starController.forward();

    // ステージクリア状態を更新
    if (widget.testScore >= 70) {
      final stage = DummyData.getStageById(widget.stageId);
      if (stage != null) {
        stage.isCleared = true;
        stage.score = widget.testScore.toDouble();
        stage.clearedAt = DateTime.now();
      }
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _starController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  int _getStarCount() {
    if (widget.testScore >= 90) return 3;
    if (widget.testScore >= 70) return 2;
    if (widget.testScore >= 50) return 1;
    return 0;
  }

  Color _getScoreColor() {
    if (widget.testScore >= 90) return Colors.amber;
    if (widget.testScore >= 70) return Colors.green;
    if (widget.testScore >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getResultMessage() {
    if (widget.testScore >= 90) return 'パーフェクト！天才(てんさい)だ！';
    if (widget.testScore >= 70) return 'やったね！ごうかくだよ！';
    if (widget.testScore >= 50) return 'おしい！もうちょっと！';
    return 'つぎはがんばろう！';
  }

  String _getEncouragementMessage() {
    if (widget.testScore >= 90) {
      return 'きみはえいごの天才(てんさい)！このちょうしでいこう！';
    } else if (widget.testScore >= 70) {
      return 'すごくがんばったね！つぎのステージもたのしみだね！';
    } else if (widget.testScore >= 50) {
      return 'いいかんじ！もうすこしでクリアできるよ！';
    } else {
      return 'だいじょうぶ！れんしゅうすればかならずできるよ！';
    }
  }

  IconData _getResultIcon() {
    if (widget.testScore >= 90) return Icons.emoji_events;
    if (widget.testScore >= 70) return Icons.celebration;
    if (widget.testScore >= 50) return Icons.thumb_up;
    return Icons.sentiment_satisfied;
  }

  @override
  Widget build(BuildContext context) {
    final starCount = _getStarCount();
    final isPassed = widget.testScore >= 70;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isPassed
                ? [Colors.blue.shade400, Colors.purple.shade400]
                : [Colors.orange.shade300, Colors.pink.shade300],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildCharacterSection(),
                const SizedBox(height: 30),
                _buildScoreSection(starCount),
                const SizedBox(height: 30),
                _buildEncouragementCard(),
                const SizedBox(height: 20),
                _buildDetailsCard(),
                const SizedBox(height: 30),
                _buildActionButtons(context, isPassed),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterSection() {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getScoreColor().withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _getResultIcon(),
              size: 60,
              color: _getScoreColor(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreSection(int starCount) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _scoreAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: _getScoreColor().withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_scoreAnimation.value.toInt()}',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(),
                          ),
                        ),
                        Text(
                          'てん',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ...List.generate(12, (index) {
                  final angle = (index * math.pi / 6);
                  return Transform.translate(
                    offset: Offset(
                      math.cos(angle) * 130,
                      math.sin(angle) * 130,
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.yellow.withOpacity(0.4),
                      size: 24,
                    ),
                  );
                }),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        AnimatedBuilder(
          animation: _starAnimation,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final filled = index < starCount;
                return Transform.scale(
                  scale: filled ? _starAnimation.value : 0.8,
                  child: Icon(
                    filled ? Icons.star : Icons.star_border,
                    color: filled ? Colors.amber : Colors.grey.shade400,
                    size: 60,
                  ),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          _getResultMessage(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEncouragementCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.tips_and_updates,
            color: Colors.orange.shade500,
            size: 40,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              _getEncouragementMessage(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'せいせきひょう',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),
          _buildResultRow(
            'チェックタイム',
            '${widget.checkTimeCorrectCount} / ${widget.checkTimeTotalCount}',
            Colors.orange,
            Icons.edit,
          ),
          const SizedBox(height: 15),
          _buildResultRow(
            'ステージテスト',
            '${widget.testCorrectCount} / ${widget.testTotalCount}',
            Colors.deepPurple,
            Icons.quiz,
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: _getScoreColor(),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'ごうけいてん',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getScoreColor(),
                    width: 2,
                  ),
                ),
                child: Text(
                  '${widget.testScore}てん',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isPassed) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPassed ? Icons.arrow_forward : Icons.home,
                  color: Colors.purple,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  isPassed ? 'つぎのステージへ' : 'ホームにもどる',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isPassed) ...[
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/input-training',
                  (route) => false,
                  arguments: widget.stageId,
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.refresh,
                    color: Colors.black,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'もういちどチャレンジ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}