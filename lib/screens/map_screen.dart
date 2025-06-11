import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 360,
        height: 640,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          // body: マップ表示と検索バー
          body: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // マップ領域のコンテナ
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 500,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        // TODO: 実際の地図ウィジェット（GoogleMap など）をここに組み込む
                        child: const Center(
                          child: Text('Map Placeholder'),
                        ),
                      ),
                    ),
                    // 検索バー（オーバーレイ）
                    Positioned(
                      top: -16,
                      left: 32,
                      right: 32,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 40,
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: '検索',
                              hintStyle: const TextStyle(color: Colors.black54),
                              prefixIcon: const Icon(Icons.search, color: Colors.black54),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onChanged: (value) {
                              // TODO: 検索処理を実装
                            },
                          ),
                        ),
                      ),
                    ),
                    // マーカーの例
                    const Positioned(
                      top: 100,
                      left: 60,
                      child: _MapMarker(),
                    ),
                    const Positioned(
                      top: 180,
                      left: 200,
                      child: _MapMarker(),
                    ),
                    const Positioned(
                      top: 300,
                      left: 120,
                      child: _MapMarker(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ボトムナビゲーションバー
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 1,
            selectedItemColor: const Color(0xFF3E5C40),
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/');
                  break;
                case 1:
                  // 現在の画面なので何もしない
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

/// マップ上のピン（マーカー）を表現するカスタムウィジェット
class _MapMarker extends StatelessWidget {
  const _MapMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF56C0B3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.local_florist,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}
