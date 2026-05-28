import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/teacher_bloc.dart';
import 'bloc/teacher_event.dart';
import 'bloc/teacher_state.dart';
import '../../test_engine/domain/question_model.dart';
import 'widgets/add_question_dialog.dart';

class QuestionEditorScreen extends StatefulWidget {
  final String categoryId;
  final String levelId;
  final String levelName;
  
  const QuestionEditorScreen({
    super.key,
    required this.categoryId,
    required this.levelId,
    required this.levelName,
  });

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadQuestions(widget.categoryId, widget.levelId));
  }

  void _showAddQuestionDialog(BuildContext context) {
    final teacherBloc = context.read<TeacherBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: teacherBloc,
          child: AddQuestionDialog(
            categoryId: widget.categoryId,
            levelId: widget.levelId,
          ),
        );
      },
    );
  }

  void _showEditQuestionDialog(BuildContext context, QuestionModel question) {
    final teacherBloc = context.read<TeacherBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: teacherBloc,
          child: AddQuestionDialog(
            categoryId: widget.categoryId,
            levelId: widget.levelId,
            questionToEdit: question,
          ),
        );
      },
    );
  }

  void _showDeleteQuestionDialog(BuildContext context, QuestionModel question) {
    final teacherBloc = context.read<TeacherBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف السؤال'),
          content: const Text('هل أنت متأكد من رغبتك في حذف هذا السؤال؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                teacherBloc.add(DeleteQuestion(widget.categoryId, widget.levelId, question.id));
                Navigator.pop(dialogContext);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/teacher/categories/${widget.categoryId}/levels'),
            ),
            const SizedBox(width: 8),
            Text('الأسئلة للمستوى: ${widget.levelName}', style: AppTextStyles.heading3),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _showAddQuestionDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة سؤال جديد'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: BlocBuilder<TeacherBloc, TeacherState>(
            builder: (context, state) {
              if (state is TeacherLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is TeacherError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
              }

              if (state is TeacherQuestionsLoaded) {
                if (state.questions.isEmpty) {
                  return const Center(child: Text('لا توجد أسئلة بعد'));
                }

                return ListView.builder(
                  itemCount: state.questions.length,
                  itemBuilder: (context, index) {
                    final question = state.questions[index];
                    
                    String typeLabel = '';
                    String contentPreview = '';
                    
                    switch (question.type) {
                      case QuestionType.qcm:
                        typeLabel = 'اختيار من متعدد';
                        contentPreview = 'الخيارات: ${question.options.join("، ")}\nالإجابة الصحيحة: ${question.options.isNotEmpty && question.correctIndex < question.options.length ? question.options[question.correctIndex] : "غير محدد"}';
                        break;
                      case QuestionType.fillBlank:
                        typeLabel = 'أكمل الفراغ';
                        contentPreview = 'الجملة: ${question.sentence}\nالكلمة المخفية: ${question.answer}';
                        break;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.xpGold.withOpacity(0.2),
                          child: Text(
                            '${question.order}',
                            style: const TextStyle(
                              color: AppColors.xpGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          question.type == QuestionType.fillBlank 
                              ? 'سؤال أكمل الفراغ' 
                              : question.question,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('النوع: $typeLabel', style: const TextStyle(color: AppColors.primaryBrown)),
                              const SizedBox(height: 4),
                              Text(contentPreview),
                            ],
                          ),
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.primaryBrown),
                              onPressed: () => _showEditQuestionDialog(context, question),
                              tooltip: 'تعديل',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteQuestionDialog(context, question),
                              tooltip: 'حذف',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}
