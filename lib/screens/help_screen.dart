import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      category: '基本的な使い方',
      question: 'ワードLaboとは何ですか？',
      answer: 'ワードLaboは効率的な英単語学習アプリです。ライトナーシステムを使用して、あなたの記憶に合わせて単語を出題し、効果的な復習スケジュールを自動で管理します。',
    ),
    FAQItem(
      category: '基本的な使い方',
      question: '学習の流れを教えてください',
      answer: '1. インプットトレーニング（6語の単語を確認）\n2. チェックタイム（覚えた単語をテスト）\n3. ステージクリアテスト（文章での応用問題）\n\nこの3ステップを繰り返して学習を進めます。',
    ),
    FAQItem(
      category: '基本的な使い方',
      question: 'スワイプ操作はどのように使いますか？',
      answer: 'インプットトレーニングでは：\n• 右スワイプ：「知ってる」→カードを積み上げ\n• 左スワイプ：「念入りに学習」→もう一度学習\n\n画面の60%の高さでスワイプを検知します。',
    ),
    FAQItem(
      category: 'ライトナーシステム',
      question: 'BOXとは何ですか？',
      answer: 'BOXは復習タイミングを管理するシステムです：\n• BOX1：12時間後\n• BOX2：48時間後\n• BOX3：96時間後\n• BOX4：168時間後\n• BOX5：336時間後\n• BOX∞：完全定着（復習不要）',
    ),
    FAQItem(
      category: 'ライトナーシステム',
      question: 'BOXはどのように移動しますか？',
      answer: '基本ルール：\n• 全問正解 → BOX+1\n• 1問でも不正解 → BOX-1\n\n既知語ブースト（2段階昇格）：\n• インプットで「知ってる」\n• 英→日を「自信をもって」正解\n• 日→英を「自信をもって」正解\n→ BOX1→3、BOX2→4に昇格',
    ),
    FAQItem(
      category: 'ライトナーシステム',
      question: '完全定着とは何ですか？',
      answer: 'BOX5で自信を持って全問正解すると、その単語を完全定着（BOX∞）にできます。セッション終了時にダイアログで選択できます。完全定着した単語は二度と出題されません。',
    ),
    FAQItem(
      category: 'テスト・問題',
      question: 'チェックタイムではどんな問題が出ますか？',
      answer: '6語×2問＝12問が出題されます：\n• 英→日（6問）：4択問題、出題時に音声再生\n• 日→英（6問）：入力問題、答え合わせ時に音声再生\n\n各回答で自信度の選択が必要です。',
    ),
    FAQItem(
      category: 'テスト・問題',
      question: 'ステージクリアテストの内容は？',
      answer: '3文×4セット＝12問が出題されます：\n• 前半2セット：英→日（単語を色付き表示、4択）\n• 後半2セット：日→英（4択、手書きなし）\n\n音声再生はありません。文章はあなたの興味・関心に基づいてGPTが生成します。',
    ),
    FAQItem(
      category: '設定・カスタマイズ',
      question: '学習レベルはどのように設定しますか？',
      answer: '単語レベルと文法レベルを別々に設定できます：\n• 小学4年生〜高校中級まで8段階\n• 単語レベル：出題される単語の難易度\n• 文法レベル：例文の難易度\n\n設定はいつでも変更可能です。',
    ),
    FAQItem(
      category: '設定・カスタマイズ',
      question: '手書き入力の使い方は？',
      answer: 'チェックタイムの日→英問題で使用できます：\n• キーボード/手書きの切り替えボタンあり\n• ペン機能のみ（消しゴムなし）\n• Google ML Kitで認識\n\n手書きが苦手な場合はキーボードをお使いください。',
    ),
    FAQItem(
      category: 'アカウント・データ',
      question: 'ゲストユーザーとして始めた場合は？',
      answer: 'ゲストユーザーでも学習データは保存されます。設定画面から後でGoogleやAppleアカウントと連携することで、デバイス間でデータを同期できます。',
    ),
    FAQItem(
      category: 'アカウント・データ',
      question: '学習データはどこに保存されますか？',
      answer: '各単語のBOX状態とユーザー基本情報がクラウドに保存されます。詳細な正誤履歴は保存されません。ローカルには一時データのみ保存され、サーバー送信後は削除されます。',
    ),
    FAQItem(
      category: '音声・技術',
      question: '音声が再生されません',
      answer: '以下をご確認ください：\n• デバイスの音量設定\n• アプリの効果音設定（設定画面）\n• インターネット接続\n\n5000語分の音声データを事前準備していますが、一部の単語で音声がない場合があります。',
    ),
    FAQItem(
      category: '音声・技術',
      question: 'オフラインでも使えますか？',
      answer: 'インプットトレーニングとチェックタイムは完全にオフライン対応しています。ステージクリアテストはGPTによる文章生成のためオンライン必須です。',
    ),
    FAQItem(
      category: 'トラブルシューティング',
      question: 'アプリが重い・動作が遅い',
      answer: '以下をお試しください：\n• アプリの再起動\n• 設定画面でキャッシュクリア\n• デバイスの再起動\n• ストレージ容量の確認\n\n改善しない場合はお問い合わせください。',
    ),
    FAQItem(
      category: 'トラブルシューティング',
      question: '学習データが消えてしまいました',
      answer: 'アカウント連携済みの場合、ログアウト後に再ログインで復元される可能性があります。ゲストユーザーの場合、アプリ削除やデータクリアで復元できません。定期的なアカウント連携をお勧めします。',
    ),
  ];

  String _selectedCategory = 'すべて';
  List<String> get _categories {
    final categories = _faqItems.map((item) => item.category).toSet().toList();
    categories.insert(0, 'すべて');
    return categories;
  }

  List<FAQItem> get _filteredItems {
    if (_selectedCategory == 'すべて') {
      return _faqItems;
    }
    return _faqItems.where((item) => item.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ヘルプ'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade600,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryFilter(),
            Expanded(child: _buildFAQList()),
            _buildContactButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Column(
        children: [
          Icon(
            Icons.help_outline,
            size: 48,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'よくある質問',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '分からないことがあれば、まずはこちらをご確認ください',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.purple : Colors.white,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.purple : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAQList() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ListView.builder(
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          return _buildFAQItem(_filteredItems[index]);
        },
      ),
    );
  }

  Widget _buildFAQItem(FAQItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.help_outline,
            color: Colors.purple,
            size: 20,
          ),
        ),
        title: Text(
          item.question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          item.category,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              item.answer,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            '解決しない問題がありますか？',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/contact'),
              icon: const Icon(Icons.mail_outline),
              label: const Text(
                'お問い合わせ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String category;
  final String question;
  final String answer;

  FAQItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}