import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import '../data/dummy_data.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final completedStages = DummyData.stages.where((s) => s.isCleared).length;
    final totalStages = DummyData.stages.length;
    final reviewWords = DummyData.getReviewWords().length;
    final totalWords = DummyData.words.where((w) => w.isMemorized).length;

    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(totalWords),
                const SizedBox(height: 20),
                _buildProgressCard(completedStages, totalStages),
                const SizedBox(height: 20),
                _buildMenuGrid(context, reviewWords),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int totalWords) {
    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 10) return 'おはよう！';
      if (hour < 15) return 'こんにちは！';
      if (hour < 18) return 'がんばってるね！';
      return 'こんばんは！';
    }

    String getEncouragement(int words) {
      if (words == 0) return 'さあ、はじめよう！';
      if (words < 10) return 'いいスタートだね！';
      if (words < 30) return 'すごい！その調子(ちょうし)！';
      if (words < 50) return 'めちゃくちゃがんばってる！';
      return 'えいご名人(めいじん)だ！';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getGreeting(),
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              getEncouragement(totalWords),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: const RiveAnimation.asset(
                'assets/animations/pikotan_animation.riv',
                fit: BoxFit.contain,
              ),
            ),
            if (totalWords >= 10)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    size: 12,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  IconData _getAvatarIcon(int words) {
    if (words >= 50) return Icons.school;
    if (words >= 30) return Icons.emoji_events;
    if (words >= 10) return Icons.celebration;
    return Icons.face;
  }

  Color _getAvatarColor(int words) {
    if (words >= 50) return AppColors.primary;
    if (words >= 30) return AppColors.warning;
    if (words >= 10) return AppColors.accent;
    return AppColors.correct;
  }

  Widget _buildProgressCard(int completed, int total) {
    final progress = total > 0 ? completed / total : 0.0;
    final percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              const Icon(
                Icons.rocket_launch,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '学習の進み具合',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text(
                '$percentage',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '%',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'クリア $completed',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'ぜんぶで $total ステージ',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 20,
                  backgroundColor: AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.warning,
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    percentage >= 50 ? 'すごい！' : 'がんばれ！',
                    style: const TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, int reviewCount) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // メインメニュー4つ（new_req仕様）
            _buildMainMenuSection(context, reviewCount),
            const SizedBox(height: 20),
            // 右上設定・プレミアムボタン
            _buildTopRightButtons(context),
            const SizedBox(height: 20),
            // フッターリンク
            _buildFooterLinks(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenuSection(BuildContext context, int reviewCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // トレーニングの続き
          _buildMainMenuItem(
            icon: Icons.play_circle_fill,
            title: 'トレーニングの続き',
            subtitle: '前回の続きから学習を開始',
            color: AppColors.accent,
            onTap: () => Navigator.pushNamed(context, '/stage-select'),
            isMain: true,
          ),
          const SizedBox(height: 16),
          
          // 学習レベルの選択
          _buildMainMenuItem(
            icon: Icons.tune,
            title: '学習レベルの選択',
            subtitle: '単語・文法レベルを設定',
            color: AppColors.correct,
            onTap: () => Navigator.pushNamed(context, '/level-select'),
          ),
          const SizedBox(height: 16),
          
          // 学習のあしあと
          _buildMainMenuItem(
            icon: Icons.analytics,
            title: '学習のあしあと',
            subtitle: '学習履歴と進捗を確認',
            color: AppColors.warning,
            onTap: () => Navigator.pushNamed(context, '/history'),
          ),
          const SizedBox(height: 16),
          
          // ヘルプ
          _buildMainMenuItem(
            icon: Icons.help_outline,
            title: 'ヘルプ',
            subtitle: '使い方とよくある質問',
            color: AppColors.primary,
            onTap: () => Navigator.pushNamed(context, '/help'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isMain = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.textPrimary,
                size: isMain ? 28 : 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMain ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRightButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 設定ボタン
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/settings'),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.settings,
              color: AppColors.textPrimary.withOpacity(0.7),
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // プレミアムボタン
        GestureDetector(
          onTap: () {
            // プレミアム画面へ遷移（未実装）
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('プレミアム機能は開発中です')),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                SizedBox(width: 4),
                Text(
                  'プレミアム',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/terms'),
            child: Text(
              '利用規約',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/privacy'),
            child: Text(
              'プライバシーポリシー',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    bool isMain = false,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isMain)
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.star,
                  size: 100,
                  color: AppColors.textSecondary.withOpacity(0.1),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: isMain ? 50 : 45,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMain ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}