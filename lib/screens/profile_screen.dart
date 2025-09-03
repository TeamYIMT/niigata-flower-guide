import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:niigata_flower_guide/pages/unity_webview_page.dart';

import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'profileedit_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _primaryGreen = Color(0xFF4CAF50);
  static const _bgLight = Color(0xFFFCF8F2);
  static const _borderRed = Color(0xFFE57373);
  static const _avatarBg = Color(0xFFE8F5E9);

  // ログアウト確認
  Future<void> _showLogoutDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ログアウト'),
          content: const Text('ログアウトしますか？'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('ログアウト'),
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await authProvider.signOut();
                if (success && context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ゲスト → メール/パスワード変換
  Future<void> _showLinkAccountDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('アカウント作成'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('ゲストアカウントを正式なアカウントに変換しますか？'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'メールアドレス',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'メールアドレスを入力してください';
                    }
                    final ok = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$')
                        .hasMatch(value);
                    if (!ok) return 'メールアドレスの形式が正しくありません';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'パスワード',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'パスワードを入力してください';
                    }
                    if (value.length < 6) {
                      return 'パスワードは6文字以上で入力してください';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('変換'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  final success = await authProvider.linkAnonymousWithEmail(
                    emailController.text.trim(),
                    passwordController.text,
                  );
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('アカウントの変換が完了しました'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = screenWidth * 0.9;
    final cardPadding = screenWidth * 0.06;

    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;

            return SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                  child: Container(
                    width: cardWidth,
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // アバター
                        CircleAvatar(
                          radius: screenWidth * 0.15,
                          backgroundColor: _avatarBg,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? Icon(
                                  authProvider.isAnonymous
                                      ? Icons.person_outline
                                      : Icons.person,
                                  size: screenWidth * 0.2,
                                  color: _primaryGreen,
                                )
                              : null,
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        // 名前
                        Text(
                          user?.displayName ??
                              (authProvider.isAnonymous
                                  ? 'ゲストユーザー'
                                  : 'ユーザー'),
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            color: _primaryGreen,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),

                        // メール
                        Text(
                          user?.email ??
                              (authProvider.isAnonymous ? 'ゲストアカウント' : ''),
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.black87,
                          ),
                        ),

                        // ゲスト警告
                        if (authProvider.isAnonymous) ...[
                          SizedBox(height: screenHeight * 0.02),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.orange[700], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'ゲストアカウントです。データを保持するには正式なアカウントを作成してください。',
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: screenHeight * 0.05),

                        // ボタン群
                        if (!authProvider.isAnonymous) ...[
                          _buildButton(
                            context,
                            Icons.edit,
                            'プロフィール編集',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileEditScreen(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: screenHeight * 0.02),
                        ],
                        if (authProvider.isAnonymous) ...[
                          _buildButton(
                            context,
                            Icons.person_add,
                            'アカウント作成',
                            () => _showLinkAccountDialog(
                                context, authProvider),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                        ],
                        _buildButton(
                          context,
                          Icons.help_outline,
                          'ヘルプ',
                          () {
                            // TODO: ヘルプ画面
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildButton(
                          context,
                          Icons.logout,
                          'ログアウト',
                          () => _showLogoutDialog(context, authProvider),
                        ),
                        if (!authProvider.isAnonymous) ...[
                          SizedBox(height: screenHeight * 0.02),
                          _buildButton(
                            context,
                            Icons.lock,
                            'パスワードリセット',
                            () async {
                              final email = user?.email;
                              if (email != null) {
                                final ok = await authProvider
                                    .sendPasswordResetEmail(email);
                                if (ok && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'パスワードリセットメールを送信しました'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // 下ナビ
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 4,
        selectedItemColor: _primaryGreen,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'マップ'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'ARカメラ'),
          BottomNavigationBarItem(icon: Icon(Icons.collections), label: 'コレクション'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'プロフィール'),
        ],
        onTap: (index) {
          switch (index) {
            case 0: // ホーム
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              );
              break;
            case 2: // ARカメラ
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UnityWebViewPage()),
              );
              break;
            default:
              // 必要に応じて実装
              break;
          }
        },
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return OutlinedButton.icon(
      icon: Icon(icon, color: _primaryGreen),
      label: Text(
        label,
        style: TextStyle(
          color: _primaryGreen,
          fontSize: screenWidth * 0.045,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: _bgLight,
        side: const BorderSide(color: _borderRed),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.05,
        ),
        minimumSize: Size(screenWidth * 0.7, screenHeight * 0.06),
      ),
      onPressed: onPressed,
    );
  }
}
