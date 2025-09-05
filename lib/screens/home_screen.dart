import 'package:flutter/material.dart';

import 'map_screen.dart';
import 'stamps_collection_screen.dart'; // クラス名は StampCollectionScreen（単数形）
import 'profile_screen.dart';
import '../widgets/nearby_spots_widget.dart';

const _primaryGreen = Color(0xFF4CAF50);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 0:ホーム, 1:マップ, 2:AR(押したら遷移), 3:コレクション, 4:プロフィール
  int _index = 0;

  static const _bgLight = Color(0xFFFCF8F2);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      // ← ここで4ボタンを持つホーム
      _HomeTab(
        goTab: (i) {
          if (i == 2) {
            // ARだけは別ルートへ
            Navigator.pushNamed(context, '/unity');
          } else {
            setState(() => _index = i);
          }
        },
      ),
      const MapScreen(embedded: true),       // マップ
      const SizedBox.shrink(),               // AR（ページは持たない）
      const StampCollectionScreen(embedded: true), // コレクション（親に埋め込み）
      const ProfileScreen(embedded: true),   // プロフィール
    ];

    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: IndexedStack(
          index: _index == 2 ? 0 : _index,   // AR選択時でも見た目はホームのまま
          children: pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        selectedItemColor: _primaryGreen,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'マップ'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'AR'),
          BottomNavigationBarItem(icon: Icon(Icons.collections), label: 'コレクション'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'プロフィール'),
        ],
        onTap: (i) {
          if (i == 2) {
            Navigator.pushNamed(context, '/unity');
            return;
          }
          setState(() => _index = i);
        },
      ),
    );
  }
}

/// 4つの大ボタンを持つホームタブ
class _HomeTab extends StatelessWidget {
  final void Function(int tabIndex) goTab;
  const _HomeTab({super.key, required this.goTab});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const SizedBox(height: 16),

        // トップ画像（高さ120）
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: const Color(0xFF3E5C40),
              child: Image.asset(
                'assets/images/flower_field.png',
                width: double.infinity,
                height: 120,
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
              ) ?? const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3E5C40)),
        ),
        const SizedBox(height: 8),
        Text(
          '花をきっかけに、新潟の魅力を見つけよう。',
          style: TextStyle(color: Color(0xFF476D5B)),
        ),
        const SizedBox(height: 24),

        // 2x2 の大ボタン
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _HomeBigButton(
              icon: Icons.map,
              label: 'マップ',
              onTap: () => goTab(1),
              color: const Color(0xFF56C0B3),
            ),
            _HomeBigButton(
              icon: Icons.camera_alt,
              label: 'ARカメラ',
              onTap: () => goTab(2),
              color: const Color(0xFF8DD7B2),
            ),
            _HomeBigButton(
              icon: Icons.collections,
              label: 'コレクション',
              onTap: () => goTab(3),
              color: const Color(0xFFF4C84E),
            ),
            _HomeBigButton(
              icon: Icons.person,
              label: 'プロフィール',
              onTap: () => goTab(4),
              color: const Color(0xFFF9A1B0),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 近くのスポット情報
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const NearbySpotsWidget(),
        ),
      ],
    );
  }
}

class _HomeBigButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _HomeBigButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      elevation: 1.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
