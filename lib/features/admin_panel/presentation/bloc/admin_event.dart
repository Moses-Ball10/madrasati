import '../../../auth/domain/user_model.dart';

abstract class AdminEvent {}

class LoadDashboardStats extends AdminEvent {}

class LoadUsers extends AdminEvent {}

class LoadPendingRequests extends AdminEvent {}

class ApproveUser extends AdminEvent {
  final String uid;

  ApproveUser(this.uid);
}

class RejectUser extends AdminEvent {
  final String uid;

  RejectUser(this.uid);
}

class UpdateUserStatusEvent extends AdminEvent {
  final String uid;
  final UserStatus status;

  UpdateUserStatusEvent(this.uid, this.status);
}

class UpdateUserRoleEvent extends AdminEvent {
  final String uid;
  final UserRole role;

  UpdateUserRoleEvent(this.uid, this.role);
}
