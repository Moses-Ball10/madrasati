import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Level progress status
enum LevelStatus { locked, unlocked, completed }

/// Progress data model — tracks user progress on a level
class ProgressModel extends Equatable {
  final String userId;
  final String categoryId;
  final String levelId;
  final LevelStatus status;
  final int stars;
  final int bestScore;
  final DateTime? completedAt;

  const ProgressModel({
    required this.userId,
    required this.categoryId,
    required this.levelId,
    this.status = LevelStatus.locked,
    this.stars = 0,
    this.bestScore = 0,
    this.completedAt,
  });

  factory ProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgressModel(
      userId: data['userId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      levelId: data['levelId'] as String? ?? doc.id,
      status: _parseStatus(data['status'] as String? ?? 'locked'),
      stars: data['stars'] as int? ?? 0,
      bestScore: data['bestScore'] as int? ?? 0,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory ProgressModel.fromMap(Map<String, dynamic> data) {
    return ProgressModel(
      userId: data['userId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      levelId: data['levelId'] as String? ?? '',
      status: _parseStatus(data['status'] as String? ?? 'locked'),
      stars: data['stars'] as int? ?? 0,
      bestScore: data['bestScore'] as int? ?? 0,
      completedAt: data['completedAt'] != null
          ? DateTime.tryParse(data['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'categoryId': categoryId,
      'levelId': levelId,
      'status': status.name,
      'stars': stars,
      'bestScore': bestScore,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'userId': userId,
      'categoryId': categoryId,
      'levelId': levelId,
      'status': status.name,
      'stars': stars,
      'bestScore': bestScore,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  ProgressModel copyWith({
    String? userId,
    String? categoryId,
    String? levelId,
    LevelStatus? status,
    int? stars,
    int? bestScore,
    DateTime? completedAt,
  }) {
    return ProgressModel(
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      levelId: levelId ?? this.levelId,
      status: status ?? this.status,
      stars: stars ?? this.stars,
      bestScore: bestScore ?? this.bestScore,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get isLocked => status == LevelStatus.locked;
  bool get isUnlocked => status == LevelStatus.unlocked;
  bool get isCompleted => status == LevelStatus.completed;

  static LevelStatus _parseStatus(String status) {
    switch (status) {
      case 'unlocked':
        return LevelStatus.unlocked;
      case 'completed':
        return LevelStatus.completed;
      default:
        return LevelStatus.locked;
    }
  }

  @override
  List<Object?> get props => [
        userId,
        categoryId,
        levelId,
        status,
        stars,
        bestScore,
        completedAt,
      ];
}
