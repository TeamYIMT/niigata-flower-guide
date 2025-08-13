import 'package:flutter/material.dart';
import '../models/spot.dart';
import 'spot_action_button.dart';
import 'stamp_collection_button.dart';

class SpotDetailCard extends StatelessWidget {
  final Spot data;
  final VoidCallback onClose;
  final VoidCallback onTouristInfo;

  const SpotDetailCard({
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
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(onTap: onClose, child: const Icon(Icons.close, size: 20)),
                ),
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
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    data.image,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E5C40)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Expanded(child: Text(data.location)),
                  ],
                ),
                const SizedBox(height: 12),
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
                          data.description,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // スタンプ取得ボタン
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: StampCollectionButton(spot: data),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SpotActionButton(icon: Icons.map, label: 'マップ', onPressed: onClose),
                    SpotActionButton(icon: Icons.near_me, label: 'ルート', onPressed: () {}),
                    SpotActionButton(icon: Icons.camera_alt, label: 'AR', onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ARカメラ機能は開発中です')),
                      );
                    }),
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
