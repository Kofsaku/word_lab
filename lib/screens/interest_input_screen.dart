import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class InterestInputScreen extends StatefulWidget {
  final String stageId;
  final List<Map<String, dynamic>> checkTimeResults;

  const InterestInputScreen({
    super.key,
    required this.stageId,
    required this.checkTimeResults,
  });

  @override
  State<InterestInputScreen> createState() => _InterestInputScreenState();
}

class _InterestInputScreenState extends State<InterestInputScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool _isInputValid = false;

  final List<String> _exampleInterests = [
    '最新のテクノロジーやAIの発展について学びたい',
    'ビジネスで使える実践的な英語を身につけたい',
    '海外旅行で現地の人と自然に会話できるようになりたい',
    '映画や音楽を字幕なしで楽しみたい',
    '仕事でグローバルなチームと協働したい',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    _controller.addListener(() {
      setState(() {
        _isInputValid = _controller.text.trim().length >= 5;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToStageTest() {
    if (!_isInputValid) return;

    // 興味関心を保存（実際のアプリではデータベースやSharedPreferencesに保存）
    final userInterest = _controller.text.trim();
    
    Navigator.pushReplacementNamed(
      context,
      '/stage-test',
      arguments: {
        'stageId': widget.stageId,
        'checkTimeResults': widget.checkTimeResults,
        'userInterest': userInterest,
      },
    );
  }

  void _setExampleInterest(String interest) {
    _controller.text = interest;
    setState(() {
      _isInputValid = true;
    });
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
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 40),
                        _buildInputSection(),
                        const SizedBox(height: 30),
                        _buildExampleSection(),
                        const SizedBox(height: 40),
                        _buildContinueButton(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // キャラクター表示エリア（new_req仕様）
        _buildCharacterArea(),
        const SizedBox(height: 30),
        
        // ステージクリアテストの説明文（new_req仕様）
        _buildTestDescription(),
      ],
    );
  }

  Widget _buildCharacterArea() {
    return Container(
      width: double.infinity,
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
          // キャラクター（ピコタン）
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.3),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: AppColors.warning,
                width: 3,
              ),
            ),
            child: Icon(
              Icons.psychology,
              size: 60,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ピコタン',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'よくがんばったね！\n次はステージクリアテストだよ！',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTestDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.quiz,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'ステージクリアテスト',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'あなたの興味・関心に基づいて、学習した単語を使った文章問題を出題します。\n\n'
            '全12問：\n'
            '• 前半6問：英語→日本語（4択）\n'
            '• 後半6問：日本語→英語（4択）\n\n'
            '音声再生はありません。',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: 10),
              const Text(
                'フリーワード入力',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'あなたの興味・関心分野を自由に入力してください。\n'
            'より面白い問題文が生成されます！',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            maxLines: 4,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: '例：宇宙探索、料理、スポーツ、映画、音楽、旅行、IT技術、環境問題、キャラクター名、有名人、映画やドラマ、アニメのタイトルなど...',
              hintStyle: TextStyle(
                color: AppColors.textPrimary.withOpacity(0.6),
              ),
              filled: true,
              fillColor: AppColors.surface.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: AppColors.textPrimary.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: AppColors.textPrimary.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              counterText: '${_controller.text.length}/200',
              counterStyle: TextStyle(
                color: _controller.text.length > 180 
                    ? AppColors.incorrect 
                    : AppColors.textPrimary.withOpacity(0.6),
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          if (_controller.text.isNotEmpty && !_isInputValid) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 5),
                Text(
                  '5文字以上入力してください',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExampleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '例えばこんな興味・関心',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _exampleInterests.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _setExampleInterest(_exampleInterests[index]),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.surface.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _exampleInterests[index].length > 20
                          ? '${_exampleInterests[index].substring(0, 20)}...'
                          : _exampleInterests[index],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isInputValid ? _navigateToStageTest : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isInputValid 
                  ? AppColors.accent 
                  : AppColors.textSecondary.withOpacity(0.3),
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: _isInputValid ? 8 : 2,
              shadowColor: AppColors.accent.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.quiz, color: AppColors.textPrimary, size: 24),
                const SizedBox(width: 8),
                Text(
                  _isInputValid ? 'ステージクリアテストへ' : '興味・関心を入力してください',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            // スキップして直接テストへ
            Navigator.pushReplacementNamed(
              context,
              '/stage-test',
              arguments: {
                'stageId': widget.stageId,
                'checkTimeResults': widget.checkTimeResults,
                'userInterest': '',
              },
            );
          },
          child: Text(
            'スキップして進む',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}