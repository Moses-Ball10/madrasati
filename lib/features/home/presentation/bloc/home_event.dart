import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  final String userId;
  const LoadHomeData(this.userId);
  
  @override
  List<Object?> get props => [userId];
}
