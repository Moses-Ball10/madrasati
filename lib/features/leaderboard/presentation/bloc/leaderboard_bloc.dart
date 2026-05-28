import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/leaderboard_repository.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';
import '../../../auth/domain/user_model.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository leaderboardRepository;
  StreamSubscription? _subscription;

  LeaderboardBloc({required this.leaderboardRepository})
      : super(LeaderboardInitial()) {
    on<StartLeaderboardStream>(_onStartStream);
    on<LeaderboardUpdated>(_onLeaderboardUpdated);
  }

  void _onStartStream(StartLeaderboardStream event, Emitter<LeaderboardState> emit) {
    emit(LeaderboardLoading());
    _subscription?.cancel();
    _subscription = leaderboardRepository.getLeaderboard().listen(
      (users) {
        add(LeaderboardUpdated(users));
      },
      onError: (error) {
        emit(LeaderboardError('فشل في جلب المتصدرين: $error'));
      },
    );
  }

  void _onLeaderboardUpdated(LeaderboardUpdated event, Emitter<LeaderboardState> emit) {
    emit(LeaderboardLoaded(event.users.cast<UserModel>()));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
