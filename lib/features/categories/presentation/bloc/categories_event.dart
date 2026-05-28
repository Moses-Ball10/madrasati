import 'package:equatable/equatable.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoriesEvent {
  final String userId;
  const LoadCategories(this.userId);
  
  @override
  List<Object?> get props => [userId];
}
