import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  double _textSize = 1.0;
  String _selectedDifficulty = '標準';
  bool _isGuestUser = true; // ダミー：ゲストユーザーかどうか

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.transparent,
              child: const Text(
                'アプリの設定を変更できます',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
            // new_req仕様のメニュー項目
            _buildSection(
              'アカウント管理',
              [
                _buildAccountLinkingTile(),
                _buildActionTile(
                  'アカウント削除',
                  'すべてのデータが削除されます',
                  Icons.delete_forever,
                  AppColors.incorrect,
                  () => _showAccountDeleteDialog(context),
                ),
                _buildActionTile(
                  'ログアウトする',
                  'アカウントからログアウト',
                  Icons.logout,
                  AppColors.warning,
                  () => _showLogoutDialog(context),
                ),
              ],
            ),
            _buildSection(
              'プレミアム機能',
              [
                _buildPurchaseRestoreTile(),
              ],
            ),
            _buildSection(
              '学習設定',
              [
                _buildDifficultySelector(),
                _buildTextSizeSlider(),
              ],
            ),
            _buildSection(
              'サウンド・通知',
              [
                _buildSwitchTile(
                  '効果音',
                  'タップ音や正解音を再生',
                  _soundEnabled,
                  Icons.volume_up,
                  (value) => setState(() => _soundEnabled = value),
                ),
                _buildSwitchTile(
                  '通知',
                  '学習リマインダーを受け取る',
                  _notificationsEnabled,
                  Icons.notifications,
                  (value) => setState(() => _notificationsEnabled = value),
                ),
              ],
            ),
            _buildSection(
              'アプリ情報',
              [
                _buildInfoTile('バージョン', '1.0.0'),
                _buildInfoTile('開発者', 'Word Learning Team'),
                _buildActionTile(
                  'ライセンス',
                  'オープンソースライセンス',
                  Icons.description,
                  Colors.black87,
                  () => _showLicensePage(context),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: value ? AppColors.primary.withOpacity(0.3) : AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: value ? AppColors.primary : Colors.black87,
        ),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.black87,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '難易度',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ['簡単', '標準', '難しい'].map((difficulty) {
              final isSelected = _selectedDifficulty == difficulty;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDifficulty = difficulty),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary 
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        difficulty,
                        style: TextStyle(
                          color: isSelected ? AppColors.surface : AppColors.textPrimary,
                          fontWeight: isSelected 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSizeSlider() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '文字サイズ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(_textSize * 100).toInt()}%',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: _textSize,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              onChanged: (value) => setState(() => _textSize = value),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'A',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              Text(
                'A',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.border,
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(
          color: Colors.black87,
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('学習データをリセット'),
        content: const Text(
          'すべての学習進捗がクリアされます。\nこの操作は取り消せません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(context, '学習データをリセットしました');
            },
            child: const Text(
              'リセット',
              style: TextStyle(color: AppColors.incorrect),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showLicensePage(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Word Learning',
      applicationVersion: '1.0.0',
    );
  }

  // new_req仕様の新しいメソッド
  Widget _buildAccountLinkingTile() {
    return _isGuestUser 
        ? _buildActionTile(
            'アカウント連携',
            'GoogleやAppleアカウントと連携',
            Icons.link,
            AppColors.accent,
            () => _showAccountLinkingDialog(context),
          )
        : ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.correct.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.correct,
              ),
            ),
            title: const Text('アカウント連携済み'),
            subtitle: Text(
              'sample@example.com',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          );
  }

  Widget _buildPurchaseRestoreTile() {
    return _buildActionTile(
      Theme.of(context).platform == TargetPlatform.iOS
          ? '購入を復元'
          : '定期購入を管理',
      Theme.of(context).platform == TargetPlatform.iOS
          ? '以前の購入を復元します'
          : 'Google Playで管理します',
      Icons.restore,
      AppColors.primary,
      () => _handlePurchaseRestore(context),
    );
  }

  void _showAccountLinkingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アカウント連携'),
        content: const Text(
          'ゲストアカウントをGoogleまたはAppleアカウントと連携しますか？\n\n'
          '連携することで、デバイスを変更しても学習データを引き継げます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('後で'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(context, 'アカウント連携機能は開発中です');
            },
            child: const Text('連携する'),
          ),
        ],
      ),
    );
  }

  void _showAccountDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アカウント削除'),
        content: const Text(
          '本当にアカウントを削除しますか？\n\n'
          'すべての学習データが完全に削除され、復元できません。\n'
          'この操作は取り消せません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleAccountDelete(context);
            },
            child: const Text(
              '削除する',
              style: TextStyle(color: AppColors.incorrect),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text(
          'ログアウトしますか？\n\n'
          '学習データはクラウドに保存されているため、再ログイン時に復元されます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout(context);
            },
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );
  }

  void _handlePurchaseRestore(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      _showSnackBar(context, '購入履歴を確認中...');
      // iOS購入復元処理（ダミー）
      Future.delayed(const Duration(seconds: 2), () {
        _showSnackBar(context, '復元可能な購入はありませんでした');
      });
    } else {
      _showSnackBar(context, 'Google Playストアへ遷移します...');
      // Android定期購入管理（ダミー）
    }
  }

  void _handleAccountDelete(BuildContext context) {
    _showSnackBar(context, 'アカウントを削除しています...');
    // ダミー削除処理
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    });
  }

  void _handleLogout(BuildContext context) {
    _showSnackBar(context, 'ログアウトしています...');
    // ダミーログアウト処理
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    });
  }
}