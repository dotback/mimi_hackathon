import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimi/constants/profile_selection.dart';
import 'package:mimi/logic/services/api_service.dart';
import 'package:mimi/signup/controller/auth_token_controller.dart';

import '../data/models/user.dart';
import '../utils/helper.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  final _apiService = ApiService();
  final _nameController = TextEditingController();
  String? _selectedGender;
  final _ageController = TextEditingController();
  DateTime? _selectedBirthday;
  String? _exerciseHabit;
  final _sleepHoursController = TextEditingController();
  bool _isLoading = true;

  Future<void> _initializeProfile() async {
    final controller = Get.find<AuthTokenController>();
    if (controller.token.isEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        await _initializeProfile();
      }
      return;
    }
    if (mounted) {
      await _fetchUserProfile();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _sleepHoursController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userProfile = await _apiService.fetchUserProfile();
      print(userProfile);
      print('_isLoading');
      print(_isLoading);
      print('_isLoading');

      setState(() {
        _nameController.text = userProfile.username;
        _selectedGender = userProfile.gender;
        if (userProfile.birthDate != null) {
          _selectedBirthday = DateTime.tryParse(userProfile.birthDate!);
          if (_selectedBirthday != null) {
            _ageController.text =
                Helper.calculateAge(_selectedBirthday!).toString();
          } else {
            _ageController.text = '';
          }
        } else {
          _selectedBirthday = null;
          _ageController.text = '';
        }
        _exerciseHabit = userProfile.exerciseHabit;
        _sleepHoursController.text = userProfile.sleepHours.toString();
        _isLoading = false;
      });
      print('_isLoading');
      print(_isLoading);
      print('_isLoading');
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('プロフィール情報の取得に失敗しました: $e')),
      );
      print('エラー: $stackTrace');
    }
  }

  _saveProfile() async {
    UpdateUser user = UpdateUser(
      username: _nameController.text,
      gender: _selectedGender,
      birthDate: _selectedBirthday?.toIso8601String(),
      exerciseHabit: _exerciseHabit,
      sleepHours: double.tryParse(_sleepHoursController.text),
    );
    await _apiService.updateUserProfile(user);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('プロフィールを保存しました')),
    );
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
          onPressed: () => Get.back(),
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
                              _buildSleepHoursField(),
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
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage:
                AssetImage('assets/images/user_icon.png') as ImageProvider,
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
        if (Helper.isNullOrEmpty(value)) {
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
      items: const [
        DropdownMenuItem(
          value: '男性',
          child: Text('男性'),
        ),
        DropdownMenuItem(
          value: '女性',
          child: Text('女性'),
        ),
        DropdownMenuItem(
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
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseHabitDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: '運動習慣',
        prefixIcon: const Icon(Icons.fitness_center),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      value: _exerciseHabit,
      items: exerciseHabits
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
    );
  }

  Widget _buildSleepHoursField() {
    return TextFormField(
      controller: _sleepHoursController,
      decoration: InputDecoration(
        labelText: '睡眠時間 (時間)',
        prefixIcon: const Icon(Icons.bedtime),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
        ),
      ),
    );
  }
}
