import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/plan_api.dart';
import '../data/spot.dart';
import '../data/spot_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  final originController = TextEditingController(text: '37.9161,139.0364');
  final durationController = TextEditingController(text: '4');
  final keywordsController = TextEditingController(text: 'sakura,park');
  bool includePoi = true;

  // Functionsエミュレータ（デフォルト 5001）へ直接POST（WebのCORS/リライト依存を避ける）
  final planApi = PlanApi(baseUrl: 'http://localhost:5001', path: '/flower-guide-hackathon-2025/asia-northeast1/plan');
  Map<String, dynamic>? lastPlan;
  bool loading = false;
  String? error;
  final spotsRepo = const SpotRepository();
  List<Spot> spots = [];

  final Completer<GoogleMapController> mapController = Completer();
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  List<LatLng> _lastRoute = const [];

  @override
  void initState() {
    super.initState();
    _loadSpots();
    _loadCache();
  }

  Future<void> _loadSpots() async {
    final all = await spotsRepo.loadAll();
    setState(() {
      spots = all;
      markers.clear();
      for (final s in all) {
        markers.add(Marker(
          markerId: MarkerId(s.id),
          position: LatLng(s.lat, s.lng),
          infoWindow: InfoWindow(title: s.name),
        ));
      }
    });
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = null;
    });
    final parts = originController.text.split(',');
    final lat = double.tryParse(parts[0].trim()) ?? 37.9161;
    final lng = double.tryParse(parts[1].trim()) ?? 139.0364;
    final duration = int.tryParse(durationController.text.trim()) ?? 4;
    final keywords = keywordsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    try {
      final res = await planApi.createPlan(PlanRequest(
        originLat: lat,
        originLng: lng,
        durationHours: duration,
        keywords: keywords,
        includePoi: includePoi,
      ));
      setState(() => lastPlan = res);
      await _saveCache(res);
      _updatePolyline();
    } catch (e) {
      setState(() => error = '$e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _saveCache(Map<String, dynamic> plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_plan_json', jsonEncode(plan));
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('last_plan_json');
    if (s != null) {
      try {
        final cached = jsonDecode(s) as Map<String, dynamic>;
        setState(() => lastPlan = cached);
        _updatePolyline();
      } catch (_) {}
    }
  }

  void _updatePolyline() {
    if (lastPlan == null || spots.isEmpty) return;
    final planList = (lastPlan!['plan'] as List?)?.cast<dynamic>() ?? [];
    final idToSpot = {for (final s in spots) s.id: s};
    final coords = <LatLng>[];
    for (final item in planList) {
      final id = (item as Map<String, dynamic>)['id'] as String?;
      if (id == null) continue;
      final s = idToSpot[id];
      if (s != null) {
        coords.add(LatLng(s.lat, s.lng));
      }
    }
    setState(() {
      polylines.clear();
      if (coords.length >= 2) {
        polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: coords,
          color: Colors.blue,
          width: 4,
        ));
        _lastRoute = List<LatLng>.from(coords);
      }
    });
    if (coords.length >= 2) {
      _fitToPolyline(coords);
    }
  }

  Future<void> _fitToPolyline(List<LatLng> coords) async {
    if (!mapController.isCompleted) return;
    final ctrl = await mapController.future;
    double minLat = coords.first.latitude;
    double maxLat = coords.first.latitude;
    double minLng = coords.first.longitude;
    double maxLng = coords.first.longitude;
    for (final p in coords) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    try {
      await ctrl.animateCamera(CameraUpdate.newLatLngBounds(bounds, 48));
    } catch (_) {
      // Webで例外になる場合は中心へ移動
      final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
      await ctrl.animateCamera(CameraUpdate.newLatLngZoom(center, 11));
    }
  }

  @override
  Widget build(BuildContext context) {
    final latLng = LatLng(37.9161, 139.0364);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ハッカソンMVP'),
        actions: [
          IconButton(
            tooltip: 'ルートにズーム',
            onPressed: _lastRoute.length >= 2 ? () => _fitToPolyline(_lastRoute) : null,
            icon: const Icon(Icons.route),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: originController,
                      decoration: const InputDecoration(labelText: '出発地 (lat,lng)'),
                    ),
                    TextFormField(
                      controller: durationController,
                      decoration: const InputDecoration(labelText: '所要時間(時間)'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: keywordsController,
                      decoration: const InputDecoration(labelText: 'キーワード(カンマ区切り)'),
                    ),
                    SwitchListTile(
                      value: includePoi,
                      onChanged: (v) => setState(() => includePoi = v),
                      title: const Text('周辺POIを含める'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: loading ? null : _submit,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('AIにおまかせ'),
                    ),
                    if (loading) const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(),
                    ),
                    if (error != null)
                      Row(
                        children: [
                          Expanded(child: Text(error!, style: const TextStyle(color: Colors.red))),
                          TextButton(onPressed: loading ? null : _submit, child: const Text('再試行')),
                        ],
                      ),
                    const SizedBox(height: 12),
                    if (lastPlan != null) ...[
                      const Text('提案結果', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _PlanCards(plan: lastPlan!, spots: spots),
                      const SizedBox(height: 8),
                      ExpansionTile(
                        title: const Text('RAW JSON'),
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(JsonEncoder.withIndent('  ').convert(lastPlan)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: latLng, zoom: 11),
              markers: markers,
              polylines: polylines,
              onMapCreated: (c) => mapController.complete(c),
            ),
          ),
        ],
      ),
    );
  }
}


class _PlanCards extends StatelessWidget {
  final Map<String, dynamic> plan;
  final List<Spot> spots;
  const _PlanCards({required this.plan, required this.spots});

  @override
  Widget build(BuildContext context) {
    final idToSpot = {for (final s in spots) s.id: s};
    final items = (plan['plan'] as List?)?.cast<dynamic>() ?? const [];
    if (items.isEmpty) return const Text('提案がありません');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _PlanCardItem(index: i + 1, item: items[i] as Map<String, dynamic>, idToSpot: idToSpot),
          const SizedBox(height: 8),
        ]
      ],
    );
  }
}

class _PlanCardItem extends StatelessWidget {
  final int index;
  final Map<String, dynamic> item;
  final Map<String, Spot> idToSpot;
  const _PlanCardItem({required this.index, required this.item, required this.idToSpot});

  @override
  Widget build(BuildContext context) {
    final id = item['id'] as String? ?? '';
    final s = idToSpot[id];
    final title = s?.name ?? id;
    final stay = item['stayMin'] as int? ?? 40;
    final reason = item['reason'] as String? ?? '';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 12, child: Text('$index')),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text('$stay 分'),
              ],
            ),
            const SizedBox(height: 6),
            Text(reason),
          ],
        ),
      ),
    );
  }
}


