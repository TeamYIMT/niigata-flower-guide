// map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../data/spots.dart';
import '../widgets/map_marker.dart';
import '../widgets/tourist_info_card.dart';
import '../widgets/spot_detail_card.dart';
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
  int? _selectedIndex;
  bool _showTouristInfo = false;
  LatLng? _currentPosition;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _createMarkers();
  }

  void _createMarkers() {
    for (int i = 0; i < spots.length; i++) {
      final spot = spots[i];
      _markers.add(
        Marker(
          markerId: MarkerId('spot_$i'),
          position: LatLng(spot.latitude, spot.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: spot.title,
            snippet: spot.location,
            onTap: () {
              setState(() {
                _selectedIndex = i;
                _showTouristInfo = false;
              });
            },
          ),
        ),
      );
    }
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
          backgroundColor: Colors.transparent,
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
                        child: _buildSearchBar(),
                      ),
                    for (var i = 0; i < spots.length; i++)
                        Positioned(
                          top: 100.0 + i * 80,
                          left: 60.0 + (i % 2) * 120,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedIndex = i),
                          child: const MapMarker(),
                        ),
                      ),
                      if (_selectedIndex != null)
                        Positioned(
                          bottom: 100,
                          left: 16,
                          right: 16,
                          child: _showTouristInfo
                            ? TouristInfoCard(
                                data: spots[_selectedIndex!],
                                  onClose: () => setState(() => _showTouristInfo = false),
                                )
                            : SpotDetailCard(
                                data: spots[_selectedIndex!],
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
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: const Color(0xFF3E5C40),
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/');
          if (i == 2) Navigator.pushNamed(context, '/ar');
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
