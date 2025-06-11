import 'package:flutter/material.dart';
import '../widgets/icon_tile.dart';
import 'map_screen.dart';

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
                  children: [
                    IconTile(
                      icon: 'map_icon.png',
                      label: 'マップ',
                      bgColor: const Color(0xFF56C0B3),
                      iconSize: 40,
                      fontSize: 14,
                      padding: 12,
                      onTap: () => Navigator.pushNamed(context, '/map'),
                    ),
                    IconTile(
                      icon: 'collection_icon.png',
                      label: 'コレクション',
                      bgColor: const Color(0xFFF4C84E),
                      iconSize: 40,
                      fontSize: 14,
                      padding: 12,
                    ),
                    IconTile(
                      icon: 'profile_icon.png',
                      label: 'プロフィール',
                      bgColor: const Color(0xFFF9A1B0),
                      iconSize: 40,
                      fontSize: 14,
                      padding: 12,
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                    IconTile(
                      icon: 'ar_camera_icon.png',
                      label: 'ARカメラ',
                      bgColor: const Color(0xFF8DD7B2),
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
            type: BottomNavigationBarType.shifting,  // 選択中のアイコンのラベルのみ表示
            currentIndex: 0,  // ホーム画面なので0を指定
            selectedItemColor: const Color(0xFF3E5C40),
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              switch (index) {
                case 0:
                  // 現在の画面なので何もしない
                  break;
                case 1:
                  Navigator.pushNamed(context, '/map');
                  break;
                case 4:
                  Navigator.pushNamed(context, '/profile');
                  break;
                // TODO: 他の画面の遷移も実装
              }
            },
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
