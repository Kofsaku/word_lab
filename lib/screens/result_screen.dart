import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/word.dart';
import '../theme/app_colors.dart';

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
  late AnimationController _boxAnimationController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _boxAnimation;
  
  // ダミーBOX移動データ
  late List<Map<String, dynamic>> wordResults;

  @override
  void initState() {
    super.initState();
    _generateWordResults();
    _initializeAnimations();
    _startAnimations();
  }

  void _generateWordResults() {
    // ダミーデータ：各単語のBOX移動情報
    wordResults = [
      {'word': 'apple', 'japanese': 'りんご', 'fromBox': 1, 'toBox': 2, 'isBoost': false},
      {'word': 'run', 'japanese': '走る', 'fromBox': 1, 'toBox': 3, 'isBoost': true},
      {'word': 'happy', 'japanese': '幸せな', 'fromBox': 2, 'toBox': 3, 'isBoost': false},
      {'word': 'book', 'japanese': '本', 'fromBox': 1, 'toBox': 2, 'isBoost': false},
      {'word': 'study', 'japanese': '勉強する', 'fromBox': 2, 'toBox': 1, 'isBoost': false},
      {'word': 'beautiful', 'japanese': '美しい', 'fromBox': 3, 'toBox': 4, 'isBoost': false},
    ];
  }

  void _initializeAnimations() {
    _scoreController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _boxAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.testScore.toDouble(),
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutCubic,
    ));

    _boxAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _boxAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _scoreController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _boxAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _boxAnimationController.dispose();
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
              _buildCharacterArea(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildBoxMovementSection(),
                      const SizedBox(height: 30),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterArea() {
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
          // キャラクター（ピコタン）
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.correct.withOpacity(0.3),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: AppColors.correct,
                width: 3,
              ),
            ),
            child: Icon(
              Icons.celebration,
              size: 40,
              color: AppColors.correct,
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
                  _getCharacterMessage(),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCharacterMessage() {
    final overallScore = (widget.testScore + 
        (widget.checkTimeCorrectCount / widget.checkTimeTotalCount * 100)) / 2;
    
    if (overallScore >= 90) return 'すごいじゃない！パーフェクトに近いよ！';
    if (overallScore >= 80) return 'とてもよくできました！この調子で頑張って！';
    if (overallScore >= 70) return 'いいね！着実に力がついてるよ！';
    if (overallScore >= 60) return 'まずまずの結果だね！復習も大切だよ！';
    return 'ドンマイ！次は必ずできるよ！';
  }

  Widget _buildResultsSection() {
    return Container(
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
      child: Column(
        children: [
          const Text(
            '学習結果',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          // 詳細結果（スコア表示を削除）
          Row(
            children: [
              Expanded(
                child: _buildResultCard(
                  'チェックタイム',
                  widget.checkTimeCorrectCount,
                  widget.checkTimeTotalCount,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildResultCard(
                  'ステージテスト',
                  widget.testCorrectCount,
                  widget.testTotalCount,
                  AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, int correct, int total, Color color) {
    final percentage = total > 0 ? (correct / total * 100).round() : 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$correct/$total',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxMovementSection() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.move_up,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'BOX移動結果',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _boxAnimation,
            builder: (context, child) {
              final visibleItems = (_boxAnimation.value * wordResults.length).round();
              
              return Column(
                children: wordResults
                    .take(visibleItems)
                    .map((result) => _buildWordBoxMovement(result))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWordBoxMovement(Map<String, dynamic> result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result['isBoost'] ? AppColors.warning : AppColors.border,
          width: result['isBoost'] ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // 単語情報
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['word'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  result['japanese'],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // BOX移動表示
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBoxIndicator(result['fromBox'], false),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  color: result['toBox'] > result['fromBox'] 
                      ? AppColors.correct 
                      : AppColors.incorrect,
                  size: 20,
                ),
                const SizedBox(width: 8),
                _buildBoxIndicator(result['toBox'], true),
              ],
            ),
          ),
          
          // ブーストアイコン
          if (result['isBoost'])
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.rocket_launch,
                size: 16,
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBoxIndicator(int boxNumber, bool isDestination) {
    Color color;
    String text;
    
    if (boxNumber == 6) {
      color = AppColors.primary;
      text = '∞';
    } else {
      color = isDestination ? AppColors.correct : AppColors.primary;
      text = boxNumber.toString();
    }
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedResults() {
    final overallCorrect = widget.testCorrectCount + widget.checkTimeCorrectCount;
    final overallTotal = widget.testTotalCount + widget.checkTimeTotalCount;
    final overallPercentage = overallTotal > 0 ? (overallCorrect / overallTotal * 100).round() : 0;
    
    return Container(
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
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '詳細結果',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildDetailRow('総合正答率', '$overallPercentage%', AppColors.primary),
          _buildDetailRow('チェックタイム', 
              '${widget.checkTimeCorrectCount}/${widget.checkTimeTotalCount}問正解', 
              AppColors.warning),
          _buildDetailRow('ステージテスト', 
              '${widget.testCorrectCount}/${widget.testTotalCount}問正解', 
              AppColors.primary),
          _buildDetailRow('BOX昇格', '${_getUpgradeCount()}語', AppColors.accent),
          _buildDetailRow('BOX降格', '${_getDowngradeCount()}語', AppColors.incorrect),
          if (_getBoostCount() > 0)
            _buildDetailRow('既知語ブースト', '${_getBoostCount()}語', AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
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
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // 次のステージに進むボタン
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            icon: const Icon(Icons.play_arrow, color: AppColors.surface),
            label: const Text(
              '次のステージに進む',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.surface,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.correct,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // 保存して終了ボタン
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              _showSaveDialog();
            },
            icon: Icon(Icons.save, color: AppColors.accent),
            label: Text(
              '保存して終了する',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.accent),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  int _getUpgradeCount() {
    return wordResults.where((r) => r['toBox'] > r['fromBox']).length;
  }

  int _getDowngradeCount() {
    return wordResults.where((r) => r['toBox'] < r['fromBox']).length;
  }

  int _getBoostCount() {
    return wordResults.where((r) => r['isBoost'] == true).length;
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('学習完了'),
        content: const Text(
          '今回の学習結果を保存して終了します。\n\n'
          'BOX移動が反映され、次回の復習スケジュールに適用されます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleSaveAndExit();
            },
            child: const Text('保存して終了'),
          ),
        ],
      ),
    );
  }

  void _handleSaveAndExit() {
    // ダミー保存処理
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('学習結果を保存しました'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    });
  }
}