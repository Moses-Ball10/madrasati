import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import 'package:intl/intl.dart';

class DashboardRegistrationsTab extends StatefulWidget {
  const DashboardRegistrationsTab({super.key});

  @override
  State<DashboardRegistrationsTab> createState() => _DashboardRegistrationsTabState();
}

class _DashboardRegistrationsTabState extends State<DashboardRegistrationsTab> {
  String _filter = 'الكل'; // All, Pending, Approved, Rejected

  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadDashboardStudents());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherBloc, TeacherState>(
      builder: (context, state) {
        if (state is TeacherDashboardLoaded) {
          final students = state.students;
          if (students == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredStudents = students.where((s) {
            final status = s['status'] ?? '';
            if (_filter == 'معلّق') return status == 'pending';
            if (_filter == 'مقبول') return status == 'approved';
            if (_filter == 'مرفوض') return status == 'rejected';
            return true;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.xpGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.xpGold),
                    const SizedBox(width: 8),
                    Text('الموافقة على التسجيل من صلاحيات المدير فقط', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: ['الكل', 'معلّق', 'مقبول', 'مرفوض'].map((filter) {
                  return ChoiceChip(
                    label: Text(filter),
                    selected: _filter == filter,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _filter = filter);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (filteredStudents.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('لا توجد تسجيلات مطابقة')),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Card(
                      child: DataTable(
                        headingTextStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                        columns: const [
                          DataColumn(label: Text('الاسم')),
                          DataColumn(label: Text('البريد الإلكتروني')),
                          DataColumn(label: Text('تاريخ التسجيل')),
                          DataColumn(label: Text('الحالة')),
                        ],
                        rows: filteredStudents.map((s) {
                          return DataRow(
                            cells: [
                              DataCell(Text(s['name'] ?? '')),
                              DataCell(Text(s['email'] ?? '')),
                              DataCell(Text(_formatDate(s['createdAt']))),
                              DataCell(_buildStatusBadge(s['status'] ?? 'unknown')),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = timestamp.toDate();
      return DateFormat('yyyy/MM/dd').format(dt);
    } catch (_) {
      return '';
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case 'pending':
        bgColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange[800]!;
        text = 'معلّق';
        break;
      case 'approved':
        bgColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green[800]!;
        text = 'مقبول';
        break;
      case 'rejected':
        bgColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red[800]!;
        text = 'مرفوض';
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey[800]!;
        text = 'موقوف';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
    );
  }
}
