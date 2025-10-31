import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  String _selectedCategory = 'バグ報告';
  bool _isLoading = false;

  final List<String> _categories = [
    'バグ報告',
    '機能要望',
    '学習内容について',
    'アカウント・課金',
    'その他',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // ダミー送信処理
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('送信完了'),
          content: const Text(
            'お問い合わせを受け付けました。\n'
            '通常2-3営業日以内にご返信いたします。\n\n'
            'お急ぎの場合は、ヘルプページもご確認ください。',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('お問い合わせ'),
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
              Colors.blue.shade600,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildForm(),
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
            Icons.mail_outline,
            size: 48,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 16),
          Text(
            'お問い合わせ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ご質問・ご要望・不具合報告など\nお気軽にお問い合わせください',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.all(20),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('お問い合わせ内容'),
            const SizedBox(height: 12),
            _buildCategorySelector(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('お名前'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hintText: 'お名前を入力してください',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'お名前を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            _buildSectionTitle('メールアドレス'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hintText: 'example@domain.com',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'メールアドレスを入力してください';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return '正しいメールアドレスを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            _buildSectionTitle('件名'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _subjectController,
              hintText: '件名を入力してください',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '件名を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            _buildSectionTitle('詳細内容'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _messageController,
              hintText: '詳しい内容をお書きください...\n\n'
                     '【バグ報告の場合】\n'
                     '• 発生した問題\n'
                     '• 操作手順\n'
                     '• 端末情報（iPhone/Android等）\n\n'
                     '【機能要望の場合】\n'
                     '• 欲しい機能の詳細\n'
                     '• 使用場面',
              maxLines: 8,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '詳細内容を入力してください';
                }
                if (value.length < 10) {
                  return '10文字以上で入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            
            _buildSubmitButton(),
            const SizedBox(height: 16),
            
            _buildPrivacyNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCategory = value);
            }
          },
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    '送信する',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                '個人情報の取り扱いについて',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'いただいた個人情報は、お問い合わせへの回答のためのみに使用し、'
            '適切に管理いたします。詳細は',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/privacy'),
            child: Text(
              'プライバシーポリシー',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Text(
            'をご確認ください。',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}