import 'package:cloud_firestore/cloud_firestore.dart';

class Stamp {
  final String id;
  final String spotTitle;
  final String spotLocation;
  final String spotImage;
  final String userId;
  final DateTime collectedAt;
  final double latitude;
  final double longitude;

  const Stamp({
    required this.id,
    required this.spotTitle,
    required this.spotLocation,
    required this.spotImage,
    required this.userId,
    required this.collectedAt,
    required this.latitude,
    required this.longitude,
  });

  // Firestoreのドキュメントから読み込み
  factory Stamp.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Stamp(
      id: snapshot.id,
      spotTitle: data?['spotTitle'] ?? '',
      spotLocation: data?['spotLocation'] ?? '',
      spotImage: data?['spotImage'] ?? '',
      userId: data?['userId'] ?? '',
      collectedAt: (data?['collectedAt'] as Timestamp).toDate(),
      latitude: data?['latitude'] ?? 0.0,
      longitude: data?['longitude'] ?? 0.0,
    );
  }

  // Firestoreのドキュメントに保存
  Map<String, dynamic> toFirestore() {
    return {
      'spotTitle': spotTitle,
      'spotLocation': spotLocation,
      'spotImage': spotImage,
      'userId': userId,
      'collectedAt': Timestamp.fromDate(collectedAt),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // 通常のMapから読み込み
  factory Stamp.fromMap(Map<String, dynamic> map) {
    return Stamp(
      id: map['id'] ?? '',
      spotTitle: map['spotTitle'] ?? '',
      spotLocation: map['spotLocation'] ?? '',
      spotImage: map['spotImage'] ?? '',
      userId: map['userId'] ?? '',
      collectedAt: map['collectedAt'] is Timestamp 
          ? (map['collectedAt'] as Timestamp).toDate()
          : DateTime.parse(map['collectedAt']),
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
    );
  }

  // 通常のMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'spotTitle': spotTitle,
      'spotLocation': spotLocation,
      'spotImage': spotImage,
      'userId': userId,
      'collectedAt': collectedAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return 'Stamp{id: $id, spotTitle: $spotTitle, spotLocation: $spotLocation, userId: $userId, collectedAt: $collectedAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Stamp &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          spotTitle == other.spotTitle &&
          userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ spotTitle.hashCode ^ userId.hashCode;
} 