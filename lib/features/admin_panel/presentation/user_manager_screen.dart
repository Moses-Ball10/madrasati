import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/domain/user_model.dart';
import 'bloc/admin_bloc.dart';
import 'bloc/admin_event.dart';
import 'bloc/admin_state.dart';

class UserManagerScreen extends StatefulWidget {
  const UserManagerScreen({super.key});

  @override
  State<UserManagerScreen> createState() => _UserManagerScreenState();
}

class _UserManagerScreenState extends State<UserManagerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('المستخدمين النشطين', style: AppTextStyles.heading3),
            SizedBox(
              width: 300,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'بحث بالاسم أو البريد...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Card(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminLoading || state is AdminInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AdminError) {
                  return Center(child: Text(state.message));
                }

                if (state is AdminUsersLoaded) {
                  if (state.users.isEmpty) {
                    return const Center(child: Text('لا يوجد مستخدمين'));
                  }

                  return SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppColors.beige),
                        columns: const [
                          DataColumn(label: Text('الاسم')),
                          DataColumn(label: Text('البريد الإلكتروني')),
                          DataColumn(label: Text('الدور')),
                          DataColumn(label: Text('نقاط XP')),
                          DataColumn(label: Text('الحالة')),
                          DataColumn(label: Text('الإجراءات')),
                        ],
                        rows: state.users.map((user) {
                          return DataRow(cells: [
                            DataCell(Text(user.name)),
                            DataCell(Text(user.email)),
                            DataCell(
                              DropdownButton<UserRole>(
                                value: user.role,
                                underline: const SizedBox(),
                                borderRadius: BorderRadius.circular(8),
                                items: const [
                                  DropdownMenuItem(value: UserRole.student, child: Text('طالب')),
                                  DropdownMenuItem(value: UserRole.teacher, child: Text('معلم')),
                                  DropdownMenuItem(value: UserRole.admin, child: Text('مسؤول')),
                                ],
                                onChanged: (newRole) {
                                  if (newRole != null && newRole != user.role) {
                                    context.read<AdminBloc>().add(UpdateUserRoleEvent(user.uid, newRole));
                                  }
                                },
                              ),
                            ),
                            DataCell(Text(user.xp.toString())),
                            DataCell(
                              Chip(
                                label: Text(
                                  user.status == UserStatus.approved ? 'نشط' : (user.status == UserStatus.pending ? 'انتظار' : 'مرفوض/معطل'),
                                  style: TextStyle(color: user.status == UserStatus.approved ? AppColors.success : AppColors.error),
                                ),
                                backgroundColor: (user.status == UserStatus.approved ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (user.status == UserStatus.approved)
                                    IconButton(
                                      icon: const Icon(Icons.block, color: AppColors.error),
                                      onPressed: () {
                                        context.read<AdminBloc>().add(UpdateUserStatusEvent(user.uid, UserStatus.disabled));
                                      },
                                      tooltip: 'تعطيل الحساب',
                                    ),
                                  if (user.status == UserStatus.disabled || user.status == UserStatus.rejected)
                                    IconButton(
                                      icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
                                      onPressed: () {
                                        context.read<AdminBloc>().add(UpdateUserStatusEvent(user.uid, UserStatus.approved));
                                      },
                                      tooltip: 'تفعيل الحساب',
                                    ),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ),
      ],
    );
  }
}
