import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/result_repository.dart';
import 'result_event.dart';
import 'result_state.dart';

class ResultBloc extends Bloc<ResultEvent, ResultState> {
  final ResultRepository resultRepository;

  ResultBloc({required this.resultRepository}) : super(ResultInitial()) {
    on<SaveResult>(_onSaveResult);
  }

  Future<void> _onSaveResult(SaveResult event, Emitter<ResultState> emit) async {
    emit(ResultSaving());
    try {
      await resultRepository.saveResult(
        userId: event.userId,
        categoryId: event.categoryId,
        levelId: event.levelId,
        score: event.score,
        stars: event.stars,
      );
      emit(ResultSaved());
    } catch (e) {
      emit(ResultError('حدث خطأ أثناء حفظ النتيجة'));
    }
  }
}
