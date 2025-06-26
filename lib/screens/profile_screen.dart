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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = screenWidth * 0.9; // 画面幅の90%
    final cardPadding = screenWidth * 0.06; // 画面幅の6%

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F2),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    CircleAvatar(
                      radius: screenWidth * 0.15,
                      backgroundColor: _avatarBg,
                      child: Icon(
                        Icons.person,
                        size: screenWidth * 0.2,
                        color: _primaryGreen,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      '新潟 花子',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: _primaryGreen,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'hanako@gmail.com',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    _buildButton(context, Icons.edit, 'プロフィール編集'),
                    SizedBox(height: screenHeight * 0.02),
                    _buildButton(context, Icons.help_outline, 'ヘルプ'),
                    SizedBox(height: screenHeight * 0.02),
                    _buildButton(context, Icons.logout, 'ログアウト'),
                    SizedBox(height: screenHeight * 0.02),
                    _buildButton(context, Icons.lock, 'パスワード変更'),
                  ],
                ),
              ),
            ),
          ),
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
              Navigator.pushNamed(context, '/ar');
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

  Widget _buildButton(BuildContext context, IconData icon, String label) {
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
      onPressed: () {
        if (label == 'プロフィール編集') {
          Navigator.pushNamed(context, '/profileedit');
        }
      },
    );
  }
}
