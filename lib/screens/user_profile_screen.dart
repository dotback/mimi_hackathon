import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../data/models/user.dart';
import '../utils/helper.dart';
import '../screens/home_screen.dart';

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
  String? _sleepHabit;
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

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

      // SharedPreferencesからプロフィール情報を取得
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _nameController.text = prefs.getString('name') ?? '';
        _selectedGender = prefs.getString('gender') ?? '未設定';
        _ageController.text = prefs.getString('age') ?? '0';
        _selectedBirthday = prefs.getString('birthday') != null
            ? DateTime.parse(prefs.getString('birthday')!)
            : null;

        // 運動習慣の初期値を修正
        String? storedExerciseHabit = prefs.getString('exerciseHabit');
        _exerciseHabit = storedExerciseHabit != null &&
                ['ほぼ毎日', '週3-4回', '週1-2回', 'ほとんどしない']
                    .contains(storedExerciseHabit)
            ? storedExerciseHabit
            : null;

        // 睡眠時間の初期値を修正
        String? storedSleepHabit = prefs.getString('sleepHabit');
        _sleepHabit = storedSleepHabit != null &&
                ['4時間未満', '4-6時間', '6-8時間', '8時間以上'].contains(storedSleepHabit)
            ? storedSleepHabit
            : null;

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
    // デバッグ用のprint文を追加
    print('_saveProfile method called');

    // フォームキーを使用してバリデーションを行う
    if (_formKey.currentState == null) {
      print('Form key is null');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // ユーザーモデルに合わせて保存
      User user = User(
        name: _nameController.text,
        gender: _selectedGender ?? '未設定',
        age: int.tryParse(_ageController.text) ?? 0,
        birthday: _selectedBirthday ?? DateTime.now(),
        exerciseHabit: _exerciseHabit ?? 'ほとんどしない',
        sleepHours: _sleepHabit == '4時間未満'
            ? 3.0
            : _sleepHabit == '4-6時間'
                ? 5.0
                : _sleepHabit == '6-8時間'
                    ? 7.0
                    : 9.0, // 8時間以上
        email: prefs.getString('email') ?? 'guest@example.com',
      );

      // すべての情報を保存
      await prefs.setString('name', user.name);
      await prefs.setString('gender', user.gender);
      await prefs.setString('age', user.age.toString());
      await prefs.setString('birthday', user.birthday.toIso8601String());
      await prefs.setString('exerciseHabit', user.exerciseHabit);
      await prefs.setString('sleepHabit', _sleepHabit ?? '6-8時間');
      await prefs.setString('sleepHours', user.sleepHours.toString());

      print('Profile saved successfully');

      // プロフィールを再読み込み
      await _fetchUserProfile();

      // ダイアログで成功メッセージを表示
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('プロフィール更新'),
          content: const Text('プロフィールが正常に更新されました。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error saving profile: $e');

      // エラー時のダイアログ
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('エラー'),
          content: Text('プロフィールの更新中にエラーが発生しました: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              primary: Colors.blue,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('ユーザープロフィール'),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // GetXを使用したナビゲーション
            Get.offAll(() => const HomeScreen());
          },
        ),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // プロフィールヘッダー
                    _buildProfileHeader(),
                    const SizedBox(height: 24),

                    // プロフィールフォーム
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 氏名
                              _buildNameField(),
                              const SizedBox(height: 16),

                              // 性別
                              _buildGenderDropdown(),
                              const SizedBox(height: 16),

                              // 生年月日と年齢
                              _buildBirthdayAndAgeRow(),
                              const SizedBox(height: 16),

                              // 運動習慣
                              _buildExerciseHabitDropdown(),
                              const SizedBox(height: 16),

                              // 睡眠時間
                              _buildSleepHabitDropdown(),
                              const SizedBox(height: 24),

                              // 保存ボタン
                              _buildSaveButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: const AssetImage('assets/images/user_icon.png')
                as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text
                      : 'ゲストユーザー',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'プロフィール管理',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: '氏名',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '氏名を入力してください';
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: '性別',
        prefixIcon: const Icon(Icons.wc),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
    );
  }

  Widget _buildBirthdayAndAgeRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: TextEditingController(
              text: _selectedBirthday != null
                  ? Helper.formatDate(_selectedBirthday!)
                  : '',
            ),
            decoration: InputDecoration(
              labelText: '生年月日',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
            decoration: InputDecoration(
              labelText: '年齢',
              prefixIcon: const Icon(Icons.cake),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.number,
            readOnly: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '年齢を計算してください';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseHabitDropdown() {
    // 運動習慣のオプションを定義
    final exerciseHabitOptions = ['未選択', 'ほぼ毎日', '週3-4回', '週1-2回', 'ほとんどしない'];

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: '運動習慣',
        prefixIcon: const Icon(Icons.fitness_center),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      value: _exerciseHabit ?? '未選択',
      items: exerciseHabitOptions
          .map((habit) => DropdownMenuItem(
                value: habit,
                child: Text(habit),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _exerciseHabit = value == '未選択' ? null : value;
        });
      },
      validator: (value) {
        if (value == null || value == '未選択') {
          return '運動習慣を選択してください';
        }
        return null;
      },
    );
  }

  Widget _buildSleepHabitDropdown() {
    // 睡眠時間のオプションを定義
    final sleepHabitOptions = ['未選択', '4時間未満', '4-6時間', '6-8時間', '8時間以上'];

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: '睡眠時間',
        prefixIcon: const Icon(Icons.bedtime),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'プロフィールを保存',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
