/// Flower-specific information for spots
class FlowerInfo {
  final String scientificName;
  final String bloomPeriod;
  final String bestViewingTime;
  final String flowerLanguage;
  final String? referenceUrl;

  const FlowerInfo({
    required this.scientificName,
    required this.bloomPeriod,
    required this.bestViewingTime,
    required this.flowerLanguage,
    this.referenceUrl,
  });

  factory FlowerInfo.fromMap(Map<String, dynamic> map) {
    return FlowerInfo(
      scientificName: map['scientific_name'] ?? '',
      bloomPeriod: map['bloom_period'] ?? '',
      bestViewingTime: map['best_viewing_time'] ?? '',
      flowerLanguage: map['flower_language'] ?? '',
      referenceUrl: map['reference_url'],
    );
  }
}

/// Sightseeing-specific information for spots
class SightseeingInfo {
  final String nearbyAttractions;
  final String accessInfo;
  final String facilities;
  final String? websiteUrl;
  final List<String> images; // 追加：観光情報用の画像リスト

  const SightseeingInfo({
    required this.nearbyAttractions,
    required this.accessInfo,
    required this.facilities,
    this.websiteUrl,
    this.images = const [], // デフォルトは空リスト
  });

  factory SightseeingInfo.fromMap(Map<String, dynamic> map) {
    return SightseeingInfo(
      nearbyAttractions: map['nearby_attractions'] ?? '',
      accessInfo: map['access_info'] ?? '',
      facilities: map['facilities'] ?? '',
      websiteUrl: map['website_url'],
      images: map['images'] != null 
          ? List<String>.from(map['images']) 
          : const [],
    );
  }
}

class Spot {
  final String id;
  final String title;
  final String location;
  final String image;
  final List<String> images; // 追加：複数の画像を保持
  final String stampImage; // 追加：スタンプ専用の画像
  final String description;
  final String touristTitle;
  final String touristLocation;
  final String touristDescription;
  final double latitude;
  final double longitude;
  final bool isDemo; // デモスポットかどうかを識別
  final FlowerInfo? flowerInfo;
  final SightseeingInfo? sightseeingInfo;

  const Spot({
    required this.id,
    required this.title,
    required this.location,
    required this.image,
    this.images = const [], // デフォルトは空リスト
    String? stampImage, // オプショナルに変更
    required this.description,
    required this.touristTitle,
    required this.touristLocation,
    required this.touristDescription,
    required this.latitude,
    required this.longitude,
    this.isDemo = false, // デフォルトはfalse
    this.flowerInfo,
    this.sightseeingInfo,
  }) : stampImage = stampImage ?? image; // デフォルトとしてimageを使用

  // メインで表示する画像を取得するヘルパーメソッド
  List<String> get displayImages {
    if (images.isNotEmpty) {
      return images;
    }
    return [image]; // 既存のimageをフォールバックとして使用
  }

  factory Spot.fromMap(Map<String, dynamic> map) {
    return Spot(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      image: map['image'] ?? '',
      images: map['images'] != null 
          ? List<String>.from(map['images']) 
          : const [],
      stampImage: map['stamp_image'], // nullの場合はコンストラクタでimageを使用
      description: map['description'] ?? '',
      touristTitle: map['tourist_title'] ?? '',
      touristLocation: map['tourist_location'] ?? '',
      touristDescription: map['tourist_description'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      isDemo: map['isDemo'] ?? false,
      flowerInfo: map['flower_info'] != null 
          ? FlowerInfo.fromMap(map['flower_info']) 
          : null,
      sightseeingInfo: map['sightseeing_info'] != null 
          ? SightseeingInfo.fromMap(map['sightseeing_info']) 
          : null,
    );
  }
} 