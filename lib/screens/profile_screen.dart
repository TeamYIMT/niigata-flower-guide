// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _primaryGreen = Color(0xFF4CAF50);
  static const _bgLight = Color(0xFFFCF8F2);
  static const _borderRed = Color(0xFFE57373);
  static const _avatarBg = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    return Center(
      // 画面全体をスマホサイズで固定
      child: SizedBox(
        width: 360,
        height: 640,
        child: Scaffold(
          backgroundColor: const Color(0xFFFCF8F2),
          body: SafeArea(
            // LayoutBuilder で親の SizedBox（360×640）の幅を取得
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final horizontalMargin = screenWidth * 0.05;
                final cardWidth = screenWidth - horizontalMargin * 2;
                final cardPadding = screenWidth * 0.06;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: screenWidth * 0.05),
                      Container(
                        width: cardWidth,
                        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
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
                            CircleAvatar(
                              radius: screenWidth * 0.13,
                              backgroundColor: _avatarBg,
                              child: Icon(Icons.person, size: screenWidth * 0.15, color: _primaryGreen),
                            ),
                            SizedBox(height: screenWidth * 0.04),
                            Text(
                              '新潟 花子',
                              style: TextStyle(
                                fontSize: screenWidth * 0.055,
                                fontWeight: FontWeight.bold,
                                color: _primaryGreen,
                              ),
                            ),
                            SizedBox(height: screenWidth * 0.01),
                            Text(
                              'hanako@gmail.com',
                              style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.black87),
                            ),
                            SizedBox(height: screenWidth * 0.08),
                            _buildButton(context, Icons.edit, 'プロフィール編集', screenWidth),
                            SizedBox(height: screenWidth * 0.02),
                            _buildButton(context, Icons.help_outline, 'ヘルプ', screenWidth),
                            SizedBox(height: screenWidth * 0.02),
                            _buildButton(context, Icons.logout, 'ログアウト', screenWidth),
                            SizedBox(height: screenWidth * 0.02),
                            _buildButton(context, Icons.lock, 'パスワード変更', screenWidth),
                          ],
                        ),
                      ),
                    ],
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
                case 3:
                  Navigator.pushNamed(context, '/collection');
                  break;
                case 4:
                  // 現在の画面なので何もしない
                  break;
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, String label, double screenWidth) {
    return OutlinedButton.icon(
      icon: Icon(icon, color: _primaryGreen),
      label: Text(
        label,
        style: TextStyle(
          color: _primaryGreen,
          fontSize: screenWidth * 0.04,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: _bgLight,
        side: const BorderSide(color: _borderRed),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.03,
          horizontal: screenWidth * 0.04,
        ),
      ),
      onPressed: () {
        if (label == 'プロフィール編集') {
          Navigator.pushNamed(context, '/profileedit');
        }
        // TODO: 他のボタンの処理
      },
    );
  }
}
