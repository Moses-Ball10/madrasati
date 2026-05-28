import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/domain/user_model.dart';
import 'bloc/admin_bloc.dart';
import 'bloc/admin_event.dart';
import 'bloc/admin_state.dart';
import '../../../core/utils/arabic_helpers.dart';

class RegistrationRequestsScreen extends StatefulWidget {
  const RegistrationRequestsScreen({super.key});

  @override
  State<RegistrationRequestsScreen> createState() => _RegistrationRequestsScreenState();
}

class _RegistrationRequestsScreenState extends State<RegistrationRequestsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadPendingRequests());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الطلبات قيد الانتظار', style: AppTextStyles.heading3),
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

                if (state is AdminPendingLoaded) {
                  if (state.pendingUsers.isEmpty) {
                    return const Center(child: Text('لا توجد طلبات معلقة حالياً'));
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
                          DataColumn(label: Text('تاريخ الطلب')),
                          DataColumn(label: Text('الإجراءات')),
                        ],
                        rows: state.pendingUsers.map((user) {
                          return DataRow(cells: [
                            DataCell(Text(user.name)),
                            DataCell(Text(user.email)),
                            DataCell(
                              Chip(
                                label: Text(
                                  user.role == UserRole.teacher ? 'معلم' : 'طالب',
                                  style: TextStyle(color: user.role == UserRole.teacher ? AppColors.primaryBrown : Colors.blue),
                                ),
                                backgroundColor: (user.role == UserRole.teacher ? AppColors.primaryBrown : Colors.blue).withValues(alpha: 0.1),
                              ),
                            ),
                            DataCell(Text(ArabicHelpers.formatDateArabic(user.createdAt))),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check_circle, color: AppColors.success),
                                    onPressed: () {
                                      context.read<AdminBloc>().add(ApproveUser(user.uid));
                                    },
                                    tooltip: 'قبول',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: AppColors.error),
                                    onPressed: () {
                                      context.read<AdminBloc>().add(RejectUser(user.uid));
                                    },
                                    tooltip: 'رفض',
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
