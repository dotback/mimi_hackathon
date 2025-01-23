import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'login/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // SharedPreferencesを初期化
  await SharedPreferences.getInstance();

  // AuthServiceをGetに登録
  Get.lazyPut(() => AuthService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'みんなの認知機能アプリ',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.murechoTextTheme(),
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
      ],
      home: const LoginScreen(),
    );
  }
}
