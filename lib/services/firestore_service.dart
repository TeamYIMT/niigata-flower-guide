import 'dart:async';
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
      print('🔐 Firestore saveStamp開始: ${spot.title}');
      
      final userId = currentUserId;
      if (userId == null) {
        print('❌ ユーザーがログインしていません');
        return false;
      }
      print('✅ ユーザーID確認: $userId');

      // 既に同じスポットのスタンプを取得済みかチェック
      print('🔍 重複チェック開始...');
      bool alreadyCollected = await hasCollectedStamp(spot.title);
      if (alreadyCollected) {
        print('❌ このスポットのスタンプは既に取得済みです: ${spot.title}');
        return false;
      }
      print('✅ 重複チェック完了: 新規スタンプ');

      // スタンプオブジェクトを作成
      print('📝 スタンプオブジェクト作成中...');
      final stampDoc = _firestore.collection(_stampsCollection).doc();
      final stamp = Stamp(
        id: stampDoc.id,
        spotTitle: spot.title,
        spotLocation: spot.location,
        spotImage: spot.stampImage, // 修正：stampImageを使用
        userId: userId,
        collectedAt: DateTime.now(),
        latitude: userLatitude,
        longitude: userLongitude,
      );
      print('✅ スタンプオブジェクト作成完了: ${stamp.id}');

      // Firestoreに保存
      print('💾 Firestore書き込み開始...');
      await stampDoc.set(stamp.toFirestore()).timeout(
        Duration(seconds: 20), // 20秒でタイムアウト
        onTimeout: () {
          print('⏰ Firestore書き込みタイムアウト');
          throw TimeoutException('Firestore書き込みがタイムアウトしました', Duration(seconds: 20));
        },
      );
      print('✅ スタンプが保存されました: ${spot.title} (ID: ${stamp.id})');
      return true;
    } catch (e) {
      print('💥 スタンプの保存に失敗しました: $e');
      print('📋 エラー詳細: ${e.toString()}');
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
    print('🔍 getUserStampsStream開始: userId=$userId');
    
    if (userId == null) {
      print('❌ ユーザーIDがnull - 空のストリームを返します');
      return Stream.value([]);
    }

    return _firestore
        .collection(_stampsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('collectedAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
          print('📦 Firestoreスナップショット受信: ${querySnapshot.docs.length}件');
          final stamps = querySnapshot.docs
              .map((doc) {
                try {
                  final stamp = Stamp.fromFirestore(doc, null);
                  print('✅ スタンプ変換成功: ${stamp.spotTitle}');
                  return stamp;
                } catch (e) {
                  print('💥 スタンプ変換エラー: $e, docId: ${doc.id}');
                  return null;
                }
              })
              .where((stamp) => stamp != null)
              .cast<Stamp>()
              .toList();
          
          print('🎯 最終スタンプリスト: ${stamps.length}件');
          return stamps;
        });
  }

  // 特定のスポットのスタンプを取得済みかチェック
  static Future<bool> hasCollectedStamp(String spotTitle) async {
    try {
      print('🔍 hasCollectedStamp開始: $spotTitle');
      
      final userId = currentUserId;
      if (userId == null) {
        print('❌ ユーザーがログインしていません');
        return false;
      }
      print('✅ ユーザーID確認: $userId');

      print('📡 Firestoreクエリ実行中...');
      
      // タイムアウト付きでクエリを実行
      final querySnapshot = await _firestore
          .collection(_stampsCollection)
          .where('userId', isEqualTo: userId)
          .where('spotTitle', isEqualTo: spotTitle)
          .limit(1)
          .get()
          .timeout(Duration(seconds: 10)); // 10秒でタイムアウト

      bool exists = querySnapshot.docs.isNotEmpty;
      print('✅ 重複チェック完了: $spotTitle - 存在=${exists}');
      return exists;
    } catch (e) {
      print('💥 スタンプ確認に失敗しました: $e');
      print('📋 エラー詳細: ${e.toString()}');
      // エラー時は重複していないものとして扱う
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