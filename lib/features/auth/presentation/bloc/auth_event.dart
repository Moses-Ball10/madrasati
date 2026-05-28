import 'package:equatable/equatable.dart';

/// Auth BLoC events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Request login with email + password
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Request registration with name, email, password
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

/// Request logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Check current auth status (on app launch)
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// User data updated (from Firestore stream)
class UserUpdated extends AuthEvent {
  final dynamic user;

  const UserUpdated(this.user);

  @override
  List<Object?> get props => [user];
}
