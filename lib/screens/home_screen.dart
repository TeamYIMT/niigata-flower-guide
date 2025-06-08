import 'package:flutter/material.dart';
import '../widgets/icon_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 360,
        height: 640,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          // body はスクロールなしの固定レイアウト
          body: Column(
            children: [
              const SizedBox(height: 16),
              // 画像部分を高さ 120 にダウン
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: const Color(0xFF3E5C40),
                    child: Image.asset(
                      'assets/images/flower_field.png',
                      width: double.infinity,
                      height: 120,        // ←200→120 に縮小
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // タイトル
              Text(
                'Niigata 花図鑑',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF3E5C40),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              // グリッド：スクロールを無効にして shrinkWrap
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                  children: const [
                    IconTile(
                      icon: 'map_icon.png',
                      label: 'マップ',
                      bgColor: Color(0xFF56C0B3),
                      iconSize: 40,    // ←48→40 に縮小
                      fontSize: 14,    // ←16→14 に縮小
                      padding: 12,     // 少し余白を広めに取って見栄え良く
                    ),
                    IconTile(
                      icon: 'collection_icon.png',
                      label: 'コレクション',
                      bgColor: Color(0xFFF4C84E),
                      iconSize: 40,
                      fontSize: 14,
                      padding: 12,
                    ),
                    IconTile(
                      icon: 'profile_icon.png',
                      label: 'プロフィール',
                      bgColor: Color(0xFFF9A1B0),
                      iconSize: 40,
                      fontSize: 14,
                      padding: 12,
                    ),
                    IconTile(
                      icon: 'ar_camera_icon.png',
                      label: 'ARカメラ',
                      bgColor: Color(0xFF8DD7B2),
                      iconSize: 40,
                      fontSize: 14,
                      padding: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ボトムナビゲーションはそのまま
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
