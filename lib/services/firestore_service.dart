import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stamp.dart';
import '../models/spot.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // スタンプコレクションの参照
  static const String _stampsCollection = 'stamps';

  // 現在のユーザーIDを取得
  static String? get currentUserId => _auth.currentUser?.uid;

  // スタンプを保存
  static Future<bool> saveStamp(Spot spot, double userLatitude, double userLongitude) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        print('ユーザーがログインしていません');
        return false;
      }

      // 既に同じスポットのスタンプを取得済みかチェック
      bool alreadyCollected = await hasCollectedStamp(spot.title);
      if (alreadyCollected) {
        print('このスポットのスタンプは既に取得済みです');
        return false;
      }

      // スタンプオブジェクトを作成
      final stampDoc = _firestore.collection(_stampsCollection).doc();
      final stamp = Stamp(
        id: stampDoc.id,
        spotTitle: spot.title,
        spotLocation: spot.location,
        spotImage: spot.image,
        userId: userId,
        collectedAt: DateTime.now(),
        latitude: userLatitude,
        longitude: userLongitude,
      );

      // Firestoreに保存
      await stampDoc.set(stamp.toFirestore());
      print('スタンプが保存されました: ${spot.title}');
      return true;
    } catch (e) {
      print('スタンプの保存に失敗しました: $e');
      return false;
    }
  }

  // ユーザーの全スタンプを取得
  static Future<List<Stamp>> getUserStamps() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        print('ユーザーがログインしていません');
        return [];
      }

      final querySnapshot = await _firestore
          .collection(_stampsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('collectedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Stamp.fromFirestore(doc, null))
          .toList();
    } catch (e) {
      print('スタンプの取得に失敗しました: $e');
      return [];
    }
  }

  // ユーザーの全スタンプをリアルタイムで監視
  static Stream<List<Stamp>> getUserStampsStream() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_stampsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('collectedAt', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => Stamp.fromFirestore(doc, null))
            .toList());
  }

  // 特定のスポットのスタンプを取得済みかチェック
  static Future<bool> hasCollectedStamp(String spotTitle) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return false;
      }

      final querySnapshot = await _firestore
          .collection(_stampsCollection)
          .where('userId', isEqualTo: userId)
          .where('spotTitle', isEqualTo: spotTitle)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('スタンプ確認に失敗しました: $e');
      return false;
    }
  }

  // 取得済みスポットのタイトル一覧を取得
  static Future<Set<String>> getCollectedSpotTitles() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return {};
      }

      final querySnapshot = await _firestore
          .collection(_stampsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['spotTitle'] as String)
          .toSet();
    } catch (e) {
      print('取得済みスポット一覧の取得に失敗しました: $e');
      return {};
    }
  }

  // スタンプの数を取得
  static Future<int> getStampCount() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return 0;
      }

      final querySnapshot = await _firestore
          .collection(_stampsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('スタンプ数の取得に失敗しました: $e');
      return 0;
    }
  }

  // スタンプを削除
  static Future<bool> deleteStamp(String stampId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        print('ユーザーがログインしていません');
        return false;
      }

      // スタンプが本人のものかチェック
      final stampDoc = await _firestore
          .collection(_stampsCollection)
          .doc(stampId)
          .get();

      if (!stampDoc.exists) {
        print('スタンプが見つかりません');
        return false;
      }

      final stampData = stampDoc.data();
      if (stampData?['userId'] != userId) {
        print('他のユーザーのスタンプは削除できません');
        return false;
      }

      // スタンプを削除
      await _firestore.collection(_stampsCollection).doc(stampId).delete();
      print('スタンプが削除されました');
      return true;
    } catch (e) {
      print('スタンプの削除に失敗しました: $e');
      return false;
    }
  }

  // 特定の期間のスタンプを取得
  static Future<List<Stamp>> getStampsInDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return [];
      }

      final querySnapshot = await _firestore
          .collection(_stampsCollection)
          .where('userId', isEqualTo: userId)
          .where('collectedAt', isGreaterThanOrEqualTo: startDate)
          .where('collectedAt', isLessThanOrEqualTo: endDate)
          .orderBy('collectedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Stamp.fromFirestore(doc, null))
          .toList();
    } catch (e) {
      print('期間指定スタンプの取得に失敗しました: $e');
      return [];
    }
  }
} 