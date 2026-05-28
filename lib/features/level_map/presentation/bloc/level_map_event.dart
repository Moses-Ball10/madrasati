import 'package:equatable/equatable.dart';

abstract class LevelMapEvent extends Equatable {
  const LevelMapEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadLevelMap extends LevelMapEvent {
  final String categoryId;
  final String userId;

  const LoadLevelMap({required this.categoryId, required this.userId});
  
  @override
  List<Object?> get props => [categoryId, userId];
}
