import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import '../../components/my_button.dart';
import '../../signup/controller/flow_controller.dart';
import '../../signup/controller/sign_up_controller.dart';
import '../../components/my_textfield.dart';
import '../../screens/home_screen.dart';

class SignUpTwo extends StatefulWidget {
  final bool isNarrow;
  const SignUpTwo({Key? key, this.isNarrow = false}) : super(key: key);

  @override
  State<SignUpTwo> createState() => _SignUpTwoState();
}

class _SignUpTwoState extends State<SignUpTwo> {
  final usernameController = TextEditingController();
  final birthdateController = TextEditingController();
  final ageController = TextEditingController();

  String? selectedGender;
  String? selectedExerciseHabit;
  String? selectedSleepHabit;

  final List<String> genderOptions = ['男性', '女性', 'その他'];
  final List<String> exerciseHabitOptions = [
    '週に1-2回',
    '週に3-4回',
    '週に5回以上',
    'ほとんどしない'
  ];
  final List<String> sleepHabitOptions = ['6時間未満', '6-7時間', '7-8時間', '8時間以上'];

  SignUpController signUpController = Get.find<SignUpController>();
  FlowController flowController = Get.find<FlowController>();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
        ageController.text = _calculateAge(picked).toString();
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ユーザー名
              _buildSectionTitle('ユーザー名'),
              MyTextField(
                controller: usernameController,
                hintText: 'ユーザー名を入力',
                onChanged: (String value) {
                  signUpController.setName(value);
                },
                obscureText: false,
              ),

              // 性別
              _buildSectionTitle('性別'),
              _buildDropdown(
                value: selectedGender,
                items: genderOptions,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                hint: '性別を選択',
              ),

              // 生年月日と年齢のプルダウン入力
              _buildSectionTitle('生年月日'),
              Row(
                children: [
                  // 年プルダウン
                  Expanded(
                    child: _buildYearDropdown(),
                  ),
                  const SizedBox(width: 8),
                  // 月プルダウン
                  Expanded(
                    child: _buildMonthDropdown(),
                  ),
                  const SizedBox(width: 8),
                  // 日プルダウン
                  Expanded(
                    child: _buildDayDropdown(),
                  ),
                ],
              ),

              // 運動習慣
              _buildSectionTitle('運動習慣'),
              _buildDropdown(
                value: selectedExerciseHabit,
                items: exerciseHabitOptions,
                onChanged: (value) {
                  setState(() {
                    selectedExerciseHabit = value;
                  });
                },
                hint: '運動習慣を選択',
              ),

              // 睡眠習慣
              _buildSectionTitle('睡眠習慣'),
              _buildDropdown(
                value: selectedSleepHabit,
                items: sleepHabitOptions,
                onChanged: (value) {
                  setState(() {
                    selectedSleepHabit = value;
                  });
                },
                hint: '睡眠習慣を選択',
              ),

              const SizedBox(height: 20),
              MyButton(
                buttonText: '登録',
                onPressed: () async {
                  // 入力値の検証
                  if (_validateInputs()) {
                    // SignUpControllerに追加情報を設定
                    signUpController.setAdditionalUserInfo(
                      username: usernameController.value.text,
                      gender: selectedGender!,
                      birthdate: birthdateController.value.text,
                      age: int.parse(ageController.value.text),
                      exerciseHabit: selectedExerciseHabit!,
                      sleepHabit: selectedSleepHabit!,
                    );

                    // ユーザー登録を実行
                    bool isRegistered = await signUpController.registerUser(
                      signUpController.email.toString(),
                      signUpController.password.toString(),
                    );

                    if (isRegistered) {
                      // 登録成功時の処理
                      Get.snackbar("成功", "ユーザー登録が完了しました");
                      Get.offAll(() => HomeScreen());
                    } else {
                      Get.snackbar("エラー", "登録に失敗しました");
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateInputs() {
    if (usernameController.value.text.isEmpty) {
      Get.snackbar("エラー", "ユーザー名を入力してください");
      return false;
    }
    if (selectedGender == null) {
      Get.snackbar("エラー", "性別を選択してください");
      return false;
    }
    if (birthdateController.value.text.isEmpty) {
      Get.snackbar("エラー", "生年月日を選択してください");
      return false;
    }
    if (selectedExerciseHabit == null) {
      Get.snackbar("エラー", "運動習慣を選択してください");
      return false;
    }
    if (selectedSleepHabit == null) {
      Get.snackbar("エラー", "睡眠習慣を選択してください");
      return false;
    }
    return true;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: HexColor("#8d8d8d"),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    required String hint,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint),
            isExpanded: true,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  // 年齢計算メソッド
  Widget _buildYearDropdown() {
    final currentYear = DateTime.now().year;
    final years = List.generate(100, (index) => currentYear - index - 10);

    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: '年',
        border: OutlineInputBorder(),
      ),
      value: null,
      hint: Text('年'),
      items: years.map((year) {
        return DropdownMenuItem(
          value: year,
          child: Text(year.toString()),
        );
      }).toList(),
      onChanged: (selectedYear) {
        setState(() {
          // 年齢自動計算
          ageController.text = (DateTime.now().year - selectedYear!).toString();
        });
      },
    );
  }

  Widget _buildMonthDropdown() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: '月',
        border: OutlineInputBorder(),
      ),
      value: null,
      hint: Text('月'),
      items: List.generate(12, (index) {
        return DropdownMenuItem(
          value: index + 1,
          child: Text('${index + 1}月'),
        );
      }),
      onChanged: (selectedMonth) {
        // 月選択時の処理
      },
    );
  }

  Widget _buildDayDropdown() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: '日',
        border: OutlineInputBorder(),
      ),
      value: null,
      hint: Text('日'),
      items: List.generate(31, (index) {
        return DropdownMenuItem(
          value: index + 1,
          child: Text('${index + 1}日'),
        );
      }),
      onChanged: (selectedDay) {
        // 日選択時の処理
      },
    );
  }
}
