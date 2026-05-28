import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Level data model (subcollection of category)
class LevelModel extends Equatable {
  final String id;
  final String categoryId;
  final String title;
  final int order;
  final int xpReward;
  final int passThreshold;
  final bool isActive;
  final DateTime createdAt;

  const LevelModel({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.order,
    this.xpReward = 50,
    this.passThreshold = 70,
    this.isActive = true,
    required this.createdAt,
  });

  factory LevelModel.fromFirestore(DocumentSnapshot doc, String categoryId) {
    final data = doc.data() as Map<String, dynamic>;
    return LevelModel(
      id: doc.id,
      categoryId: categoryId,
      title: data['title'] as String? ?? '',
      order: data['order'] as int? ?? 0,
      xpReward: data['xpReward'] as int? ?? 50,
      passThreshold: data['passThreshold'] as int? ?? 70,
      isActive: data['isActive'] as bool? ?? true,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory LevelModel.fromMap(Map<String, dynamic> data) {
    return LevelModel(
      id: data['id'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      order: data['order'] as int? ?? 0,
      xpReward: data['xpReward'] as int? ?? 50,
      passThreshold: data['passThreshold'] as int? ?? 70,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'order': order,
      'xpReward': xpReward,
      'passThreshold': passThreshold,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'title': title,
      'order': order,
      'xpReward': xpReward,
      'passThreshold': passThreshold,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  LevelModel copyWith({
    String? id,
    String? categoryId,
    String? title,
    int? order,
    int? xpReward,
    int? passThreshold,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return LevelModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      order: order ?? this.order,
      xpReward: xpReward ?? this.xpReward,
      passThreshold: passThreshold ?? this.passThreshold,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        title,
        order,
        xpReward,
        passThreshold,
        isActive,
        createdAt,
      ];
}
