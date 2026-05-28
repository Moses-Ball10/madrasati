import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../../domain/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Auth BLoC — manages authentication state throughout the app
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  StreamSubscription? _userSubscription;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<UserUpdated>(_onUserUpdated);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.checkCurrentUser();
      if (user == null) {
        emit(const AuthUnauthenticated());
        return;
      }
      _emitStateForUser(user, emit);
      _listenToUserChanges(user.uid);
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      _emitStateForUser(user, emit);
      _listenToUserChanges(user.uid);
    } catch (e) {
      emit(AuthError(AuthRepository.getArabicErrorMessage(e)));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(AuthPendingApproval(user));
    } catch (e) {
      emit(AuthError(AuthRepository.getArabicErrorMessage(e)));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _userSubscription?.cancel();
    _userSubscription = null;
    await authRepository.signOut();
    emit(const AuthUnauthenticated());
  }

  void _onUserUpdated(
    UserUpdated event,
    Emitter<AuthState> emit,
  ) {
    final user = event.user;
    if (user is UserModel) {
      _emitStateForUser(user, emit);
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Emit the correct state based on user's role and status
  void _emitStateForUser(UserModel user, Emitter<AuthState> emit) {
    switch (user.status) {
      case UserStatus.pending:
        emit(AuthPendingApproval(user));
        break;
      case UserStatus.rejected:
        emit(const AuthRejected());
        break;
      case UserStatus.disabled:
        emit(const AuthDisabled());
        break;
      case UserStatus.approved:
        emit(AuthAuthenticated(user));
        break;
    }
  }

  /// Listen to real-time user document changes
  void _listenToUserChanges(String uid) {
    _userSubscription?.cancel();
    _userSubscription = authRepository.userStream(uid).listen(
      (user) {
        if (user != null) {
          add(UserUpdated(user));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
