import 'package:equatable/equatable.dart';
import '../../domain/question_model.dart';

abstract class TestState extends Equatable {
  const TestState();

  @override
  List<Object?> get props => [];
}

class TestInitial extends TestState {}

class TestLoading extends TestState {}

class TestInProgress extends TestState {
  final List<QuestionModel> questions;
  final int currentIndex;
  final int hearts;
  final int score;
  final dynamic selectedAnswer;

  const TestInProgress({
    required this.questions,
    required this.currentIndex,
    required this.hearts,
    required this.score,
    this.selectedAnswer,
  });

  TestInProgress copyWith({
    List<QuestionModel>? questions,
    int? currentIndex,
    int? hearts,
    int? score,
    dynamic selectedAnswer,
  }) {
    return TestInProgress(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      hearts: hearts ?? this.hearts,
      score: score ?? this.score,
      selectedAnswer: selectedAnswer, // intentional nullable overwrite
    );
  }

  QuestionModel get currentQuestion => questions[currentIndex];
  bool get hasSelection => selectedAnswer != null;
  bool get isLastQuestion => currentIndex == questions.length - 1;

  @override
  List<Object?> get props => [questions, currentIndex, hearts, score, selectedAnswer];
}

class TestAnswerRevealed extends TestState {
  final TestInProgress currentState;
  final bool isCorrect;
  final String correctAnswerText;

  const TestAnswerRevealed({
    required this.currentState,
    required this.isCorrect,
    required this.correctAnswerText,
  });

  @override
  List<Object?> get props => [currentState, isCorrect, correctAnswerText];
}

class TestCompleted extends TestState {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int timeSeconds;
  final int heartsRemaining;
  final String categoryId;
  final String levelId;

  const TestCompleted({
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSeconds,
    required this.heartsRemaining,
    required this.categoryId,
    required this.levelId,
  });

  @override
  List<Object?> get props => [
        score,
        correctAnswers,
        totalQuestions,
        timeSeconds,
        heartsRemaining,
        categoryId,
        levelId
      ];
}

class TestError extends TestState {
  final String message;

  const TestError(this.message);

  @override
  List<Object?> get props => [message];
}

class TestEmpty extends TestState {}
