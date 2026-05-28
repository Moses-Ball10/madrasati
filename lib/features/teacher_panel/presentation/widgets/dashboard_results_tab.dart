import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';

class DashboardResultsTab extends StatefulWidget {
  const DashboardResultsTab({super.key});

  @override
  State<DashboardResultsTab> createState() => _DashboardResultsTabState();
}

class _DashboardResultsTabState extends State<DashboardResultsTab> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadDashboardResultsStats());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherBloc, TeacherState>(
      builder: (context, state) {
        if (state is TeacherDashboardLoaded) {
          final stats = state.resultsStats;
          if (stats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (stats.isEmpty) {
            return const Center(child: Text('لا توجد بيانات كافية بعد'));
          }

          int totalAttempts = 0;
          int sumScores = 0;
          int sumPassRates = 0;
          String mostFailedLevel = '';
          int maxFails = -1;

          for (var s in stats) {
            final attempts = s['attempts'] as int;
            final avgScore = s['avgScore'] as int;
            final failRate = s['failRate'] as int;
            final passRate = s['passRate'] as int;

            totalAttempts += attempts;
            sumScores += (avgScore * attempts);
            sumPassRates += (passRate * attempts);

            if (failRate > maxFails) {
              maxFails = failRate;
              mostFailedLevel = s['levelName'] ?? '';
            }
          }

          final overallAvg = totalAttempts > 0 ? (sumScores / totalAttempts).round() : 0;
          final overallPass = totalAttempts > 0 ? (sumPassRates / totalAttempts).round() : 0;

          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('متوسط النتيجة', '$overallAvg%', Icons.score)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('نسبة النجاح', '$overallPass%', Icons.check_circle)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('إجمالي المحاولات', '$totalAttempts', Icons.repeat)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('المستوى الأصعب', mostFailedLevel, Icons.warning, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    child: DataTable(
                      headingTextStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      columns: const [
                        DataColumn(label: Text('الفئة')),
                        DataColumn(label: Text('المستوى')),
                        DataColumn(label: Text('المحاولات')),
                        DataColumn(label: Text('متوسط النتيجة')),
                        DataColumn(label: Text('نسبة النجاح')),
                        DataColumn(label: Text('نسبة الرسوب')),
                      ],
                      rows: stats.map((s) {
                        final failRate = s['failRate'] as int;
                        Color failColor = Colors.green;
                        if (failRate > 50) {
                          failColor = Colors.red;
                        } else if (failRate >= 20) {
                          failColor = Colors.orange;
                        }

                        return DataRow(
                          cells: [
                            DataCell(Text(s['categoryName'] ?? '')),
                            DataCell(Text(s['levelName'] ?? '')),
                            DataCell(Text(s['attempts'].toString())),
                            DataCell(Text('${s['avgScore']}%')),
                            DataCell(Text('${s['passRate']}%')),
                            DataCell(Text('${s['failRate']}%', style: TextStyle(color: failColor, fontWeight: FontWeight.bold))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('الأسئلة الأكثر إخفاقاً', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text('لا توجد بيانات كافية بعد', style: AppTextStyles.bodyMedium),
                  ),
                ),
              )
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, {Color color = AppColors.primaryBrown}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.beigeDark),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.heading2.copyWith(color: color)),
        ],
      ),
    );
  }
}
