import 'package:equatable/equatable.dart';
import '../../../auth/domain/user_model.dart';

/// Auth BLoC states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — hasn't checked auth yet
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading — checking auth or performing auth action
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated — user is logged in and approved
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated — no user logged in
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Pending approval — user is registered but waiting for admin approval
class AuthPendingApproval extends AuthState {
  final UserModel user;

  const AuthPendingApproval(this.user);

  @override
  List<Object?> get props => [user];
}

/// Rejected — user's registration was rejected
class AuthRejected extends AuthState {
  final String message;

  const AuthRejected({this.message = 'تم رفض طلب التسجيل'});

  @override
  List<Object?> get props => [message];
}

/// Disabled — user account has been disabled
class AuthDisabled extends AuthState {
  final String message;

  const AuthDisabled({this.message = 'تم تعطيل حسابك'});

  @override
  List<Object?> get props => [message];
}

/// Error — auth operation failed
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
