import 'package:equatable/equatable.dart';

abstract class TestEvent extends Equatable {
  const TestEvent();

  @override
  List<Object?> get props => [];
}

class LoadTest extends TestEvent {
  final String categoryId;
  final String levelId;

  const LoadTest({required this.categoryId, required this.levelId});

  @override
  List<Object?> get props => [categoryId, levelId];
}

class AnswerSelected extends TestEvent {
  final dynamic answer;

  const AnswerSelected(this.answer);

  @override
  List<Object?> get props => [answer];
}

class AnswerConfirmed extends TestEvent {}

class NextQuestion extends TestEvent {}
