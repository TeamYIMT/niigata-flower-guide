// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Container(
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
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF3A5A40),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      _buildTextField(hint: 'ユーザー名'),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      _buildTextField(hint: 'Email', keyboardType: TextInputType.emailAddress),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      _buildTextField(hint: 'パスワード', obscureText: true),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      _buildTextField(hint: 'パスワード再入力', obscureText: true),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.06,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: バリデーション→登録API呼び出し
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A5A40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '登録',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF7F4EE),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
