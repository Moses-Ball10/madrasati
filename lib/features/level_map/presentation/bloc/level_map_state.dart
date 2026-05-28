import 'package:equatable/equatable.dart';
import '../../../categories/domain/category_model.dart';

abstract class LevelMapState extends Equatable {
  const LevelMapState();
  
  @override
  List<Object?> get props => [];
}

class LevelMapInitial extends LevelMapState {}

class LevelMapLoading extends LevelMapState {}

class LevelMapLoaded extends LevelMapState {
  final CategoryModel category;
  final List<Map<String, dynamic>> levelsData;

  const LevelMapLoaded({
    required this.category,
    required this.levelsData,
  });

  @override
  List<Object?> get props => [category, levelsData];
}

class LevelMapError extends LevelMapState {
  final String message;
  const LevelMapError(this.message);

  @override
  List<Object?> get props => [message];
}
