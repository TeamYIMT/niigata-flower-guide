// map_screen.dart
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int? _selectedIndex;
  bool _showTouristInfo = false;
  final List<Map<String, String>> _spots = [
    {
      'title': '五泉市チューリップまつり',
      'location': '五泉市栗本地区一本杉内',
      'image': 'assets/images/tulip_field.jpg',
      'description': '五泉市は、新潟県内でも有数のチューリップの産地として知られています。五泉市では、チューリップの球根を出荷するだけでなく、市民や観光客にも楽しんでもらえるよう、生産者に依頼して巣本地区にチューリップの畑を集め、チューリップまつりを毎年開催しています。最近では、オランダなどから新たな品種の球根を輸入して栽培するなど、多種多様な花が咲き誇っています。',
      'tourist_title': 'ラポルテ五泉',
      'tourist_location': '五泉市赤海863番地',
      'tourist_description': 'ラポルテ五泉は、約2万4,000㎡の敷地に床面積3,700㎡の建物と3つの広場をもつ五泉市の交流拠点複合施設です。  館内には、芸術や学びの場となる多目的ホールや多目的室。市が日本に誇るニットや絹産業、地元の特産物を販売する産直ショップ＆カフェテリア。特におすすめなのは、木造建築を生かして面白遊具を備えた「子どもの遊び場」や開放感あるガレリアの空間です。  約 160 台収容できる駐車場と夜間にも利用できる24時間トイレも備えて車の利用者にも便利です。  "まるっと1日楽しく過ごせる"ラポルテ五泉 みなさまのご利用を、心からお待ちしております。',
    },
    // …他スポット…
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 360,
        height: 640,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              const SizedBox(height: 16),

              // ───────── 地図領域(Expanded) ─────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 地図コンテナが残り高さいっぱいに
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Center(child: Text('Map Placeholder')),
                        ),
                      ),

                      // 検索バー（オーバーラップ）
                      Positioned(
                        top: -20,
                        left: 32,
                        right: 32,
                        child: _buildSearchBar(),
                      ),

                      // マーカー
                      for (var i = 0; i < _spots.length; i++)
                        Positioned(
                          top: 100.0 + i * 80,
                          left: 60.0 + (i % 2) * 120,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedIndex = i),
                            child: const _MapMarker(),
                          ),
                        ),

                      // スポット詳細ウインドウ（カード幅を328pxに固定）
                      if (_selectedIndex != null)
                        Positioned(
                          bottom: 100,
                          left: 16,
                          right: 16,
                          child: _showTouristInfo
                              ? _TouristInfoCard(
                                  data: _spots[_selectedIndex!],
                                  onClose: () => setState(() => _showTouristInfo = false),
                                )
                              : _SpotDetailCard(
                                  data: _spots[_selectedIndex!],
                                  onClose: () => setState(() => _selectedIndex = null),
                                  onTouristInfo: () => setState(() => _showTouristInfo = true),
                                ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ───────── ボトムナビ ─────────
          bottomNavigationBar: _buildBottomNav(context),
        ),
      ),
    );
  }

  Widget _buildSearchBar() => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: const TextField(
            decoration: InputDecoration(
              hintText: '検索',
              hintStyle: TextStyle(color: Colors.black54),
              prefixIcon: Icon(Icons.search, color: Colors.black54),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      );

  Widget _buildBottomNav(BuildContext context) => BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: 1,
        selectedItemColor: const Color(0xFF3E5C40),
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/');
          if (i == 4) Navigator.pushNamed(context, '/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'マップ'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'ARカメラ'),
          BottomNavigationBarItem(icon: Icon(Icons.collections), label: 'コレクション'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'プロフィール'),
        ],
      );
}

/// マーカー
class _MapMarker extends StatelessWidget {
  const _MapMarker({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container(
        width: 32,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF56C0B3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.local_florist, color: Colors.white, size: 16),
        ),
      );
}

/// 観光情報カード
class _TouristInfoCard extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback onClose;

  const _TouristInfoCard({
    required this.data,
    required this.onClose,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 328,
        height: 480,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 閉じる
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(onTap: onClose, child: const Icon(Icons.close, size: 20)),
                ),
                // ヘッダー
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3E5C40),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '観光情報',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 画像
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/laporteshoukai.jpg',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                // 観光地名
                Text(
                  data['tourist_title']!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E5C40),
                  ),
                ),
                const SizedBox(height: 12),
                // 住所
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Expanded(child: Text(data['tourist_location']!)),
                  ],
                ),
                const SizedBox(height: 16),
                // 説明
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          data['tourist_description']!,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// スポット詳細カード
class _SpotDetailCard extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback onClose;
  final VoidCallback onTouristInfo;

  const _SpotDetailCard({
    required this.data,
    required this.onClose,
    required this.onTouristInfo,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 328,
        height: 480,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 閉じる
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(onTap: onClose, child: const Icon(Icons.close, size: 20)),
                ),
                // ヘッダー
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3E5C40),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'スポット詳細',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: onTouristInfo,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '観光情報',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 画像
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    data['image']!,
                    height: 160, // 高さもデザインに合わせて調整
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                // タイトル
                Text(
                  data['title']!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E5C40)),
                ),
                const SizedBox(height: 4),
                // 住所
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Expanded(child: Text(data['location']!)),
                  ],
                ),
                const SizedBox(height: 12),
                // 説明
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          data['description']!,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // アクションボタン
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SpotActionButton(icon: Icons.map, label: 'マップ', onPressed: onClose),
                    _SpotActionButton(icon: Icons.near_me, label: 'ルート', onPressed: () {}),
                    _SpotActionButton(icon: Icons.camera_alt, label: 'AR', onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// アクションボタン
class _SpotActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _SpotActionButton({required this.icon, required this.label, required this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: Color(0xFF3E5C40)),
          minimumSize: const Size(72, 64),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF3E5C40)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Color(0xFF3E5C40), fontSize: 12)),
          ],
        ),
      );
}
