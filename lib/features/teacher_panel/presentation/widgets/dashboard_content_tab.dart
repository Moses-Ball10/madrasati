import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';

class DashboardContentTab extends StatefulWidget {
  const DashboardContentTab({super.key});

  @override
  State<DashboardContentTab> createState() => _DashboardContentTabState();
}

class _DashboardContentTabState extends State<DashboardContentTab> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadDashboardContentStats());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherBloc, TeacherState>(
      builder: (context, state) {
        if (state is TeacherDashboardLoaded) {
          final stats = state.contentStats;
          if (stats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          int totalCards = 0;
          int totalQuestions = 0;
          for (var s in stats) {
            totalCards += (s['cardsCount'] as int);
            totalQuestions += (s['questionsCount'] as int);
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    child: DataTable(
                      headingTextStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      columns: const [
                        DataColumn(label: Text('الفئة')),
                        DataColumn(label: Text('المستوى')),
                        DataColumn(label: Text('بطاقات الدرس')),
                        DataColumn(label: Text('الأسئلة')),
                        DataColumn(label: Text('الحالة')),
                        DataColumn(label: Text('الإجراء')),
                      ],
                      rows: stats.map((s) {
                        final cards = s['cardsCount'] as int;
                        final questions = s['questionsCount'] as int;
                        return DataRow(
                          cells: [
                            DataCell(Text(s['categoryName'] ?? '')),
                            DataCell(Text(s['levelName'] ?? '')),
                            DataCell(Text(cards.toString())),
                            DataCell(Text(questions.toString())),
                            DataCell(_buildStatusBadge(cards, questions)),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.library_books, color: AppColors.primaryBrown),
                                  tooltip: 'تعديل الدرس',
                                  onPressed: () {
                                    context.push('/teacher/lesson-editor/${s['categoryId']}/${s['levelId']}');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.question_answer, color: AppColors.primaryBrown),
                                  tooltip: 'تعديل الأسئلة',
                                  onPressed: () {
                                    context.push('/teacher/question-editor/${s['categoryId']}/${s['levelId']}');
                                  },
                                ),
                              ],
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.beigeLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('إجمالي البطاقات: $totalCards', style: AppTextStyles.heading3),
                    Text('إجمالي الأسئلة: $totalQuestions', style: AppTextStyles.heading3),
                  ],
                ),
              )
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildStatusBadge(int cards, int questions) {
    Color bgColor;
    Color textColor;
    String text;

    if (questions == 0 && cards == 0) {
      bgColor = Colors.red.withOpacity(0.2);
      textColor = Colors.red[800]!;
      text = 'فارغ تماماً';
    } else if (questions == 0 && cards > 0) {
      bgColor = Colors.orange.withOpacity(0.2);
      textColor = Colors.orange[800]!;
      text = 'ناقص أسئلة';
    } else if (questions > 0 && cards == 0) {
      bgColor = Colors.orange.withOpacity(0.2);
      textColor = Colors.orange[800]!;
      text = 'ناقص بطاقات';
    } else {
      bgColor = Colors.green.withOpacity(0.2);
      textColor = Colors.green[800]!;
      text = 'مكتمل';
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
