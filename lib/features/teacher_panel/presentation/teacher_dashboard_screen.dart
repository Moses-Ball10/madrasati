import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/teacher_bloc.dart';
import 'bloc/teacher_event.dart';
import 'bloc/teacher_state.dart';

import 'widgets/dashboard_overview_tab.dart';
import 'widgets/dashboard_registrations_tab.dart';
import 'widgets/dashboard_content_tab.dart';
import 'widgets/dashboard_results_tab.dart';
import 'widgets/dashboard_alerts_tab.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadTeacherDashboardStats());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherBloc, TeacherState>(
      builder: (context, state) {
        int categories = 0;
        int levels = 0;
        int questions = 0;
        int students = 0;

        if (state is TeacherDashboardLoaded) {
          categories = state.totalCategories;
          levels = state.totalLevels;
          questions = state.totalQuestions;
          students = state.totalStudents;
        }

        return DefaultTabController(
          length: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state is TeacherLoading)
                const LinearProgressIndicator(),
              if (state is TeacherLoading)
                const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildStatCard('الطلاب النشطين', students.toString(), Icons.people, Colors.blue)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatCard('الأسئلة', questions.toString(), Icons.question_answer, AppColors.xpGold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildStatCard('المستويات', levels.toString(), Icons.layers, AppColors.success)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatCard('إجمالي الفئات', categories.toString(), Icons.category, AppColors.primaryBrown)),
                          ],
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: _buildStatCard('الطلاب النشطين', students.toString(), Icons.people, Colors.blue)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('الأسئلة', questions.toString(), Icons.question_answer, AppColors.xpGold)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('المستويات', levels.toString(), Icons.layers, AppColors.success)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('إجمالي الفئات', categories.toString(), Icons.category, AppColors.primaryBrown)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const TabBar(
                isScrollable: false,
                labelColor: AppColors.primaryBrown,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primaryBrown,
                tabs: [
                  Tab(text: 'نظرة عامة', icon: Icon(Icons.dashboard)),
                  Tab(text: 'التسجيلات', icon: Icon(Icons.how_to_reg)),
                  Tab(text: 'المحتوى والدروس', icon: Icon(Icons.library_books)),
                  Tab(text: 'نتائج الطلاب', icon: Icon(Icons.analytics)),
                  Tab(text: 'التنبيهات', icon: Icon(Icons.notifications)),
                ],
              ),
              const SizedBox(height: 24),
              const Expanded(
                child: TabBarView(
                  children: [
                    DashboardOverviewTab(),
                    DashboardRegistrationsTab(),
                    DashboardContentTab(),
                    DashboardResultsTab(),
                    DashboardAlertsTab(),
                  ],
                ),
              ),
            ],
          ),
        );
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
