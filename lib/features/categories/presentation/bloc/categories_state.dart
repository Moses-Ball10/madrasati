import 'package:equatable/equatable.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();
  
  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<Map<String, dynamic>> categoriesWithStats;

  const CategoriesLoaded(this.categoriesWithStats);

  @override
  List<Object?> get props => [categoriesWithStats];
}

class CategoriesError extends CategoriesState {
  final String message;
  const CategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}
