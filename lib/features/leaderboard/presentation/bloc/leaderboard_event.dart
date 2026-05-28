import 'package:equatable/equatable.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class StartLeaderboardStream extends LeaderboardEvent {}

class LeaderboardUpdated extends LeaderboardEvent {
  final List<dynamic> users;

  const LeaderboardUpdated(this.users);

  @override
  List<Object?> get props => [users];
}
