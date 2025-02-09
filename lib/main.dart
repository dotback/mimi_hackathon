import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
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
    print('Flutter Framework Error: ${details.exception}');
    print('Stack Trace: ${details.stack}');
    FlutterError.dumpErrorToConsole(details);
  };

  // Firebase初期化
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase初期化成功');
  } catch (e) {
    print('Firebase初期化エラー: $e');
  }

  Get.put<String>(Env.geminiApiKey, tag: 'geminiApiKey');

  // AuthServiceをGetに登録
  Get.lazyPut(() => AuthService());

  // グローバルエラーハンドリング
  PlatformDispatcher.instance.onError = (error, stack) {
    print('キャッチされていないエラー: $error');
    print('スタックトレース: $stack');
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
    print('MyAppのビルド開始');

    return GetMaterialApp(
      title: 'みんなの認知機能アプリ',
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
      navigatorKey: Get.key,
    );
  }
}

// 他のスクリーンやサービスでAPIキーを取得する例は不要なので削除
// APIキーの使用例は各画面で直接実装する
