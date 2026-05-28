import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/lesson_repository.dart';
import 'lesson_event.dart';
import 'lesson_state.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final LessonRepository lessonRepository;

  LessonBloc({required this.lessonRepository}) : super(LessonInitial()) {
    on<LoadLesson>(_onLoadLesson);
    on<NextCard>(_onNextCard);
    on<PreviousCard>(_onPreviousCard);
  }

  Future<void> _onLoadLesson(LoadLesson event, Emitter<LessonState> emit) async {
    emit(LessonLoading());
    try {
      final lesson = await lessonRepository.getLessonForLevel(event.categoryId, event.levelId);
      if (lesson == null || lesson.cards.isEmpty) {
        emit(LessonEmpty());
      } else {
        emit(LessonLoaded(lesson: lesson, currentIndex: 0));
      }
    } catch (e) {
      emit(LessonError('حدث خطأ أثناء تحميل الدرس'));
    }
  }

  void _onNextCard(NextCard event, Emitter<LessonState> emit) {
    if (state is LessonLoaded) {
      final currentState = state as LessonLoaded;
      if (currentState.currentIndex < currentState.lesson.cards.length - 1) {
        emit(currentState.copyWith(currentIndex: currentState.currentIndex + 1));
      }
    }
  }

  void _onPreviousCard(PreviousCard event, Emitter<LessonState> emit) {
    if (state is LessonLoaded) {
      final currentState = state as LessonLoaded;
      if (currentState.currentIndex > 0) {
        emit(currentState.copyWith(currentIndex: currentState.currentIndex - 1));
      }
    }
  }
}
