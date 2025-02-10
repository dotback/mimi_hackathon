import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:mimi/logic/services/api_service.dart';
import 'package:mimi/signup/controller/auth_token_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'login/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/foundation.dart' show PlatformDispatcher;

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'env.dart'; // env.dart をインポート

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();

  // 詳細なエラーロギングを追加
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  // Firebase初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  Get.put<String>(Env.geminiApiKey, tag: 'geminiApiKey');

  // AuthServiceをGetに登録
  Get.lazyPut(() => AuthService());

  // グローバルエラーハンドリング
  PlatformDispatcher.instance.onError = (error, stack) {
    return true;
  };

  runApp(const MyApp());
}

Future<void> initServices() async {
  await Get.putAsync(() async => SharedPreferences.getInstance());
  // 他の必要な初期化処理
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MiMi',
      debugShowCheckedModeBanner: false,
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
      initialBinding: BindingsBuilder(() {
        Get.put(AuthTokenController(), permanent: true);
        Get.put(AuthService(), permanent: true);
        Get.put(ApiService(), permanent: true);
      }),
      navigatorKey: Get.key,
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
          maintainState: false,
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
          maintainState: false,
        ),
      ],
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

// 他のスクリーンやサービスでAPIキーを取得する例は不要なので削除
// APIキーの使用例は各画面で直接実装する
