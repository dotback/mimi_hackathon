import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // ロゴ
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: Icon(Icons.account_circle,
                    size: 60, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              Text(
                'みんなの認知機能アプリへようこそ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = true;
                      });
                    },
                    child: Text('ログイン'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isLogin ? Colors.blue : Colors.grey[300],
                      foregroundColor: _isLogin ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = false;
                      });
                    },
                    child: Text('新規登録'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !_isLogin ? Colors.blue : Colors.grey[300],
                      foregroundColor: !_isLogin ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'メールアドレス',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'パスワード',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // ログインまたは新規登録の処理
                  Get.back();
                },
                child: Text('メールアドレスで${_isLogin ? 'ログイン' : '新規登録'}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // パスワードを忘れた場合の処理
                  Get.back();
                },
                child: Text('パスワードをお忘れの方はこちら'),
              ),
              SizedBox(height: 10),
              Text('または'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Googleでログインの処理
                  Get.back();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.g_mobiledata, color: Colors.white),
                    SizedBox(width: 5),
                    Text('Googleでログイン', style: TextStyle(color: Colors.white)),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Appleでログインの処理
                  Get.back();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.apple, color: Colors.white),
                    SizedBox(width: 5),
                    Text('Appleでログイン', style: TextStyle(color: Colors.white)),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
