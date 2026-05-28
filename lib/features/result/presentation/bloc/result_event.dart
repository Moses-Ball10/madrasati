import 'package:equatable/equatable.dart';

abstract class ResultEvent extends Equatable {
  const ResultEvent();

  @override
  List<Object?> get props => [];
}

class SaveResult extends ResultEvent {
  final String userId;
  final String categoryId;
  final String levelId;
  final int score;
  final int stars;

  const SaveResult({
    required this.userId,
    required this.categoryId,
    required this.levelId,
    required this.score,
    required this.stars,
  });

  @override
  List<Object?> get props => [userId, categoryId, levelId, score, stars];
}
