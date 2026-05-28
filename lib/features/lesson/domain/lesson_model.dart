import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// A single lesson card content
class LessonCard extends Equatable {
  final String icon;
  final String title;
  final String body;

  const LessonCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  factory LessonCard.fromMap(Map<String, dynamic> data) {
    return LessonCard(
      icon: data['icon'] as String? ?? '📖',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'icon': icon,
      'title': title,
      'body': body,
    };
  }

  LessonCard copyWith({
    String? icon,
    String? title,
    String? body,
  }) {
    return LessonCard(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  @override
  List<Object?> get props => [icon, title, body];
}

/// Lesson data model — contains a list of cards
class LessonModel extends Equatable {
  final String id;
  final String levelId;
  final int order;
  final List<LessonCard> cards;
  final DateTime createdAt;

  const LessonModel({
    required this.id,
    required this.levelId,
    required this.order,
    required this.cards,
    required this.createdAt,
  });

  factory LessonModel.fromFirestore(DocumentSnapshot doc, String levelId) {
    final data = doc.data() as Map<String, dynamic>;
    final rawCards = data['cards'] as List<dynamic>? ?? [];
    return LessonModel(
      id: doc.id,
      levelId: levelId,
      order: data['order'] as int? ?? 0,
      cards: rawCards
          .map((c) => LessonCard.fromMap(c as Map<String, dynamic>))
          .toList(),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory LessonModel.fromMap(Map<String, dynamic> data) {
    final rawCards = data['cards'] as List<dynamic>? ?? [];
    return LessonModel(
      id: data['id'] as String? ?? '',
      levelId: data['levelId'] as String? ?? '',
      order: data['order'] as int? ?? 0,
      cards: rawCards
          .map((c) => LessonCard.fromMap(c as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'levelId': levelId,
      'order': order,
      'cards': cards.map((c) => c.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'id': id,
      'levelId': levelId,
      'order': order,
      'cards': cards.map((c) => c.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  LessonModel copyWith({
    String? id,
    String? levelId,
    int? order,
    List<LessonCard>? cards,
    DateTime? createdAt,
  }) {
    return LessonModel(
      id: id ?? this.id,
      levelId: levelId ?? this.levelId,
      order: order ?? this.order,
      cards: cards ?? this.cards,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, levelId, order, cards, createdAt];
}
