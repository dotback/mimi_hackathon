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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 詳細なエラーロギングを追加
  FlutterError.onError = (FlutterErrorDetails details) {
    print('Flutter Framework Error: ${details.exception}');
    print('Stack Trace: ${details.stack}');
    FlutterError.dumpErrorToConsole(details);
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase初期化成功');
  } catch (e) {
    print('Firebase初期化エラー: $e');
  }

  // 環境変数の取得方法も修正
  final geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY');
  Get.put<String>(geminiApiKey, tag: 'geminiApiKey');

  // SharedPreferencesを初期化
  try {
    await SharedPreferences.getInstance();
    print('SharedPreferences初期化成功');
  } catch (e) {
    print('SharedPreferences初期化エラー: $e');
  }

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
      home: const LoginScreen(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: child ?? Container(),
        );
      },
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

// 他のスクリーンやサービスでAPIキーを取得する例は不要なので削除
// APIキーの使用例は各画面で直接実装する
