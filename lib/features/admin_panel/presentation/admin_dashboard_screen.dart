import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'bloc/admin_bloc.dart';
import 'bloc/admin_event.dart';
import 'bloc/admin_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadDashboardStats());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading || state is AdminInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminError) {
          return Center(child: Text(state.message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)));
        }

        if (state is AdminDashboardLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildStatCard('إجمالي المستخدمين', state.totalUsers.toString(), Icons.people, AppColors.primaryBrown)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatCard('الطلاب', state.totalStudents.toString(), Icons.school, Colors.blue)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildStatCard('المعلمين', state.totalTeachers.toString(), Icons.assignment_ind, AppColors.success)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatCard('طلبات قيد الانتظار', state.pendingRequests.toString(), Icons.pending_actions, AppColors.error)),
                          ],
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: _buildStatCard('إجمالي المستخدمين', state.totalUsers.toString(), Icons.people, AppColors.primaryBrown)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('الطلاب', state.totalStudents.toString(), Icons.school, Colors.blue)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('المعلمين', state.totalTeachers.toString(), Icons.assignment_ind, AppColors.success)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('طلبات قيد الانتظار', state.pendingRequests.toString(), Icons.pending_actions, AppColors.error)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
              Text('ملخص النظام', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: Center(
                    child: Text('سيتم عرض المخططات والإحصائيات هنا...', style: AppTextStyles.bodyMedium),
                  ),
                ),
              )
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.beigeDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.heading2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
