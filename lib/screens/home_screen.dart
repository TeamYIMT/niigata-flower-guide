import 'package:flutter/material.dart';
import '../widgets/icon_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // スマホ画面サイズを固定する場合
    return Center(
      child: SizedBox(
        width: 360,
        height: 640,
        child: Scaffold(
          backgroundColor: Colors.transparent, // 親で指定しているので透明
          body: Column(
            children: [
              const SizedBox(height: 16),
              // 上部の大きな画像＋背景
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: const Color(0xFF3E5C40),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/images/flower_field.png',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // タイトル
              Text(
                'Niigata 花図鑑',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF3E5C40),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              // 4 つのアイコンタイル
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: const [
                    IconTile(icon: 'map_icon.png', label: 'マップ', bgColor: Color(0xFF56C0B3)),
                    IconTile(icon: 'collection_icon.png', label: 'コレクション', bgColor: Color(0xFFF4C84E)),
                    IconTile(icon: 'profile_icon.png', label: 'プロフィール', bgColor: Color(0xFFF9A1B0)),
                    IconTile(icon: 'ar_camera_icon.png', label: 'ARカメラ', bgColor: Color(0xFF8DD7B2)),
                  ],
                ),
              ),
            ],
          ),
          // ボトムナビゲーション
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: const Color(0xFF3E5C40),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'マップ'),
              BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'ARカメラ'),
              BottomNavigationBarItem(icon: Icon(Icons.collections), label: 'コレクション'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'プロフィール'),
            ],
          ),
        ),
      ),
    );
  }
}
