// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _primaryGreen = Color(0xFF4CAF50);
  static const _bgLight = Color(0xFFFCF8F2);
  static const _borderRed = Color(0xFFE57373);
  static const _avatarBg = Color(0xFFE8F5E9);

  // ログアウト確認ダイアログ
  Future<void> _showLogoutDialog(BuildContext context, AuthProvider authProvider) async {
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
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ログアウト'),
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await authProvider.signOut();
                if (success && context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 匿名アカウント変換ダイアログ
  Future<void> _showLinkAccountDialog(BuildContext context, AuthProvider authProvider) async {
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
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'メールアドレスの形式が正しくありません';
                    }
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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
                      const SnackBar(
                        content: Text('アカウントの変換が完了しました'),
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
    final cardWidth = screenWidth * 0.9; // 画面幅の90%
    final cardPadding = screenWidth * 0.06; // 画面幅の6%

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F2),
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
                        // プロフィール画像
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
                        
                        // 表示名
                        Text(
                          user?.displayName ?? 
                              (authProvider.isAnonymous ? 'ゲストユーザー' : 'ユーザー'),
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            color: _primaryGreen,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        
                        // メールアドレス
                        Text(
                          user?.email ?? (authProvider.isAnonymous ? 'ゲストアカウント' : ''),
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.black87,
                          ),
                        ),
                        
                        // 匿名ユーザー向けの注意
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
                          _buildButton(context, Icons.edit, 'プロフィール編集', () {
                            Navigator.pushNamed(context, '/profileedit');
                          }),
                          SizedBox(height: screenHeight * 0.02),
                        ],
                        
                        if (authProvider.isAnonymous) ...[
                          _buildButton(context, Icons.person_add, 'アカウント作成', () {
                            _showLinkAccountDialog(context, authProvider);
                          }),
                          SizedBox(height: screenHeight * 0.02),
                        ],
                        
                        _buildButton(context, Icons.help_outline, 'ヘルプ', () {
                          // TODO: ヘルプ画面の実装
                        }),
                        SizedBox(height: screenHeight * 0.02),
                        
                        _buildButton(context, Icons.logout, 'ログアウト', () {
                          _showLogoutDialog(context, authProvider);
                        }),
                        
                        if (!authProvider.isAnonymous) ...[
                          SizedBox(height: screenHeight * 0.02),
                          _buildButton(context, Icons.lock, 'パスワードリセット', () async {
                            if (user?.email != null) {
                              final success = await authProvider.sendPasswordResetEmail(user!.email!);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('パスワードリセットメールを送信しました'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          }),
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
            case 0:
              Navigator.pushReplacementNamed(context, '/');
              break;
            case 1:
              Navigator.pushNamed(context, '/map');
              break;
            case 2:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ARカメラ機能は開発中です')),
              );
              break;
            case 3:
              Navigator.pushNamed(context, '/collection');
              break;
            case 4:
              break;
          }
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
