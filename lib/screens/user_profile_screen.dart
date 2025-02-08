import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user.dart';
import '../utils/helper.dart';
import '../services/profile_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _nameController = TextEditingController();
  String? _selectedGender;
  final _ageController = TextEditingController();
  DateTime? _selectedBirthday;
  String? _exerciseHabit;
  final _sleepHoursController = TextEditingController();
  bool _isLoading = true;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // APIからプロフィール情報を取得
      User user = await _profileService.fetchUserProfile();

      setState(() {
        _nameController.text = user.name;
        _selectedGender = user.gender;
        _ageController.text = user.age.toString();
        _selectedBirthday = user.birthday;
        _exerciseHabit = user.exerciseHabit;
        _sleepHoursController.text = user.sleepHours.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('プロフィール情報の取得に失敗しました: $e')),
      );
    }
  }

  _saveProfile() async {
    final formState = Form.of(context);
    if (formState.validate()) {
      final prefs = await SharedPreferences.getInstance();

      // ユーザーモデルに合わせて保存
      User user = User(
        name: _nameController.text,
        gender: _selectedGender ?? '未設定',
        age: int.tryParse(_ageController.text) ?? 0,
        birthday: _selectedBirthday ?? DateTime.now(),
        exerciseHabit: _exerciseHabit ?? '',
        sleepHours: double.tryParse(_sleepHoursController.text) ?? 0.0,
        email: prefs.getString('email') ?? 'guest@example.com',
      );

      await prefs.setString('name', user.name);
      await prefs.setString('gender', user.gender);
      await prefs.setString('age', user.age.toString());
      await prefs.setString('birthday', user.birthday.toIso8601String());
      await prefs.setString('exerciseHabit', user.exerciseHabit);
      await prefs.setString('sleepHours', user.sleepHours.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('プロフィールを保存しました')),
      );
    }
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
        _ageController.text = Helper.calculateAge(picked).toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザープロフィール'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUserProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 氏名
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '氏名',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (Helper.isNullOrEmpty(value)) {
                          return '氏名を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 性別
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '性別',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedGender,
                      items: [
                        const DropdownMenuItem(
                          value: '未設定',
                          child: Text('未設定'),
                        ),
                        const DropdownMenuItem(
                          value: '男性',
                          child: Text('男性'),
                        ),
                        const DropdownMenuItem(
                          value: '女性',
                          child: Text('女性'),
                        ),
                        const DropdownMenuItem(
                          value: 'その他',
                          child: Text('その他'),
                        ),
                      ],
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
                            controller: TextEditingController(
                              text: _selectedBirthday != null
                                  ? Helper.formatDate(_selectedBirthday!)
                                  : '',
                            ),
                            decoration: const InputDecoration(
                              labelText: '生年月日',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
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
                            keyboardType: TextInputType.number,
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

                    // 睡眠時間
                    TextFormField(
                      controller: _sleepHoursController,
                      decoration: const InputDecoration(
                        labelText: '睡眠時間 (時間)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (Helper.isNullOrEmpty(value)) {
                          return '睡眠時間を入力してください';
                        }
                        double? hours = double.tryParse(value!);
                        if (hours == null || hours < 0 || hours > 24) {
                          return '有効な睡眠時間を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 保存ボタン
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('プロフィールを保存'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _sleepHoursController.dispose();
    super.dispose();
  }
}
