import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';

class DashboardOverviewTab extends StatefulWidget {
  const DashboardOverviewTab({super.key});

  @override
  State<DashboardOverviewTab> createState() => _DashboardOverviewTabState();
}

class _DashboardOverviewTabState extends State<DashboardOverviewTab> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadDashboardOverview());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherBloc, TeacherState>(
      builder: (context, state) {
        if (state is TeacherDashboardLoaded) {
          final contentStats = state.contentStats;
          final resultsStats = state.resultsStats;
          final students = state.students;

          if (contentStats == null || resultsStats == null || students == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = _buildAlertsList(contentStats, resultsStats, students);
          final hardestLevels = _getHardestLevels(resultsStats);
          final categoryProgress = _getCategoryProgress(resultsStats, contentStats);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('التنبيهات العاجلة', style: AppTextStyles.heading3),
                const SizedBox(height: 16),
                if (alerts.isEmpty)
                  _buildEmptyAlerts()
                else
                  ...alerts.map((alert) => _buildAlertCard(context, alert)).toList(),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildChartSection(
                        title: 'أصعب المستويات',
                        items: hardestLevels,
                        color: Colors.red,
                        isPercentage: true,
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: _buildChartSection(
                        title: 'تقدم الفئات',
                        items: categoryProgress,
                        color: AppColors.primaryBrown,
                        isPercentage: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        if (state is TeacherError) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  List<Map<String, dynamic>> _buildAlertsList(
    List<Map<String, dynamic>> contentStats,
    List<Map<String, dynamic>> resultsStats,
    List<Map<String, dynamic>> students,
  ) {
    List<Map<String, dynamic>> alerts = [];

    // 1. Levels without questions
    for (var s in contentStats) {
      if (s['questionsCount'] == 0) {
        alerts.add({
          'type': 'empty_questions',
          'message': 'مستوى ${s['levelName']} بدون أسئلة',
          'action': 'إضافة أسئلة ←',
          'color': Colors.red,
          'icon': Icons.warning,
          'onTap': (BuildContext context) => context.push('/teacher/question-editor/${s['categoryId']}/${s['levelId']}'),
        });
      } else if (s['cardsCount'] == 0) {
        alerts.add({
          'type': 'empty_cards',
          'message': 'مستوى ${s['levelName']} بدون بطاقات تعليمية',
          'action': 'إضافة بطاقات ←',
          'color': Colors.orange,
          'icon': Icons.warning_amber,
          'onTap': (BuildContext context) => context.push('/teacher/lesson-editor/${s['categoryId']}/${s['levelId']}'),
        });
      }
    }

    // 2. Pending registrations
    final pendingCount = students.where((s) => s['status'] == 'pending').length;
    if (pendingCount > 0) {
      alerts.add({
        'type': 'pending_registration',
        'message': '$pendingCount طالب ينتظر الموافقة',
        'action': 'مراجعة ←',
        'color': Colors.blue,
        'icon': Icons.person_add,
        'onTap': (BuildContext context) {
          // Instruct TeacherDashboardScreen to switch tabs? We can't easily without a global key, 
          // but we can just let them click it as a hint.
        },
      });
    }

    // 3. High fail rate
    for (var s in resultsStats) {
      if (s['failRate'] > 50) {
        alerts.add({
          'type': 'high_fail',
          'message': 'مستوى ${s['levelName']} نسبة رسوب ${s['failRate']}%',
          'action': 'مراجعة الأسئلة ←',
          'color': Colors.redAccent,
          'icon': Icons.trending_down,
          'onTap': (BuildContext context) {
            // Find categoryId
            final c = contentStats.firstWhere((c) => c['levelId'] == s['levelId'], orElse: () => {});
            if (c.isNotEmpty) {
              context.push('/teacher/question-editor/${c['categoryId']}/${s['levelId']}');
            }
          },
        });
      }
    }

    return alerts;
  }

  Widget _buildEmptyAlerts() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 32),
          const SizedBox(width: 16),
          Text('كل شيء على ما يرام ✓', style: AppTextStyles.heading3.copyWith(color: Colors.green[800])),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Map<String, dynamic> alert) {
    final color = alert['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(alert['icon'], color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(alert['message'], style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold))),
          TextButton(
            onPressed: () {
              final onTap = alert['onTap'] as Function(BuildContext);
              onTap(context);
            },
            child: Text(alert['action'], style: AppTextStyles.bodyMedium.copyWith(color: color, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getHardestLevels(List<Map<String, dynamic>> resultsStats) {
    var sorted = List<Map<String, dynamic>>.from(resultsStats);
    sorted.sort((a, b) => (b['failRate'] as int).compareTo(a['failRate'] as int));
    if (sorted.length > 4) sorted = sorted.sublist(0, 4);
    
    return sorted.map((s) => {
      'label': s['levelName'],
      'value': s['failRate'],
    }).toList();
  }

  List<Map<String, dynamic>> _getCategoryProgress(List<Map<String, dynamic>> resultsStats, List<Map<String, dynamic>> contentStats) {
    Map<String, List<int>> catScores = {};
    for (var s in resultsStats) {
      final cat = s['categoryName'] as String;
      if (!catScores.containsKey(cat)) catScores[cat] = [];
      catScores[cat]!.add(s['avgScore'] as int);
    }

    List<Map<String, dynamic>> progress = [];
    catScores.forEach((cat, scores) {
      final avg = scores.isNotEmpty ? scores.reduce((a, b) => a + b) ~/ scores.length : 0;
      progress.add({
        'label': cat,
        'value': avg,
      });
    });

    progress.sort((a, b) => (b['value'] as int).compareTo(a['value'] as int));
    return progress;
  }

  Widget _buildChartSection({
    required String title,
    required List<Map<String, dynamic>> items,
    required Color color,
    required bool isPercentage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.heading3),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.beigeDark),
          ),
          child: items.isEmpty
              ? const Center(child: Text('لا توجد بيانات كافية'))
              : Column(
                  children: items.map((item) {
                    final value = item['value'] as int;
                    final label = item['label'] as String;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(label, style: AppTextStyles.bodyMedium),
                              Text(isPercentage ? '$value%' : '$value', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.beigeLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: (value / 100).clamp(0.0, 1.0),
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
