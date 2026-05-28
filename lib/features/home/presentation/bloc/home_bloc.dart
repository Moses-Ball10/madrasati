import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc({required this.homeRepository}) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final categories = await homeRepository.getTopCategories();
      final recentLevels = await homeRepository.getRecentInProgressLevels(event.userId);
      emit(HomeLoaded(categories: categories, recentLevels: recentLevels));
    } catch (e) {
      emit(HomeError('حدث خطأ أثناء تحميل البيانات'));
    }
  }
}
