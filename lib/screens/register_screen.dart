import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  
  String? _selectedYear;
  String? _selectedMonth;
  String? _selectedDay;
  String? _selectedPrefecture;
  
  bool _isLoading = false;
  bool _canProceed = false;

  // 年度選択用（現在年から過去30年）
  List<String> get _years {
    final currentYear = DateTime.now().year;
    return List.generate(30, (index) => (currentYear - index).toString());
  }

  // 月選択用
  List<String> get _months {
    return List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  }

  // 日選択用
  List<String> get _days {
    return List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
  }

  // 都道府県一覧
  final List<String> _prefectures = [
    '北海道', '青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県',
    '茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県',
    '新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県',
    '静岡県', '愛知県', '三重県', '滋賀県', '京都府', '大阪府', '兵庫県',
    '奈良県', '和歌山県', '鳥取県', '島根県', '岡山県', '広島県', '山口県',
    '徳島県', '香川県', '愛媛県', '高知県', '福岡県', '佐賀県', '長崎県',
    '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _checkCanProceed() {
    final canProceed = _nameController.text.isNotEmpty &&
        _nicknameController.text.isNotEmpty &&
        _selectedYear != null &&
        _selectedMonth != null &&
        _selectedDay != null &&
        _selectedPrefecture != null;
    
    if (canProceed != _canProceed) {
      setState(() {
        _canProceed = canProceed;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate() || !_canProceed) return;
    
    setState(() => _isLoading = true);
    
    // ダミー登録処理
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, '/level-select');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildInputFields(),
                  const SizedBox(height: 40),
                  _buildButtons(),
                ],
              ),
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
          width: 80,
          height: 80,
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
            Icons.person_add,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '会員登録',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'あなたの情報を教えてください',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('学習者のお名前（非公開）'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: _buildInputDecoration(
            labelText: 'お名前',
            prefixIcon: Icons.person,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'お名前を入力してください';
            }
            return null;
          },
          onChanged: (value) => _checkCanProceed(),
        ),
        const SizedBox(height: 24),
        
        _buildSectionTitle('ニックネーム（公開）'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nicknameController,
          decoration: _buildInputDecoration(
            labelText: 'ニックネーム',
            prefixIcon: Icons.badge,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'ニックネームを入力してください';
            }
            return null;
          },
          onChanged: (value) => _checkCanProceed(),
        ),
        const SizedBox(height: 24),
        
        _buildSectionTitle('生年月日'),
        const SizedBox(height: 8),
        _buildDatePickers(),
        const SizedBox(height: 24),
        
        _buildSectionTitle('居住地'),
        const SizedBox(height: 8),
        _buildPrefectureDropdown(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(prefixIcon),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(
        color: AppColors.warning,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            value: _selectedYear,
            items: _years,
            hint: '年',
            onChanged: (value) {
              setState(() => _selectedYear = value);
              _checkCanProceed();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdown(
            value: _selectedMonth,
            items: _months,
            hint: '月',
            onChanged: (value) {
              setState(() => _selectedMonth = value);
              _checkCanProceed();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdown(
            value: _selectedDay,
            items: _days,
            hint: '日',
            onChanged: (value) {
              setState(() => _selectedDay = value);
              _checkCanProceed();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrefectureDropdown() {
    return _buildDropdown(
      value: _selectedPrefecture,
      items: _prefectures,
      hint: '都道府県を選択',
      onChanged: (value) {
        setState(() => _selectedPrefecture = value);
        _checkCanProceed();
      },
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor: AppColors.surface,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _canProceed && !_isLoading ? _handleRegister : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _canProceed ? AppColors.warning : Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: AppColors.textPrimary)
                : const Text(
                    '確定',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _canProceed && !_isLoading 
                ? () => Navigator.pushReplacementNamed(context, '/level-select')
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _canProceed ? AppColors.correct : Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'トレーニングのスタート',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '※情報は後から変更できます',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}