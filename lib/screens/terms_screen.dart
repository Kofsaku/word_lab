import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('利用規約'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
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
            Icons.description,
            size: 48,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 16),
          Text(
            'ワードLabo 利用規約',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '最終更新日：2024年10月6日',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
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
        color: AppColors.textPrimary,
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
          _buildSection(
            '第1条（適用）',
            'この利用規約（以下「本規約」といいます。）は、当社が提供するワードLabo（以下「本サービス」といいます。）の利用条件を定めるものです。登録ユーザーの皆さま（以下「ユーザー」といいます。）には、本規約に従って、本サービスをご利用いただきます。',
          ),
          _buildSection(
            '第2条（利用登録）',
            '1. 本サービスにおいて、登録希望者が当社の定める方法によって利用登録を申請し、当社がこれを承認することによって、利用登録が完了するものとします。\n\n'
            '2. 当社は、利用登録の申請者に以下の事由があると判断した場合、利用登録の申請を承認しないことがあり、その理由については一切の開示義務を負わないものとします。\n'
            '（1）利用登録の申請に際して虚偽の事項を届け出た場合\n'
            '（2）本規約に違反したことがある者からの申請である場合\n'
            '（3）その他、当社が利用登録を相当でないと判断した場合',
          ),
          _buildSection(
            '第3条（ユーザーIDおよびパスワードの管理）',
            '1. ユーザーは、自己の責任において、本サービスのユーザーIDおよびパスワードを適切に管理するものとします。\n\n'
            '2. ユーザーは、いかなる場合にも、ユーザーIDおよびパスワードを第三者に譲渡または貸与し、もしくは第三者と共用することはできません。\n\n'
            '3. ユーザーIDとパスワードの組み合わせが登録情報と一致してログインされた場合には、そのユーザーIDを登録しているユーザー自身による利用とみなします。',
          ),
          _buildSection(
            '第4条（料金および支払方法）',
            '1. ユーザーは、本サービスの有料部分の対価として、当社が別途定め、本ウェブサイトに表示する料金を、当社が指定する方法により支払うものとします。\n\n'
            '2. ユーザーが料金の支払を遅滞した場合には、ユーザーは年14.6％の割合による遅延損害金を支払うものとします。',
          ),
          _buildSection(
            '第5条（禁止事項）',
            'ユーザーは、本サービスの利用にあたり、以下の行為をしてはなりません。\n\n'
            '（1）法令または公序良俗に違反する行為\n'
            '（2）犯罪行為に関連する行為\n'
            '（3）本サービスの内容等、本サービスに含まれる著作権、商標権ほか知的財産権を侵害する行為\n'
            '（4）当社、ほかのユーザー、またはその他第三者のサーバーまたはネットワークの機能を破壊したり、妨害したりする行為\n'
            '（5）本サービスによって得られた情報を商業的に利用する行為\n'
            '（6）当社のサービスの運営を妨害するおそれのある行為\n'
            '（7）不正アクセスをし、またはこれを試みる行為\n'
            '（8）他のユーザーに関する個人情報等を収集または蓄積する行為\n'
            '（9）不正な目的を持って本サービスを利用する行為\n'
            '（10）本サービスの他のユーザーまたはその他の第三者に不利益、損害、不快感を与える行為\n'
            '（11）その他当社が不適切と判断する行為',
          ),
          _buildSection(
            '第6条（本サービスの提供の停止等）',
            '1. 当社は、以下のいずれかの事由があると判断した場合、ユーザーに事前に通知することなく本サービスの全部または一部の提供を停止または中断することができるものとします。\n\n'
            '（1）本サービスにかかるコンピュータシステムの保守点検または更新を行う場合\n'
            '（2）地震、落雷、火災、停電または天災などの不可抗力により、本サービスの提供が困難となった場合\n'
            '（3）コンピュータまたは通信回線等が事故により停止した場合\n'
            '（4）その他、当社が本サービスの提供が困難と判断した場合\n\n'
            '2. 当社は、本サービスの提供の停止または中断により、ユーザーまたは第三者が被ったいかなる不利益または損害についても、一切の責任を負わないものとします。',
          ),
          _buildSection(
            '第7条（著作権）',
            '1. ユーザーは、自ら著作権等の必要な知的財産権を有するか、または必要な権利者の許諾を得た文章、画像や映像等の情報に関してのみ、本サービスを利用し、投稿ないしアップロードすることができるものとします。\n\n'
            '2. ユーザーが本サービスを利用して投稿ないしアップロードした文章、画像、映像等の著作権については、当該ユーザーその他既存の権利者に留保されるものとします。ただし、当社は、本サービスを利用して投稿ないしアップロードされた文章、画像、映像等について、本サービスの改良、品質の向上、または不備の補正等ならびに本サービスの周知宣伝等に必要な範囲で利用できるものとし、ユーザーは、この利用に関して、著作者人格権を行使しないものとします。\n\n'
            '3. 前項本文の定めるものを除き、本サービスおよび本サービスに関連する一切の情報についての著作権およびその他の知的財産権はすべて当社または当社にその利用を許諾した権利者に帰属し、ユーザーは無断で複製、譲渡、貸与、翻訳、改変、転載、公衆送信（送信可能化を含みます。）、伝送、配布、出版、営業使用等をしてはならないものとします。',
          ),
          _buildSection(
            '第8条（利用制限および登録抹消）',
            '1. 当社は、ユーザーが以下のいずれかに該当する場合には、事前の通知なく、投稿データを削除し、ユーザーに対して本サービスの全部もしくは一部の利用を制限しまたはユーザーとしての登録を抹消することができるものとします。\n\n'
            '（1）本規約のいずれかの条項に違反した場合\n'
            '（2）登録事項に虚偽の事実があることが判明した場合\n'
            '（3）料金等の支払債務の不履行があった場合\n'
            '（4）当社からの連絡に対し、一定期間返答がない場合\n'
            '（5）本サービスについて、最終の利用から一定期間利用がない場合\n'
            '（6）その他、当社が本サービスの利用を適当でないと判断した場合\n\n'
            '2. 当社は、本条に基づき当社が行った行為によりユーザーに生じた損害について、一切の責任を負いません。',
          ),
          _buildSection(
            '第9条（退会）',
            'ユーザーは、当社の定める退会手続により、本サービスから退会できるものとします。',
          ),
          _buildSection(
            '第10条（保証の否認および免責事項）',
            '1. 当社は、本サービスに事実上または法律上の瑕疵（安全性、信頼性、正確性、完全性、有効性、特定の目的への適合性、セキュリティなどに関する欠陥、エラーやバグ、権利侵害などを含みます。）がないことを明示的にも黙示的にも保証しておりません。\n\n'
            '2. 当社は、本サービスに起因してユーザーに生じたあらゆる損害について一切の責任を負いません。ただし、本サービスに関する当社とユーザーとの間の契約（本規約を含みます。）が消費者契約法に定める消費者契約となる場合、この免責規定は適用されません。\n\n'
            '3. 前項ただし書に定める場合であっても、当社は、当社の過失（重過失を除きます。）による債務不履行または不法行為によりユーザーに生じた損害のうち特別な事情から生じた損害（当社またはユーザーが損害発生につき予見し、または予見し得た場合を含みます。）について一切の責任を負いません。また、当社の過失（重過失を除きます。）による債務不履行または不法行為によりユーザーに生じた損害の賠償は、ユーザーから当該損害が発生した月に受領した利用料の額を上限とします。\n\n'
            '4. 当社は、本サービスに関して、ユーザーと他のユーザーまたは第三者との間において生じた取引、連絡または紛争等について一切責任を負いません。',
          ),
          _buildSection(
            '第11条（サービス内容の変更等）',
            '当社は、ユーザーに通知することなく、本サービスの内容を変更しまたは本サービスの提供を中止することができるものとし、これによってユーザーに生じた損害について一切の責任を負いません。',
          ),
          _buildSection(
            '第12条（利用規約の変更）',
            '当社は、必要と判断した場合には、ユーザーに通知することなくいつでも本規約を変更することができるものとします。なお、本規約の変更後、本サービスの利用を開始した場合には、当該ユーザーは変更後の規約に同意したものとみなします。',
          ),
          _buildSection(
            '第13条（個人情報の取扱い）',
            '当社は、本サービスの利用によって取得する個人情報については、当社「プライバシーポリシー」に従い適切に取り扱うものとします。',
          ),
          _buildSection(
            '第14条（通知または連絡）',
            'ユーザーと当社との間の通知または連絡は、当社の定める方法によって行うものとします。当社は、ユーザーから、当社が別途定める方式に従った変更届け出がない限り、現在登録されている連絡先が有効なものとみなして当該連絡先へ通知または連絡を行い、これらは、発信時にユーザーへ到達したものとみなします。',
          ),
          _buildSection(
            '第15条（権利義務の譲渡の禁止）',
            'ユーザーは、当社の書面による事前の承諾なく、利用契約上の地位または本規約に基づく権利もしくは義務を第三者に譲渡し、または担保に供することはできません。',
          ),
          _buildSection(
            '第16条（適用法・裁判管轄）',
            '1. 本規約の解釈にあたっては、日本法を適用するものとします。\n\n'
            '2. 本サービスに関して紛争が生じた場合には、当社の本店所在地を管轄する裁判所を専属的合意管轄とします。',
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              '以上\n\n'
              '制定日：2024年1月1日\n'
              '最終改定日：2024年10月6日\n\n'
              '本規約に関するお問い合わせは、アプリ内のお問い合わせフォームよりご連絡ください。',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
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