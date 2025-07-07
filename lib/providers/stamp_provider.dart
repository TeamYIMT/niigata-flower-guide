import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/stamp.dart';
import '../models/spot.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../data/spots.dart';

class StampProvider with ChangeNotifier {
  // スタンプコレクション
  List<Stamp> _stamps = [];
  List<Stamp> get stamps => _stamps;

  // 取得済みスポットのタイトル
  Set<String> _collectedSpotTitles = {};
  Set<String> get collectedSpotTitles => _collectedSpotTitles;

  // 現在位置
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  // 近くのスポット情報
  List<Map<String, dynamic>> _nearbySpots = [];
  List<Map<String, dynamic>> get nearbySpots => _nearbySpots;

  // ローディング状態
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 位置情報取得中
  bool _isLoadingLocation = false;
  bool get isLoadingLocation => _isLoadingLocation;

  // エラーメッセージ
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Firestoreからのリアルタイム更新用
  StreamSubscription<List<Stamp>>? _stampsSubscription;

  StampProvider() {
    _initializeStamps();
  }

  // 初期化
  void _initializeStamps() {
    _stampsSubscription = FirestoreService.getUserStampsStream().listen(
      (stamps) {
        _stamps = stamps;
        _collectedSpotTitles = stamps.map((stamp) => stamp.spotTitle).toSet();
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'スタンプの取得に失敗しました: $error';
        notifyListeners();
      },
    );
  }

  // 現在位置を更新
  Future<void> updateCurrentPosition() async {
    _isLoadingLocation = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Position? position = await LocationService.getCurrentPosition();
      if (position != null) {
        _currentPosition = position;
        await _updateNearbySpots();
      } else {
        _errorMessage = '位置情報の取得に失敗しました';
      }
    } catch (e) {
      _errorMessage = '位置情報の取得中にエラーが発生しました: $e';
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  // 近くのスポットを更新
  Future<void> _updateNearbySpots() async {
    try {
      List<Map<String, dynamic>> nearby = await LocationService.getSpotsWithinRange(spots);
      _nearbySpots = nearby;
      notifyListeners();
    } catch (e) {
      print('近くのスポット取得エラー: $e');
    }
  }

  // スタンプを取得
  Future<bool> collectStamp(Spot spot) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 既に取得済みかチェック
      if (_collectedSpotTitles.contains(spot.title)) {
        _errorMessage = 'このスポットのスタンプは既に取得済みです';
        return false;
      }

      // 位置情報を確認
      if (_currentPosition == null) {
        await updateCurrentPosition();
        if (_currentPosition == null) {
          _errorMessage = '位置情報を取得できません';
          return false;
        }
      }

      // スポットの近くにいるかチェック
      bool isNear = await LocationService.isNearSpot(spot);
      if (!isNear) {
        _errorMessage = 'スポットの近くにいません（${LocationService.stampCollectionRadius.toInt()}m以内に近づいてください）';
        return false;
      }

      // Firestoreに保存
      bool success = await FirestoreService.saveStamp(
        spot,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (success) {
        // 成功時は自動的にStreamから更新される
        await _updateNearbySpots(); // 近くのスポット情報を更新
        return true;
      } else {
        _errorMessage = 'スタンプの保存に失敗しました';
        return false;
      }
    } catch (e) {
      _errorMessage = 'スタンプ取得中にエラーが発生しました: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 特定のスポットが取得済みかチェック
  bool isCollected(String spotTitle) {
    return _collectedSpotTitles.contains(spotTitle);
  }

  // スタンプ数を取得
  int get stampCount => _stamps.length;

  // 特定のスポットが範囲内にあるかチェック
  bool isSpotInRange(Spot spot) {
    return _nearbySpots.any((nearby) => 
      (nearby['spot'] as Spot).title == spot.title
    );
  }

  // 特定のスポットまでの距離を取得
  double? getDistanceToSpot(Spot spot) {
    try {
      final nearbySpot = _nearbySpots.firstWhere(
        (nearby) => (nearby['spot'] as Spot).title == spot.title
      );
      return nearbySpot['distance'] as double;
    } catch (e) {
      return null;
    }
  }

  // スタンプを削除
  Future<bool> deleteStamp(String stampId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool success = await FirestoreService.deleteStamp(stampId);
      if (success) {
        // 成功時は自動的にStreamから更新される
        return true;
      } else {
        _errorMessage = 'スタンプの削除に失敗しました';
        return false;
      }
    } catch (e) {
      _errorMessage = 'スタンプ削除中にエラーが発生しました: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // エラーメッセージをクリア
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 手動でスタンプを再読み込み
  Future<void> refreshStamps() async {
    try {
      List<Stamp> stamps = await FirestoreService.getUserStamps();
      _stamps = stamps;
      _collectedSpotTitles = stamps.map((stamp) => stamp.spotTitle).toSet();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'スタンプの再読み込みに失敗しました: $e';
      notifyListeners();
    }
  }

  // リソースの解放
  @override
  void dispose() {
    _stampsSubscription?.cancel();
    super.dispose();
  }
} 