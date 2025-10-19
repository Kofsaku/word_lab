import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade700,
              Colors.green.shade50,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildContent(),
            ],
          ),
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
            Icons.privacy_tip,
            size: 48,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'プライバシーポリシー',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '最終更新日：2024年10月6日',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIntroduction(),
          const SizedBox(height: 24),
          _buildSection(
            '1. 収集する情報',
            '当社は、ワードLaboの提供にあたり、以下の情報を収集します。\n\n'
            '【アカウント情報】\n'
            '• お名前（ニックネーム）\n'
            '• メールアドレス\n'
            '• 生年月日\n'
            '• 居住地（都道府県）\n'
            '• GoogleまたはAppleアカウント情報（連携時）\n\n'
            '【学習データ】\n'
            '• 学習進捗情報\n'
            '• 単語の習得状況（BOX レベル）\n'
            '• 学習レベル設定\n'
            '• 興味・関心分野\n\n'
            '【利用情報】\n'
            '• アプリの利用状況\n'
            '• 機能の使用頻度\n'
            '• エラーログ\n'
            '• 端末情報（OS、バージョン等）',
          ),
          _buildSection(
            '2. 情報の利用目的',
            '収集した情報は、以下の目的で利用します。\n\n'
            '• ワードLaboサービスの提供・運営\n'
            '• 学習進捗の管理・同期\n'
            '• 個人に最適化された学習体験の提供\n'
            '• カスタマーサポートの提供\n'
            '• サービスの改善・新機能の開発\n'
            '• 利用状況の分析\n'
            '• 重要なお知らせの配信\n'
            '• 不正利用の防止・検出',
          ),
          _buildSection(
            '3. 情報の共有・開示',
            '当社は、以下の場合を除き、収集した個人情報を第三者に提供しません。\n\n'
            '【第三者提供を行う場合】\n'
            '• ユーザーの同意がある場合\n'
            '• 法令に基づく場合\n'
            '• 人の生命・身体の安全確保のために必要な場合\n'
            '• 当社の権利・財産の保護のために必要な場合\n\n'
            '【業務委託先への提供】\n'
            '• クラウドストレージサービス（Firebase）\n'
            '• AI サービス（GPT API）\n'
            '• 決済代行サービス\n'
            '• 分析ツール\n\n'
            '※委託先には適切な個人情報保護の契約を締結しています。',
          ),
          _buildSection(
            '4. データの保存期間',
            '• アカウント情報：退会まで\n'
            '• 学習データ：退会後1年間\n'
            '• ログデータ：3ヶ月間\n'
            '• お問い合わせ履歴：2年間\n\n'
            'ただし、法令により保存が義務付けられている場合は、該当期間中保存します。',
          ),
          _buildSection(
            '5. データセキュリティ',
            '当社は、個人情報の安全性確保のため、以下の対策を実施しています。\n\n'
            '• データの暗号化\n'
            '• アクセス制御\n'
            '• 定期的なセキュリティ監査\n'
            '• 従業員への教育・研修\n'
            '• セキュリティインシデント対応体制の整備',
          ),
          _buildSection(
            '6. ユーザーの権利',
            'ユーザーは、自身の個人情報について以下の権利を有します。\n\n'
            '• 開示請求権：どのような情報が保存されているかの確認\n'
            '• 訂正・削除権：情報の修正・削除の要求\n'
            '• 利用停止権：情報処理の停止要求\n'
            '• データポータビリティ権：他サービスへのデータ移行\n\n'
            'これらの権利行使については、アプリ内設定またはお問い合わせフォームよりご連絡ください。',
          ),
          _buildSection(
            '7. 第三者サービスの利用',
            'ワードLaboでは、以下の第三者サービスを利用しています。各サービスのプライバシーポリシーもご確認ください。\n\n'
            '【Firebase（Google）】\n'
            '• 認証・データベース・ホスティング\n'
            '• プライバシーポリシー：https://policies.google.com/privacy\n\n'
            '【OpenAI GPT API】\n'
            '• 文章生成サービス\n'
            '• プライバシーポリシー：https://openai.com/privacy/\n\n'
            '【Google ML Kit】\n'
            '• 手書き文字認識\n'
            '• プライバシーポリシー：https://policies.google.com/privacy',
          ),
          _buildSection(
            '8. 未成年者の個人情報',
            '13歳未満のお子様が本サービスを利用される場合は、保護者の方の同意が必要です。保護者の方は、お子様の個人情報の取り扱いについて確認し、必要に応じて訂正・削除を求めることができます。',
          ),
          _buildSection(
            '9. 国際的なデータ転送',
            '当社が利用する一部のサービス（Firebase、OpenAI等）では、データが日本国外のサーバーに保存される場合があります。これらの国・地域においても、適切なセキュリティ対策のもとで情報を保護します。',
          ),
          _buildSection(
            '10. Cookieとトラッキング',
            '本サービスでは、利用状況の分析・サービス改善のため、以下の技術を使用する場合があります。\n\n'
            '• Cookie\n'
            '• ローカルストレージ\n'
            '• 分析ツール\n\n'
            'これらの技術により個人を特定することはありません。',
          ),
          _buildSection(
            '11. プライバシーポリシーの変更',
            '当社は、必要に応じて本プライバシーポリシーを変更する場合があります。重要な変更については、アプリ内通知またはメールにてお知らせします。継続して本サービスをご利用いただくことで、変更後のプライバシーポリシーに同意したものとみなします。',
          ),
          _buildSection(
            '12. お問い合わせ',
            '個人情報の取り扱いに関するご質問・ご要望は、以下の方法でお問い合わせください。\n\n'
            '• アプリ内お問い合わせフォーム\n'
            '• 設定画面の「アカウント削除」機能\n\n'
            '通常2-3営業日以内にご回答いたします。',
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'お客様の個人情報保護について',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '当社は、お客様の個人情報を大切に扱い、適切に保護することをお約束します。'
                  'ご不明な点がございましたら、いつでもお気軽にお問い合わせください。',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              '制定日：2024年1月1日\n'
              '最終改定日：2024年10月6日\n\n'
              'ワードLabo運営チーム',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroduction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'はじめに',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ワードLabo（以下「当社」といいます）は、お客様の個人情報保護の重要性を認識し、'
            '個人情報の保護に関する法律（個人情報保護法）を遵守し、'
            'お客様の個人情報を適切に取り扱うことをお約束します。',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}