import '../../../auth/domain/user_model.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final int totalUsers;
  final int totalStudents;
  final int totalTeachers;
  final int pendingRequests;

  AdminDashboardLoaded({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalTeachers,
    required this.pendingRequests,
  });
}

class AdminUsersLoaded extends AdminState {
  final List<UserModel> users;

  AdminUsersLoaded({required this.users});
}

class AdminPendingLoaded extends AdminState {
  final List<UserModel> pendingUsers;

  AdminPendingLoaded({required this.pendingUsers});
}

class AdminActionSuccess extends AdminState {
  final String message;

  AdminActionSuccess(this.message);
}

class AdminError extends AdminState {
  final String message;

  AdminError(this.message);
}
