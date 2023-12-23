import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/signUp.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyHomePage(title: '勤怠管理システム')),
      );
    } on FirebaseAuthException catch (e) {
      // スナックバーを使用してエラーメッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('メールアドレスorパスワードが間違っています。'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
    void _navigateToSignup() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => SignupPage()),
      );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ログイン')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'メールアドレス'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'パスワード'),
              obscureText: true,
            ),
            ElevatedButton(onPressed: _login, child: Text('ログイン')),
             TextButton(
              onPressed: _navigateToSignup,
              child: Text('アカウントをお持ちでない方はこちら'),
            ),
          ],
        ),
      ),
    );
  }
}
