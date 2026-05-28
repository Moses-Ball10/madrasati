import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/level_repository.dart';
import 'level_map_event.dart';
import 'level_map_state.dart';

class LevelMapBloc extends Bloc<LevelMapEvent, LevelMapState> {
  final LevelRepository levelRepository;

  LevelMapBloc({required this.levelRepository}) : super(LevelMapInitial()) {
    on<LoadLevelMap>(_onLoadLevelMap);
  }

  Future<void> _onLoadLevelMap(LoadLevelMap event, Emitter<LevelMapState> emit) async {
    emit(LevelMapLoading());
    try {
      final category = await levelRepository.getCategory(event.categoryId);
      final levelsData = await levelRepository.getLevelsWithProgress(event.categoryId, event.userId);
      emit(LevelMapLoaded(category: category, levelsData: levelsData));
    } catch (e) {
      emit(LevelMapError('حدث خطأ أثناء تحميل خريطة المستويات'));
    }
  }
}
