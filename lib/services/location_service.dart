import 'package:geolocator/geolocator.dart';
import '../models/spot.dart';

class LocationService {
  static const double _stampCollectionRadius = 100.0; // メートル

  // 位置情報の権限を確認・取得
  static Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 位置情報サービスが有効かチェック
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 位置情報サービスが無効の場合はfalseを返す
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 権限が拒否された場合
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 権限が永続的に拒否された場合
      return false;
    }

    // 権限が許可されている場合
    return true;
  }

  // 現在位置を取得
  static Future<Position?> getCurrentPosition() async {
    try {
      bool hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } catch (e) {
      print('位置情報の取得に失敗しました: $e');
      return null;
    }
  }

  // 2つの座標間の距離を計算（メートル）
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // ユーザーがスポットの近くにいるかチェック
  static Future<bool> isNearSpot(Spot spot) async {
    Position? currentPosition = await getCurrentPosition();
    if (currentPosition == null) {
      return false;
    }

    double distance = calculateDistance(
      currentPosition.latitude,
      currentPosition.longitude,
      spot.latitude,
      spot.longitude,
    );

    return distance <= _stampCollectionRadius;
  }

  // ユーザーから最も近いスポットを取得
  static Future<Map<String, dynamic>?> getNearestSpot(List<Spot> spots) async {
    Position? currentPosition = await getCurrentPosition();
    if (currentPosition == null) {
      return null;
    }

    Spot? nearestSpot;
    double nearestDistance = double.infinity;

    for (Spot spot in spots) {
      double distance = calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        spot.latitude,
        spot.longitude,
      );

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestSpot = spot;
      }
    }

    if (nearestSpot != null) {
      return {
        'spot': nearestSpot,
        'distance': nearestDistance,
        'isWithinRange': nearestDistance <= _stampCollectionRadius,
      };
    }

    return null;
  }

  // 範囲内にあるすべてのスポットを取得
  static Future<List<Map<String, dynamic>>> getSpotsWithinRange(
      List<Spot> spots) async {
    Position? currentPosition = await getCurrentPosition();
    if (currentPosition == null) {
      return [];
    }

    List<Map<String, dynamic>> nearbySpots = [];

    for (Spot spot in spots) {
      double distance = calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        spot.latitude,
        spot.longitude,
      );

      if (distance <= _stampCollectionRadius) {
        nearbySpots.add({
          'spot': spot,
          'distance': distance,
        });
      }
    }

    // 距離でソート
    nearbySpots.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    return nearbySpots;
  }

  // スタンプ取得可能半径を取得
  static double get stampCollectionRadius => _stampCollectionRadius;

  // 位置情報設定画面を開く
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // アプリ設定画面を開く
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
} 