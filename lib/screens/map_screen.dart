// map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../data/spots.dart';
import '../widgets/map_marker.dart';
import '../widgets/tourist_info_card.dart';
import '../widgets/spot_detail_sheet.dart';
import '../widgets/nearby_spots_widget.dart';
import '../widgets/stamp_collection_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:niigata_flower_guide/models/spot.dart';
import '../providers/stamp_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentPosition;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isBottomSheetOpen = false;

  // 検索機能の状態管理
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Spot> _filteredSpots = spots;
  bool _isSuggestVisible = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _rebuildMarkers(_filteredSpots);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }



  void _rebuildMarkers(List<Spot> sourceSpots) {
    final newMarkers = <Marker>{};
    for (int i = 0; i < sourceSpots.length; i++) {
      final spot = sourceSpots[i];
      newMarkers.add(
        Marker(
          markerId: MarkerId('spot_${spot.id}'),
          position: LatLng(spot.latitude, spot.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: spot.title,
            snippet: spot.location,
            onTap: () {
              showSpotDetailSheet(
                context, 
                spot,
                onShow: () => setState(() => _isBottomSheetOpen = true),
                onHide: () => setState(() => _isBottomSheetOpen = false),
              );
            },
          ),
        ),
      );
    }
    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  // 検索クエリの正規化
  String _normalizeQuery(String? query) {
    if (query == null) return '';
    return query.toLowerCase().trim();
  }

  // スポットが検索クエリにマッチするかチェック
  bool _matchSpot(Spot spot, String normalizedQuery) {
    if (normalizedQuery.isEmpty) return true;
    
    final fields = [
      spot.title,
      spot.location,
      spot.description,
      spot.touristTitle,
      spot.touristLocation,
      spot.touristDescription,
      spot.flowerInfo?.scientificName,
      spot.flowerInfo?.bloomPeriod,
      spot.flowerInfo?.bestViewingTime,
      spot.flowerInfo?.flowerLanguage,
      spot.sightseeingInfo?.nearbyAttractions,
      spot.sightseeingInfo?.accessInfo,
      spot.sightseeingInfo?.facilities,
    ];
    
    return fields.any((field) => 
      field != null && _normalizeQuery(field).contains(normalizedQuery)
    );
  }

  // 検索フィルタを適用
  void _applyFilter() {
    final normalizedQuery = _normalizeQuery(_searchQuery);
    final filteredSpots = normalizedQuery.isEmpty
        ? spots
        : spots.where((spot) => _matchSpot(spot, normalizedQuery)).toList();
    
    setState(() {
      _filteredSpots = filteredSpots;
      _isSuggestVisible = normalizedQuery.isNotEmpty;
    });
    
    _rebuildMarkers(filteredSpots);
  }

  // 検索クエリ変更時のデバウンス処理
  void _onQueryChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      setState(() {
        _searchQuery = value;
      });
      _applyFilter();
    });
  }

  // 検索クリア
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filteredSpots = spots;
      _isSuggestVisible = false;
    });
    _rebuildMarkers(spots);
  }

  // サジェスト選択時の処理
  void _onSelectSuggestion(Spot spot) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(spot.latitude, spot.longitude),
        15.0,
      ),
    );
    setState(() {
      _isSuggestVisible = false;
    });
    
    // 少し遅らせて詳細シートを表示
    Future.delayed(const Duration(milliseconds: 500), () {
      showSpotDetailSheet(
        context, 
        spot,
        onShow: () => setState(() => _isBottomSheetOpen = true),
        onHide: () => setState(() => _isBottomSheetOpen = false),
      );
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // サービスが無効の場合は何もしない
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_currentPosition!),
    );
  }

  void _showFlowerDetail(Spot spot) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              spot.title, 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            Text(spot.description),
            const SizedBox(height: 16),
            Text(
              '場所: ${spot.location}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '座標: ${spot.latitude.toStringAsFixed(6)}, ${spot.longitude.toStringAsFixed(6)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                          width: double.infinity,
                        height: double.infinity,
                        child: GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(37.9026, 139.0232),
                            zoom: 8,
                          ),
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                          myLocationEnabled: _currentPosition != null,
                          myLocationButtonEnabled: true,
                          zoomGesturesEnabled: !_isBottomSheetOpen,
                          scrollGesturesEnabled: !_isBottomSheetOpen,
                          tiltGesturesEnabled: !_isBottomSheetOpen,
                          rotateGesturesEnabled: !_isBottomSheetOpen,
                          markers: {
                            ..._markers,
                            if (_currentPosition != null)
                              Marker(
                                markerId: const MarkerId('currentLocation'),
                                position: _currentPosition!,
                                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                                infoWindow: const InfoWindow(title: '現在地'),
                              ),
                          },
                        ),
                        ),
                      ),
                      Positioned(
                        top: -20,
                        left: 32,
                        right: 32,
                        child: Column(
                          children: [
                            _buildSearchBar(),
                            if (_isSuggestVisible) _buildSuggestionList(),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSearchBar() => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: _searchController,
            onChanged: _onQueryChanged,
            onSubmitted: (value) {
              if (_filteredSpots.isNotEmpty) {
                _onSelectSuggestion(_filteredSpots.first);
              }
            },
            decoration: InputDecoration(
              hintText: '検索（スポット名、場所、説明など）',
              hintStyle: const TextStyle(color: Colors.black54),
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.black54),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      );

  Widget _buildSuggestionList() {
    const maxSuggestions = 8;
    final suggestions = _filteredSpots.take(maxSuggestions).toList();
    
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 300),
      child: suggestions.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '該当するスポットが見つかりませんでした',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: suggestions.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final spot = suggestions[index];
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: spot.isDemo 
                        ? Colors.orange[100] 
                        : Colors.green[100],
                    child: Icon(
                      spot.isDemo ? Icons.science : Icons.location_on,
                      size: 16,
                      color: spot.isDemo 
                          ? Colors.orange[700] 
                          : Colors.green[700],
                    ),
                  ),
                  title: Text(
                    spot.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    spot.location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.grey[400],
                  ),
                  onTap: () => _onSelectSuggestion(spot),
                );
              },
            ),
    );
  }

  Widget _buildBottomNav(BuildContext context) => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: const Color(0xFF3E5C40),
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/');
          if (i == 2) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ARカメラ機能は開発中です')),
          );
          if (i == 3) Navigator.pushNamed(context, '/collection');
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
