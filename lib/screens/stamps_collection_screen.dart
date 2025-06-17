import 'package:flutter/material.dart';

/// モックアップ用のスタンプデータクラス
class Stamp {
  final String assetPath;
  final bool collected;
  const Stamp(this.assetPath, this.collected);
}

/// スタンプコレクション画面のウィジェット
class StampCollectionScreen extends StatelessWidget {
  const StampCollectionScreen({Key? key}) : super(key: key);

  // ダミーデータ: 購入・取得状態を bool で管理
  final List<Stamp> stamps = const [
    Stamp('assets/images/question.png', false),
    Stamp('assets/images/cherryblossom.png', true),
    Stamp('assets/images/cherryblossom2.png', true),
    Stamp('assets/images/daylily.png', true),
    Stamp('assets/images/daylily.png', false),
    Stamp('assets/images/hydrangea.png', true),
    Stamp('assets/images/cosmos.png', false),
    Stamp('assets/images/question.png', false),
    Stamp('assets/images/tulip.png', true),
    // ... 合計 20 個分を配置
  ];

  @override
  Widget build(BuildContext context) {
    final total = stamps.length;
    final collectedCount = stamps.where((s) => s.collected).length;

    return Center(
      child: SizedBox(
        width: 360,
        height: 640,
        child: Scaffold(
          // 背景花柄を薄く表示
          body: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    'assets/images/backgroundflower.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // スタンプ／バッジ切り替え（今回はスタンプのみ）
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: Text('スタンプ'),
                            selected: true,
                            onSelected: (_) {},
                          ),
                          SizedBox(width: 8),
                          ChoiceChip(
                            label: Text('バッジ'),
                            selected: false,
                            onSelected: (_) {},
                          ),
                        ],
                      ),
                    ),

                    // スタンプグリッド
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.builder(
                          itemCount: stamps.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            final stamp = stamps[index];
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.green, width: 2),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  stamp.collected
                                      ? stamp.assetPath
                                      : 'assets/images/question.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // 「さらに見る」ボタン
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: StadiumBorder(),
                          elevation: 0,
                        ),
                        child: Text('さらに見る'),
                      ),
                    ),

                    // 進捗バー
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Row(
                        children: [
                          Text('$collectedCount / $total'),
                          SizedBox(width: 12),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: collectedCount / total,
                              backgroundColor: Colors.green.shade100,
                              color: Colors.green,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ボトムナビゲーション
                    BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      currentIndex: 3,
                      items: [
                        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
                        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'マップ'),
                        BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'ARカメラ'),
                        BottomNavigationBarItem(icon: Icon(Icons.collections), label: 'コレクション'),
                        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'プロフィール'),
                      ],
                      onTap: (index) {
                        switch (index) {
                          case 0:
                            Navigator.pushNamed(context, '/');
                            break;
                          case 1:
                            Navigator.pushNamed(context, '/map');
                            break;
                          case 4:
                            Navigator.pushNamed(context, '/profile');
                            break;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
