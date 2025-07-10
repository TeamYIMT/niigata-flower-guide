import 'package:flutter/material.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/spot.dart';
import 'stamp_collection_button.dart';
import 'spot_action_button.dart';

class SpotDetailSheet extends StatefulWidget {
  final Spot spot;

  const SpotDetailSheet({
    required this.spot,
    Key? key,
  }) : super(key: key);

  @override
  State<SpotDetailSheet> createState() => _SpotDetailSheetState();
}

class _SpotDetailSheetState extends State<SpotDetailSheet> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Center(
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.8,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      widget.spot.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Segmented Button for content switching
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('スポット'),
                    icon: Icon(Icons.location_on),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('花情報'),
                    icon: Icon(Icons.local_florist),
                  ),
                  ButtonSegment(
                    value: 2,
                    label: Text('観光情報'),
                    icon: Icon(Icons.camera_alt),
                  ),
                ],
                selected: <int>{_selectedIndex},
                showSelectedIcon: false,
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _selectedIndex = newSelection.first;
                  });
                },
              ),
            ),

            // Content area with IndexedStack
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _BasicInfoView(
                    spot: widget.spot,
                    scrollController: ScrollController(),
                  ),
                  _FlowerInfoView(
                    spot: widget.spot,
                    scrollController: ScrollController(),
                  ),
                  _SightseeingInfoView(
                    spot: widget.spot,
                    scrollController: ScrollController(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Basic spot information view
class _BasicInfoView extends StatelessWidget {
  final Spot spot;
  final ScrollController scrollController;

  const _BasicInfoView({
    required this.spot,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spot image carousel
          _ImageCarousel(spot: spot),
          
          const SizedBox(height: 16),
          
          // Location with icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  spot.location,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Distance indicator (placeholder)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.near_me,
                      size: 16,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '0m',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Description with expandable text
          ExpandableText(
            spot.description,
            expandText: ' 続きを読む',
            collapseText: ' 閉じる',
            maxLines: 3,
            linkColor: colorScheme.primary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stamp collection button
          StampCollectionButton(spot: spot),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SpotActionButton(
                icon: Icons.map,
                label: 'マップ',
                onPressed: () => Navigator.of(context).pop(),
              ),
              SpotActionButton(
                icon: Icons.near_me,
                label: 'ルート',
                onPressed: () {},
              ),
              SpotActionButton(
                icon: Icons.camera_alt,
                label: 'AR',
                onPressed: () {},
              ),
            ],
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Flower information view
class _FlowerInfoView extends StatelessWidget {
  final Spot spot;
  final ScrollController scrollController;

  const _FlowerInfoView({
    required this.spot,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final flowerInfo = spot.flowerInfo;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (flowerInfo != null) ...[
            _InfoRow(
              icon: Icons.science,
              label: '学名',
              value: flowerInfo.scientificName,
              isItalic: true,
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.calendar_today,
              label: '花期',
              value: flowerInfo.bloomPeriod,
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.visibility,
              label: '見頃',
              value: flowerInfo.bestViewingTime,
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.favorite,
              label: '花言葉',
              value: flowerInfo.flowerLanguage,
            ),
            const SizedBox(height: 16),
            if (flowerInfo.referenceUrl != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.link,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '参考サイト',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _launchUrl(flowerInfo.referenceUrl!),
                icon: const Icon(Icons.open_in_new),
                label: const Text('外部リンクを開く'),
              ),
            ],
          ] else ...[
            // No flower info available
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.local_florist_outlined,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '花情報はまだ準備中です',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Sightseeing information view
class _SightseeingInfoView extends StatelessWidget {
  final Spot spot;
  final ScrollController scrollController;

  const _SightseeingInfoView({
    required this.spot,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sightseeingInfo = spot.sightseeingInfo;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sightseeingInfo != null) ...[
            _InfoRow(
              icon: Icons.place,
              label: '周辺観光地',
              value: sightseeingInfo.nearbyAttractions,
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.directions,
              label: 'アクセス',
              value: sightseeingInfo.accessInfo,
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.local_parking,
              label: '施設',
              value: sightseeingInfo.facilities,
            ),
            const SizedBox(height: 16),
            if (sightseeingInfo.websiteUrl != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.web,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '公式サイト',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _launchUrl(sightseeingInfo.websiteUrl!),
                icon: const Icon(Icons.open_in_new),
                label: const Text('公式サイトを開く'),
              ),
            ],
          ] else ...[
            // No sightseeing info available
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '観光情報はまだ準備中です',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Reusable info row widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isItalic;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isItalic = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: isItalic ? FontStyle.italic : null,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Image carousel widget for displaying multiple spot images
class _ImageCarousel extends StatefulWidget {
  final Spot spot;

  const _ImageCarousel({required this.spot});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final images = widget.spot.displayImages;

    // デバッグ用：画像リストをログ出力
    debugPrint('ImageCarousel - images: $images');
    debugPrint('ImageCarousel - images.length: ${images.length}');

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  // スワイプ感度を向上させるため、物理設定を追加
                  physics: const BouncingScrollPhysics(),
                  // ページ変更時のコールバック
                  onPageChanged: (index) {
                    debugPrint('ImageCarousel - Page changed to: $index');
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final imagePath = images[index];
                    debugPrint('ImageCarousel - Building image at index $index: $imagePath');
                    
                    return GestureDetector(
                      // タップで次の画像に切り替え（追加機能）
                      onTap: () {
                        if (images.length > 1) {
                          final nextIndex = (_currentIndex + 1) % images.length;
                          _pageController.animateToPage(
                            nextIndex,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('ImageCarousel - Error loading image: $imagePath, Error: $error');
                          return Container(
                            color: colorScheme.surfaceVariant,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '画像が読み込めません',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  imagePath,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                // 左右の矢印ボタン（複数画像がある場合のみ表示）
                if (images.length > 1) ...[
                  // 左矢印ボタン
                  if (_currentIndex > 0)
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  // 右矢印ボタン
                  if (_currentIndex < images.length - 1)
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Helper function to launch URLs
Future<void> _launchUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

/// Helper function to show the spot detail sheet
void showSpotDetailSheet(BuildContext context, Spot spot, {VoidCallback? onShow, VoidCallback? onHide}) {
  // マップ操作を無効化
  if (onShow != null) onShow();
  
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    barrierDismissible: true,
    builder: (context) => SpotDetailSheet(spot: spot),
  ).then((_) {
    // シートが閉じられた時にマップ操作を再有効化
    if (onHide != null) onHide();
  });
} 