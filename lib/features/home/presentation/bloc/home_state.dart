import 'package:equatable/equatable.dart';
import '../../../categories/domain/category_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CategoryModel> categories;
  final List<Map<String, dynamic>> recentLevels;

  const HomeLoaded({
    required this.categories,
    required this.recentLevels,
  });

  @override
  List<Object?> get props => [categories, recentLevels];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
