import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:mimi/constants/profile_selection.dart';
import 'package:mimi/data/models/user.dart';
import 'package:mimi/logic/services/api_service.dart';
import 'package:mimi/screens/home_screen.dart';

import '../components/my_button.dart';
import '../services/auth_service.dart';
import '../utils/helper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _sleepHoursController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedBirthDate;
  String? _exerciseHabit;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Get.find<AuthService>();
      final apiService = Get.find<ApiService>();
      await authService.signUp(
          _emailController.text.trim(), _passwordController.text.trim());
      final User user = User(
        username: _nameController.text,
        gender: _selectedGender.toString(),
        age: 0,
        birthDate: DateFormat('yyyy-MM-dd')
            .format(_selectedBirthDate ?? DateTime.now()),
        exerciseHabit: _exerciseHabit!,
        sleepHours: double.parse(_sleepHoursController.text),
        email: _emailController.text,
      );
      await apiService.createUser(user);
      Get.offAll(() => const HomeScreen());
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _ageController.text = Helper.calculateAge(picked).toString();
      });
    }
  }

  Widget _buildDropdown({
    required String labelText,
    required List<String> options,
    required String? currentValue,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(color: HexColor("#8d8d8d")),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: HexColor("#8d8d8d")),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: HexColor("#8d8d8d")),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: HexColor("#44564a"), width: 2),
        ),
      ),
      value: currentValue,
      items: options
          .map((option) => DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  style: GoogleFonts.poppins(),
                ),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isNarrow = screenWidth < 600;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // 背景画像
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/images/R6A_0329.jpg',
                    fit: BoxFit.cover,
                    height: screenHeight * 0.3, // 画面の30%
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.3,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: HexColor("#ffffff").withOpacity(0.9),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isNarrow ? 20 : 50,
                          vertical: 30,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "新規登録",
                                style: GoogleFonts.poppins(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: HexColor("#4f4f4f"),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildFormField(
                                labelText: "メールアドレス",
                                controller: _emailController,
                                hintText: "hello@gmail.com",
                                prefixIcon: Icons.mail_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'メールアドレスを入力してください';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildFormField(
                                labelText: "パスワード",
                                controller: _passwordController,
                                hintText: "*************",
                                prefixIcon: Icons.lock_outline,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'パスワードを入力してください';
                                  }
                                  if (value.length < 6) {
                                    return 'パスワードは6文字以上にしてください';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildFormField(
                                labelText: "氏名",
                                controller: _nameController,
                                hintText: "山田 太郎",
                                prefixIcon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '氏名を入力してください';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildDropdown(
                                labelText: "性別",
                                options: genders,
                                currentValue: _selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return '性別を選択してください';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _buildFormField(
                                      labelText: "生年月日",
                                      controller: TextEditingController(
                                        text: _selectedBirthDate != null
                                            ? Helper.formatDate(
                                                _selectedBirthDate!)
                                            : '',
                                      ),
                                      hintText: "生年月日を選択",
                                      prefixIcon: Icons.calendar_today,
                                      readOnly: true,
                                      onTap: () => _selectBirthday(context),
                                      validator: (value) {
                                        if (_selectedBirthDate == null) {
                                          return '生年月日を選択してください';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildFormField(
                                      labelText: "年齢",
                                      controller: _ageController,
                                      readOnly: true,
                                      hintText: "自動計算",
                                      prefixIcon: Icons.numbers,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildDropdown(
                                labelText: "運動習慣",
                                options: exerciseHabits,
                                currentValue: _exerciseHabit,
                                onChanged: (value) {
                                  setState(() {
                                    _exerciseHabit = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return '運動習慣を選択してください';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildFormField(
                                controller: _sleepHoursController,
                                labelText: "睡眠時間",
                                hintText: "7.5",
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d{1,2}(\.|(\.\d))?$')),
                                ],
                              ),
                              //   validator: (value) {
                              //     if (value == null || value == '未選択') {
                              //       return '睡眠時間を選択してください';
                              //     }
                              //     return null;
                              //   },
                              // ),
                              const SizedBox(height: 24),
                              _isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: HexColor("#44564a"),
                                      ),
                                    )
                                  : SizedBox(
                                      width: double.infinity,
                                      child: MyButton(
                                        buttonText: 'アカウント作成',
                                        onPressed: _signUp,
                                      ),
                                    ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'すでにアカウントをお持ちの方は',
                                      style: GoogleFonts.poppins(
                                        color: HexColor("#8d8d8d"),
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: Text(
                                        'ログイン',
                                        style: GoogleFonts.poppins(
                                          color: HexColor("#44564a"),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String labelText,
    required TextEditingController controller,
    String? hintText,
    IconData? prefixIcon,
    bool obscureText = false,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    List<FilteringTextInputFormatter>? inputFormatters,
    bool readOnly = false,
    void Function()? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: HexColor("#8d8d8d"),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            hintStyle: GoogleFonts.poppins(
              fontSize: 15,
              color: HexColor("#8d8d8d"),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: HexColor("#e8e8e8")),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: HexColor("#44564a")),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
        ),
        if (validator != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
            child: Text(
              validator(controller.text) ?? '',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
