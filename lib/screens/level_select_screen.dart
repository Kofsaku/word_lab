import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  String? _selectedWordLevel;
  String? _selectedGrammarLevel;
  bool _isLoading = false;

  // 8段階のレベル定義
  final List<Map<String, String>> _levels = [
    {'id': 'elementary_4', 'name': '小学4年生レベル'},
    {'id': 'elementary_5', 'name': '小学5年生レベル'},
    {'id': 'elementary_6', 'name': '小学6年生レベル'},
    {'id': 'junior_1', 'name': '中学1年生レベル'},
    {'id': 'junior_2', 'name': '中学2年生レベル'},
    {'id': 'junior_3', 'name': '中学3年生レベル'},
    {'id': 'high_1', 'name': '高校基礎レベル'},
    {'id': 'high_2', 'name': '高校中級レベル'},
  ];

  bool get _canProceed => _selectedWordLevel != null && _selectedGrammarLevel != null;

  Future<void> _handleStart() async {
    if (!_canProceed) return;
    
    setState(() => _isLoading = true);
    
    // ダミー保存処理
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildLevelSelections(),
                const SizedBox(height: 40),
                _buildStartButton(),
                const SizedBox(height: 20),
                _buildNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.tune,
            size: 50,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'レベル設定',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textOnPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'あなたに合ったレベルを選択してください',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLevelSelections() {
    return Column(
      children: [
        _buildLevelCard(
          title: '学習する単語のレベル',
          subtitle: '出題される単語の難易度を設定します',
          selectedValue: _selectedWordLevel,
          onChanged: (value) {
            setState(() => _selectedWordLevel = value);
          },
          icon: Icons.book,
          color: AppColors.accent,
        ),
        const SizedBox(height: 24),
        _buildLevelCard(
          title: 'あなたの文法レベル',
          subtitle: '例文の難易度を設定します',
          selectedValue: _selectedGrammarLevel,
          onChanged: (value) {
            setState(() => _selectedGrammarLevel = value);
          },
          icon: Icons.school,
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildLevelCard({
    required String title,
    required String subtitle,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedValue != null ? color : AppColors.border,
                  width: 2,
                ),
              ),
              child: DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: const InputDecoration(
                  hintText: 'レベルを選択してください',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _levels.map((level) {
                  return DropdownMenuItem<String>(
                    value: level['id'],
                    child: Text(
                      level['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                dropdownColor: AppColors.surface,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _canProceed && !_isLoading ? _handleStart : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _canProceed ? AppColors.warning : Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: _canProceed ? 4 : 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: AppColors.textOnPrimary)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_arrow,
                    size: 28,
                    color: AppColors.textOnPrimary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '学習をスタート！',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.accent,
            size: 24,
          ),
          const SizedBox(height: 8),
          const Text(
            '注意事項',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• レベルは学習を始めた後でも変更できます\n'
            '• 最初は少し易しめのレベルから始めることをおすすめします\n'
            '• ステージ選択はありません。レベル選択のみです',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}