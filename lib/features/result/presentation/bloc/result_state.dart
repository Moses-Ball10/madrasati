import 'package:equatable/equatable.dart';

abstract class ResultState extends Equatable {
  const ResultState();

  @override
  List<Object?> get props => [];
}

class ResultInitial extends ResultState {}

class ResultSaving extends ResultState {}

class ResultSaved extends ResultState {}

class ResultError extends ResultState {
  final String message;

  const ResultError(this.message);

  @override
  List<Object?> get props => [message];
}
