import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'spot.dart';

class SpotRepository {
  const SpotRepository();

  Future<List<Spot>> loadAll() async {
    final jsonString = await rootBundle.loadString('assets/data/spots.json');
    final List<dynamic> list = json.decode(jsonString) as List<dynamic>;
    return list.map((e) => Spot.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Spot>> filter({
    String? prefecture,
    List<String>? tags,
    List<String>? seasons,
  }) async {
    final all = await loadAll();
    return all.where((s) {
      final okPref = prefecture == null || s.prefecture == prefecture;
      final okTags = tags == null || tags.any((t) => s.tags.contains(t));
      final okSeasons = seasons == null || seasons.any((m) => s.seasons.contains(m));
      return okPref && okTags && okSeasons;
    }).toList();
  }
}


