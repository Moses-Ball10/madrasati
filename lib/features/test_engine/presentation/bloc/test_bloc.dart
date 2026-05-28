import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/test_repository.dart';
import 'test_event.dart';
import 'test_state.dart';

class TestBloc extends Bloc<TestEvent, TestState> {
  final TestRepository testRepository;
  
  String _categoryId = '';
  String _levelId = '';
  DateTime? _startTime;

  TestBloc({required this.testRepository}) : super(TestInitial()) {
    on<LoadTest>(_onLoadTest);
    on<AnswerSelected>(_onAnswerSelected);
    on<AnswerConfirmed>(_onAnswerConfirmed);
    on<NextQuestion>(_onNextQuestion);
  }

  Future<void> _onLoadTest(LoadTest event, Emitter<TestState> emit) async {
    emit(TestLoading());
    try {
      _categoryId = event.categoryId;
      _levelId = event.levelId;
      _startTime = DateTime.now();

      final questions = await testRepository.getQuestionsForLevel(_categoryId, _levelId);
      
      if (questions.isEmpty) {
        emit(TestEmpty());
        return;
      }

      emit(TestInProgress(
        questions: questions,
        currentIndex: 0,
        hearts: AppConstants.initialHearts,
        score: 0,
        selectedAnswer: null,
      ));
    } catch (e) {
      emit(TestError('حدث خطأ أثناء تحميل الاختبار'));
    }
  }

  void _onAnswerSelected(AnswerSelected event, Emitter<TestState> emit) {
    if (state is TestInProgress) {
      final currentState = state as TestInProgress;
      emit(currentState.copyWith(selectedAnswer: event.answer));
    }
  }

  void _onAnswerConfirmed(AnswerConfirmed event, Emitter<TestState> emit) {
    if (state is TestInProgress) {
      final currentState = state as TestInProgress;
      final question = currentState.currentQuestion;
      
      if (!currentState.hasSelection) return;

      final isCorrect = question.checkAnswer(currentState.selectedAnswer);
      final correctAnswerText = question.correctAnswerText;

      emit(TestAnswerRevealed(
        currentState: currentState,
        isCorrect: isCorrect,
        correctAnswerText: correctAnswerText,
      ));
    }
  }

  void _onNextQuestion(NextQuestion event, Emitter<TestState> emit) {
    if (state is TestAnswerRevealed) {
      final revealedState = state as TestAnswerRevealed;
      final currentState = revealedState.currentState;
      
      int newHearts = currentState.hearts;
      int newScore = currentState.score;

      if (revealedState.isCorrect) {
        newScore++;
      } else {
        newHearts--;
      }

      if (newHearts <= 0) {
        _emitCompleted(emit, newScore, 0, currentState.questions.length);
        return;
      }

      if (currentState.isLastQuestion) {
        _emitCompleted(emit, newScore, newHearts, currentState.questions.length);
      } else {
        emit(currentState.copyWith(
          currentIndex: currentState.currentIndex + 1,
          hearts: newHearts,
          score: newScore,
          selectedAnswer: null, // Clear selection for next
        ));
      }
    }
  }

  void _emitCompleted(Emitter<TestState> emit, int correctAnswers, int hearts, int total) {
    final timeSeconds = DateTime.now().difference(_startTime ?? DateTime.now()).inSeconds;
    final scorePercent = (correctAnswers / total * 100).round();
    
    emit(TestCompleted(
      score: scorePercent,
      correctAnswers: correctAnswers,
      totalQuestions: total,
      timeSeconds: timeSeconds,
      heartsRemaining: hearts,
      categoryId: _categoryId,
      levelId: _levelId,
    ));
  }
}
