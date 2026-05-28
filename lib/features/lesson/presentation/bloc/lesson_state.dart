import 'package:equatable/equatable.dart';
import '../../domain/lesson_model.dart';

abstract class LessonState extends Equatable {
  const LessonState();
  
  @override
  List<Object?> get props => [];
}

class LessonInitial extends LessonState {}

class LessonLoading extends LessonState {}

class LessonLoaded extends LessonState {
  final LessonModel lesson;
  final int currentIndex;

  const LessonLoaded({
    required this.lesson,
    this.currentIndex = 0,
  });

  LessonLoaded copyWith({
    LessonModel? lesson,
    int? currentIndex,
  }) {
    return LessonLoaded(
      lesson: lesson ?? this.lesson,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  bool get isLastCard => currentIndex == lesson.cards.length - 1;

  @override
  List<Object?> get props => [lesson, currentIndex];
}

class LessonEmpty extends LessonState {}

class LessonError extends LessonState {
  final String message;
  const LessonError(this.message);

  @override
  List<Object?> get props => [message];
}
