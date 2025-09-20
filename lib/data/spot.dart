class Spot {
  final String id;
  final String name;
  final String prefecture;
  final double lat;
  final double lng;
  final List<String> tags; // e.g. ["flower", "poi", "park"]
  final List<String> seasons; // e.g. ["spring", "summer"]

  const Spot({
    required this.id,
    required this.name,
    required this.prefecture,
    required this.lat,
    required this.lng,
    required this.tags,
    required this.seasons,
  });

  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      id: json['id'] as String,
      name: json['name'] as String,
      prefecture: json['prefecture'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      seasons: (json['seasons'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'prefecture': prefecture,
        'lat': lat,
        'lng': lng,
        'tags': tags,
        'seasons': seasons,
      };
}


