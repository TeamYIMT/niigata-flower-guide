import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSpots();
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
    } catch (e) {
      setState(() => error = '$e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final latLng = LatLng(37.9161, 139.0364);
    return Scaffold(
      appBar: AppBar(title: const Text('ハッカソンMVP')),
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
                    if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    if (lastPlan != null) ...[
                      const Text('提案結果', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(JsonEncoder.withIndent('  ').convert(lastPlan)),
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
              onMapCreated: (c) => mapController.complete(c),
            ),
          ),
        ],
      ),
    );
  }
}


