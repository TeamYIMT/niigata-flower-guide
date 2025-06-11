import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 360,
        height: 640,
        child: Scaffold(
          backgroundColor: const Color(0xFFFCF8F2),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Niigata 花図鑑',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A5A40),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '花をきっかけに、新潟の魅力を発見する',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF3A5A40),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'パスワード',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: ログイン処理を実装
                            Navigator.pushReplacementNamed(context, '/');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4D9C67),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'ログイン',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: 新規登録画面への遷移を実装
                            Navigator.pushNamed(context, '/signup');
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: const Text(
                            '新規登録',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF3A5A40),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
