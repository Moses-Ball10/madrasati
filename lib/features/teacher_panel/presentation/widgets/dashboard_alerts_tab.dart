import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import 'package:intl/intl.dart';

class DashboardAlertsTab extends StatefulWidget {
  const DashboardAlertsTab({super.key});

  @override
  State<DashboardAlertsTab> createState() => _DashboardAlertsTabState();
}

class _DashboardAlertsTabState extends State<DashboardAlertsTab> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadDashboardActivityLogs());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherBloc, TeacherState>(
      builder: (context, state) {
        if (state is TeacherDashboardLoaded) {
          final logs = state.logs;
          if (logs == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (logs.isEmpty) {
            return const Center(child: Text('لا توجد نشاطات بعد'));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: _buildIcon(log.type),
                  title: Text(log.title, style: AppTextStyles.bodyLarge),
                  subtitle: Text(log.body, style: AppTextStyles.bodyMedium),
                  trailing: Text(
                    DateFormat('yyyy/MM/dd HH:mm').format(log.timestamp),
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildIcon(String type) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'student_registered':
        iconData = Icons.person_add;
        color = AppColors.primaryBrown;
        break;
      case 'student_approved':
        iconData = Icons.how_to_reg;
        color = AppColors.success;
        break;
      case 'level_completed':
        iconData = Icons.star;
        color = AppColors.xpGold;
        break;
      case 'level_failed':
        iconData = Icons.sentiment_very_dissatisfied;
        color = AppColors.error;
        break;
      case 'content_added':
        iconData = Icons.add_circle_outline;
        color = AppColors.primaryBrown;
        break;
      default:
        iconData = Icons.info_outline;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color),
    );
  }
}
