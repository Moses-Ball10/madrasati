import 'package:equatable/equatable.dart';

abstract class LessonEvent extends Equatable {
  const LessonEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadLesson extends LessonEvent {
  final String categoryId;
  final String levelId;

  const LoadLesson({required this.categoryId, required this.levelId});
  
  @override
  List<Object?> get props => [categoryId, levelId];
}

class NextCard extends LessonEvent {}

class PreviousCard extends LessonEvent {}
