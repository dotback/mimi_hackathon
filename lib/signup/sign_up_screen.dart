import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen.dart';
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

  String? _selectedGender;
  DateTime? _selectedBirthday;
  String? _exerciseHabit;
  String? _sleepHabit;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase認証でユーザー作成
      final authService = Get.find<AuthService>();
      final user = await authService.signUp(
          _emailController.text.trim(), _passwordController.text.trim());

      if (user != null) {
        // ローカルストレージにユーザー情報を保存
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', _emailController.text.trim());
        await prefs.setString('name', _nameController.text);
        await prefs.setString('gender', _selectedGender ?? '未設定');
        await prefs.setString('age', _ageController.text);
        await prefs.setString(
            'birthday', _selectedBirthday?.toIso8601String() ?? '');
        await prefs.setString('exerciseHabit', _exerciseHabit ?? '');

        // 睡眠時間の保存を変更
        await prefs.setString('sleepHabit', _sleepHabit ?? '6-8時間');
        await prefs.setString(
            'sleepHours',
            _sleepHabit == '4時間未満'
                ? '3.0'
                : _sleepHabit == '4-6時間'
                    ? '5.0'
                    : _sleepHabit == '6-8時間'
                        ? '7.0'
                        : '9.0' // 8時間以上
            );

        // ホーム画面に遷移
        Get.offAll(() => const HomeScreen());
      } else {
        _showErrorSnackBar('アカウント作成に失敗しました');
      }
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
        _selectedBirthday = picked;
        _ageController.text = Helper.calculateAge(picked).toString();
      });
    }
  }

  // 睡眠時間のドロップダウンウィジェットを追加
  Widget _buildSleepHabitDropdown() {
    // 睡眠時間のオプションを定義
    final sleepHabitOptions = ['未選択', '4時間未満', '4-6時間', '6-8時間', '8時間以上'];

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: '睡眠時間',
        border: OutlineInputBorder(),
      ),
      value: _sleepHabit ?? '未選択',
      items: sleepHabitOptions
          .map((habit) => DropdownMenuItem(
                value: habit,
                child: Text(habit),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _sleepHabit = value == '未選択' ? null : value;
        });
      },
      validator: (value) {
        if (value == null || value == '未選択') {
          return '睡眠時間を選択してください';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規アカウント登録'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // メールアドレス入力
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'メールアドレス',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'メールアドレスを入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // パスワード入力
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'パスワード',
                        border: OutlineInputBorder(),
                      ),
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

                    // 氏名入力
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '氏名',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '氏名を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 性別選択
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '性別',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedGender,
                      items: ['男性', '女性', 'その他']
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
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

                    // 生年月日と年齢
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: '生年月日',
                              border: OutlineInputBorder(),
                            ),
                            readOnly: true,
                            controller: TextEditingController(
                              text: _selectedBirthday != null
                                  ? Helper.formatDate(_selectedBirthday!)
                                  : '',
                            ),
                            onTap: () => _selectBirthday(context),
                            validator: (value) {
                              if (_selectedBirthday == null) {
                                return '生年月日を選択してください';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(
                              labelText: '年齢',
                              border: OutlineInputBorder(),
                            ),
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 運動習慣
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '運動習慣',
                        border: OutlineInputBorder(),
                      ),
                      value: _exerciseHabit,
                      items: ['ほぼ毎日', '週3-4回', '週1-2回', 'ほとんどしない']
                          .map((habit) => DropdownMenuItem(
                                value: habit,
                                child: Text(habit),
                              ))
                          .toList(),
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

                    // 睡眠時間のドロップダウンを追加
                    _buildSleepHabitDropdown(),
                    const SizedBox(height: 24),

                    // 登録ボタン
                    ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'アカウント作成',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
