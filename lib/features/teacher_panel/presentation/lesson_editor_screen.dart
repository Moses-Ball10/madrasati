import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'bloc/teacher_bloc.dart';
import 'bloc/teacher_event.dart';
import 'bloc/teacher_state.dart';

import '../../lesson/domain/lesson_model.dart';

class LessonEditorScreen extends StatefulWidget {
  final String categoryId;
  final String levelId;
  final String levelName;
  
  const LessonEditorScreen({
    super.key,
    required this.categoryId,
    required this.levelId,
    required this.levelName,
  });

  @override
  State<LessonEditorScreen> createState() => _LessonEditorScreenState();
}

class _LessonEditorScreenState extends State<LessonEditorScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadLessons(widget.categoryId, widget.levelId));
  }

  void _showAddLessonDialog(BuildContext context) {
    final orderController = TextEditingController();
    final firstCardTitleController = TextEditingController();
    final firstCardBodyController = TextEditingController();
    final firstCardIconController = TextEditingController();
    final teacherBloc = context.read<TeacherBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة درس جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: orderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'ترتيب الدرس (مثال: 1)'),
                ),
                const Divider(height: 32),
                const Text('البطاقة الأولى', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: firstCardTitleController,
                  decoration: const InputDecoration(labelText: 'عنوان البطاقة'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: firstCardBodyController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'محتوى البطاقة'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: firstCardIconController,
                  decoration: const InputDecoration(labelText: 'الرمز (إيموجي، مثال: 📖)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final card = LessonCard(
                  title: firstCardTitleController.text.trim(),
                  body: firstCardBodyController.text.trim(),
                  icon: firstCardIconController.text.trim().isEmpty 
                      ? '📖' 
                      : firstCardIconController.text.trim(),
                );
                
                final lesson = LessonModel(
                  id: '',
                  levelId: widget.levelId,
                  order: int.tryParse(orderController.text.trim()) ?? 0,
                  cards: [card],
                  createdAt: DateTime.now(),
                );
                
                teacherBloc.add(AddLesson(widget.categoryId, lesson));
                Navigator.pop(dialogContext);
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _showEditLessonDialog(BuildContext context, LessonModel lesson) {
    final orderController = TextEditingController(text: lesson.order.toString());
    final firstCard = lesson.cards.isNotEmpty ? lesson.cards.first : const LessonCard(title: '', body: '', icon: '📖');
    final firstCardTitleController = TextEditingController(text: firstCard.title);
    final firstCardBodyController = TextEditingController(text: firstCard.body);
    final firstCardIconController = TextEditingController(text: firstCard.icon);
    final teacherBloc = context.read<TeacherBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تعديل الدرس'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: orderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'ترتيب الدرس (مثال: 1)'),
                ),
                const Divider(height: 32),
                const Text('البطاقة الأولى', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: firstCardTitleController,
                  decoration: const InputDecoration(labelText: 'عنوان البطاقة'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: firstCardBodyController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'محتوى البطاقة'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: firstCardIconController,
                  decoration: const InputDecoration(labelText: 'الرمز (إيموجي، مثال: 📖)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final card = LessonCard(
                  title: firstCardTitleController.text.trim(),
                  body: firstCardBodyController.text.trim(),
                  icon: firstCardIconController.text.trim().isEmpty 
                      ? '📖' 
                      : firstCardIconController.text.trim(),
                );
                
                final updatedLesson = lesson.copyWith(
                  order: int.tryParse(orderController.text.trim()) ?? 0,
                  cards: [card],
                );
                
                teacherBloc.add(UpdateLesson(widget.categoryId, updatedLesson));
                Navigator.pop(dialogContext);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteLessonDialog(BuildContext context, LessonModel lesson) {
    final teacherBloc = context.read<TeacherBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف الدرس'),
          content: const Text('هل أنت متأكد من حذف هذا الدرس؟ لا يمكن التراجع عن هذا الإجراء.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                teacherBloc.add(DeleteLesson(widget.categoryId, lesson.levelId, lesson.id));
                Navigator.pop(dialogContext);
              },
              child: const Text('حذف', style: TextStyle(color: AppColors.error)),
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
            Text('بطاقات الدرس للمستوى: ${widget.levelName}', style: AppTextStyles.heading3),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _showAddLessonDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة درس جديد'),
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
                return Center(child: Text(state.message));
              }

              if (state is TeacherLessonsLoaded) {
                if (state.lessons.isEmpty) {
                  return const Center(child: Text('لا توجد بطاقات حالياً'));
                }

                return ListView.builder(
                  itemCount: state.lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = state.lessons[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.beige,
                          child: Text(lesson.cards.isNotEmpty ? lesson.cards.first.icon : '📚', style: const TextStyle(fontSize: 20)),
                        ),
                        title: Text(lesson.cards.isNotEmpty ? lesson.cards.first.title : 'الدرس ${lesson.order}'),
                        subtitle: Text(
                          lesson.cards.isNotEmpty ? lesson.cards.first.body : 'يحتوي على ${lesson.cards.length} بطاقات',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.primaryBrownLight), 
                                onPressed: () => _showEditLessonDialog(context, lesson)
                            ),
                            IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.error), 
                                onPressed: () => _showDeleteLessonDialog(context, lesson)
                            ),
                            const Icon(Icons.drag_handle, color: AppColors.beigeDark),
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
