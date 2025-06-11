import 'package:flutter/material.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  static const _primaryGreen = Color(0xFF3A5A40);
  static const _borderRed = Color(0xFFBC5546);
  static const _scaffoldBg = Color(0xFFFCF8F2);
  static const _avatarBg = Color(0xFFE4E0FD);
  static const _navBg = Color(0xFFFCF8F2);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 360,
        height: 640,
        child: Scaffold(
          backgroundColor: _scaffoldBg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'プロフィール編集',
              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _avatarBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 64,
                      color: _primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Name field
                  _buildTextField(label: '名前', maxLines: 1),
                  const SizedBox(height: 16),
                  // Username field
                  _buildTextField(label: 'ユーザー名', maxLines: 1),
                  const SizedBox(height: 16),
                  // Email field
                  _buildTextField(label: 'メールアドレス', maxLines: 1),
                  const SizedBox(height: 16),
                  // Profile text
                  _buildTextField(label: 'プロフィール文', maxLines: 5),
                  const SizedBox(height: 24),
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: implement save logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '変更を保存',
                        style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: _navBg,
            selectedItemColor: _primaryGreen,
            unselectedItemColor: _primaryGreen.withOpacity(0.6),
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'ホーム',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'マップ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'ARカメラ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.collections),
                label: 'コレクション',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'プロフィール',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            currentIndex: 4, // Profile tab
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/');
                  break;
                case 1:
                  Navigator.pushNamed(context, '/map');
                  break;
                case 4:
                  Navigator.pop(context); // プロフィール画面に戻る
                  break;
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required int maxLines}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: _borderRed, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
