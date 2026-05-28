import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/categories_repository.dart';
import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoriesRepository categoriesRepository;

  CategoriesBloc({required this.categoriesRepository}) : super(CategoriesInitial()) {
    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<CategoriesState> emit) async {
    emit(CategoriesLoading());
    try {
      final data = await categoriesRepository.getCategoriesWithStats(event.userId);
      emit(CategoriesLoaded(data));
    } catch (e) {
      emit(CategoriesError('حدث خطأ أثناء تحميل الفئات'));
    }
  }
}
