import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/domain/user_model.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AuthRepository authRepository;

  AdminBloc({required this.authRepository}) : super(AdminInitial()) {
    on<LoadDashboardStats>(_onLoadDashboardStats);
    on<LoadUsers>(_onLoadUsers);
    on<LoadPendingRequests>(_onLoadPendingRequests);
    on<ApproveUser>(_onApproveUser);
    on<RejectUser>(_onRejectUser);
    on<UpdateUserStatusEvent>(_onUpdateUserStatus);
    on<UpdateUserRoleEvent>(_onUpdateUserRole);
  }

  Future<void> _onLoadDashboardStats(LoadDashboardStats event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final users = await authRepository.getAllUsers();
      final students = users.where((u) => u.role == UserRole.student).length;
      final teachers = users.where((u) => u.role == UserRole.teacher).length;
      final pending = users.where((u) => u.status == UserStatus.pending).length;

      emit(AdminDashboardLoaded(
        totalUsers: users.length,
        totalStudents: students,
        totalTeachers: teachers,
        pendingRequests: pending,
      ));
    } catch (e) {
      emit(AdminError('فشل في تحميل الإحصائيات: $e'));
    }
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final users = await authRepository.getAllUsers();
      emit(AdminUsersLoaded(users: users));
    } catch (e) {
      emit(AdminError('فشل في تحميل المستخدمين: $e'));
    }
  }

  Future<void> _onLoadPendingRequests(LoadPendingRequests event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final pendingUsers = await authRepository.getPendingUsers();
      emit(AdminPendingLoaded(pendingUsers: pendingUsers));
    } catch (e) {
      emit(AdminError('فشل في تحميل الطلبات: $e'));
    }
  }

  Future<void> _onApproveUser(ApproveUser event, Emitter<AdminState> emit) async {
    try {
      await authRepository.updateUserStatus(event.uid, UserStatus.approved);
      add(LoadPendingRequests());
    } catch (e) {
      emit(AdminError('فشل في الموافقة على المستخدم: $e'));
    }
  }

  Future<void> _onRejectUser(RejectUser event, Emitter<AdminState> emit) async {
    try {
      await authRepository.updateUserStatus(event.uid, UserStatus.rejected);
      add(LoadPendingRequests());
    } catch (e) {
      emit(AdminError('فشل في رفض المستخدم: $e'));
    }
  }

  Future<void> _onUpdateUserStatus(UpdateUserStatusEvent event, Emitter<AdminState> emit) async {
    try {
      await authRepository.updateUserStatus(event.uid, event.status);
      add(LoadUsers());
    } catch (e) {
      emit(AdminError('فشل في تحديث حالة المستخدم: $e'));
    }
  }

  Future<void> _onUpdateUserRole(UpdateUserRoleEvent event, Emitter<AdminState> emit) async {
    try {
      await authRepository.updateUserRole(event.uid, event.role);
      add(LoadUsers());
    } catch (e) {
      emit(AdminError('فشل في تغيير دور المستخدم: $e'));
    }
  }
}
