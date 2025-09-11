import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stamp.dart';
import '../models/spot.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../data/spots.dart';

// デモ設定クラス
class _DemoConfig {
  static const demoMode = bool.fromEnvironment('DEMO', defaultValue: false);
}

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

  // ローディング状態（全体）
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // スポット別ローディング状態
  Map<String, bool> _spotLoadingStates = {};
  bool isSpotLoading(String spotTitle) => _spotLoadingStates[spotTitle] ?? false;

  // 位置情報取得中
  bool _isLoadingLocation = false;
  bool get isLoadingLocation => _isLoadingLocation;

  // エラーメッセージ
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Firestoreからのリアルタイム更新用
  StreamSubscription<List<Stamp>>? _stampsSubscription;
  // Firebase認証状態の監視用
  StreamSubscription<User?>? _authSubscription;

  StampProvider() {
    _initializeAuth();
  }

  // 認証状態の監視と初期化
  void _initializeAuth() {
    print('🔐 _initializeAuth開始');
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print('👤 認証状態変更: user=${user?.email ?? user?.uid ?? 'null'}');
      
      if (user != null) {
        print('✅ ユーザー認証済み - Firestoreデータ初期化');
        // ユーザーが認証済みの場合、Firestoreからデータを取得
        _initializeStamps();
      } else {
        print('❌ ユーザー未認証 - デモモード確認');
        // 未認証の場合、デモモードで匿名認証を試行
        _handleAnonymousAuth();
      }
    });
    
    // 初期状態の確認
    final currentUser = FirebaseAuth.instance.currentUser;
    print('🔍 初期認証状態: user=${currentUser?.email ?? currentUser?.uid ?? 'null'}');
    if (currentUser != null) {
      _initializeStamps();
    }
  }

  // デモモード用の匿名認証
  Future<void> _handleAnonymousAuth() async {
    try {
      if (_DemoConfig.demoMode) {
        // デバッグモードまたはデモモードでは自動的に匿名認証
        await FirebaseAuth.instance.signInAnonymously();
        print('🧪 StampProvider: デモ用匿名認証を実行しました');
      } else {
        // 通常モードでは空の状態にリセット
        _stamps = [];
        _collectedSpotTitles = {};
        notifyListeners();
      }
    } catch (e) {
      print('StampProvider: 匿名認証に失敗しました: $e');
      _stamps = [];
      _collectedSpotTitles = {};
      notifyListeners();
    }
  }

  // 初期化
  void _initializeStamps() {
    print('🔄 _initializeStamps開始');
    // 既存のサブスクリプションをキャンセル
    _stampsSubscription?.cancel();
    
    _stampsSubscription = FirestoreService.getUserStampsStream().listen(
      (stamps) {
        print('📥 スタンプデータ受信: ${stamps.length}件');
        _stamps = stamps;
        _collectedSpotTitles = stamps.map((stamp) => stamp.spotTitle).toSet();
        print('✅ スタンプ更新完了: タイトル=${_collectedSpotTitles.toList()}');
        notifyListeners();
      },
      onError: (error) {
        print('💥 スタンプストリームエラー: $error');
        _errorMessage = 'スタンプの取得に失敗しました: $error';
        notifyListeners();
      },
      onDone: () {
        print('🏁 スタンプストリーム終了');
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
    print('🎯 collectStamp開始: ${spot.title} (isDemo: ${spot.isDemo})');
    
    // スポット個別のロード状態を設定
    _spotLoadingStates[spot.title] = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 既に取得済みかチェック
      if (_collectedSpotTitles.contains(spot.title)) {
        print('❌ 既に取得済み: ${spot.title}');
        _errorMessage = 'このスポットのスタンプは既に取得済みです';
        return false;
      }

      // デモスポットまたは demoMode=true の場合
      if (spot.isDemo || _DemoConfig.demoMode) {
        print('🧪 デモスポット処理: ${spot.title}');
        
        // デモスポットでは位置情報を偽装
        double demoLat = 37.9026;  // 新潟県の中心
        double demoLng = 139.0232;
        
        // Firestoreに保存（タイムアウト付き）
        print('💾 Firestore保存開始...');
        bool success = await FirestoreService.saveStamp(
          spot,
          demoLat,
          demoLng,
        ).timeout(
          Duration(seconds: 30),
          onTimeout: () {
            print('⏰ Firestore保存タイムアウト: ${spot.title}');
            return false;
          },
        );

        if (success) {
          print('✅ デモスタンプ保存成功: ${spot.title}');
          return true;
        } else {
          print('❌ デモスタンプ保存失敗: ${spot.title}');
          _errorMessage = 'スタンプの保存に失敗しました';
          return false;
        }
      }

      // 通常のスポット処理
      print('📍 通常スポット処理: ${spot.title}');
      
      // 位置情報を確認
      if (_currentPosition == null) {
        print('📡 位置情報取得開始...');
        await updateCurrentPosition();
        if (_currentPosition == null) {
          print('❌ 位置情報取得失敗');
          _errorMessage = '位置情報を取得できません';
          return false;
        }
        print('✅ 位置情報取得成功');
      }

      // スポットの近くにいるかチェック
      print('📏 距離判定開始...');
      bool isNear = await LocationService.isNearSpot(spot);
      if (!isNear) {
        print('❌ 距離判定失敗: 範囲外');
        _errorMessage = 'スポットの近くにいません（${LocationService.stampCollectionRadius.toInt()}m以内に近づいてください）';
        return false;
      }
      print('✅ 距離判定成功');

      // Firestoreに保存（タイムアウト付き）
      print('💾 Firestore保存開始...');
      bool success = await FirestoreService.saveStamp(
        spot,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          print('⏰ Firestore保存タイムアウト: ${spot.title}');
          return false;
        },
      );

      if (success) {
        print('✅ スタンプ保存成功: ${spot.title}');
        // 成功時は自動的にStreamから更新される
        await _updateNearbySpots(); // 近くのスポット情報を更新
        return true;
      } else {
        print('❌ スタンプ保存失敗: ${spot.title}');
        _errorMessage = 'スタンプの保存に失敗しました';
        return false;
      }
    } catch (e) {
      print('💥 collectStamp例外: $e');
      _errorMessage = 'スタンプ取得中にエラーが発生しました: $e';
      return false;
    } finally {
      print('🏁 collectStamp終了: ${spot.title}');
      // スポット個別のロード状態を解除
      _spotLoadingStates[spot.title] = false;
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
    print('🔄 refreshStamps開始');
    try {
      List<Stamp> stamps = await FirestoreService.getUserStamps();
      print('📥 手動取得スタンプ: ${stamps.length}件');
      _stamps = stamps;
      _collectedSpotTitles = stamps.map((stamp) => stamp.spotTitle).toSet();
      print('✅ 手動更新完了: タイトル=${_collectedSpotTitles.toList()}');
      notifyListeners();
    } catch (e) {
      print('💥 手動更新エラー: $e');
      _errorMessage = 'スタンプの再読み込みに失敗しました: $e';
      notifyListeners();
    }
  }

  // リソースの解放
  @override
  void dispose() {
    _stampsSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
} 
