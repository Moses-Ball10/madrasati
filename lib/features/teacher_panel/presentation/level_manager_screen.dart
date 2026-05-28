import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'bloc/teacher_bloc.dart';
import 'bloc/teacher_event.dart';
import 'bloc/teacher_state.dart';

import '../../level_map/domain/level_model.dart';

class LevelManagerScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  
  const LevelManagerScreen({
    super.key, 
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<LevelManagerScreen> createState() => _LevelManagerScreenState();
}

class _LevelManagerScreenState extends State<LevelManagerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadLevels(widget.categoryId));
  }

  void _showAddLevelDialog(BuildContext context) {
    final titleController = TextEditingController();
    final orderController = TextEditingController();
    final xpController = TextEditingController();
    final passScoreController = TextEditingController();
    final teacherBloc = context.read<TeacherBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة مستوى جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'عنوان المستوى (مثال: المستوى الأول)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: orderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الترتيب (مثال: 1)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: xpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'نقاط الخبرة (XP)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passScoreController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'نسبة النجاح (مثال: 80)'),
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
                final level = LevelModel(
                  id: '',
                  categoryId: widget.categoryId,
                  title: titleController.text.trim(),
                  order: int.tryParse(orderController.text.trim()) ?? 0,
                  xpReward: int.tryParse(xpController.text.trim()) ?? 50,
                  passThreshold: int.tryParse(passScoreController.text.trim()) ?? 80,
                  isActive: true,
                  createdAt: DateTime.now(),
                );
                teacherBloc.add(AddLevel(level));
                Navigator.pop(dialogContext);
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _showEditLevelDialog(BuildContext context, LevelModel level) {
    final titleController = TextEditingController(text: level.title);
    final orderController = TextEditingController(text: level.order.toString());
    final xpController = TextEditingController(text: level.xpReward.toString());
    final passScoreController = TextEditingController(text: level.passThreshold.toString());
    final teacherBloc = context.read<TeacherBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تعديل المستوى'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'عنوان المستوى (مثال: المستوى الأول)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: orderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الترتيب (مثال: 1)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: xpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'نقاط الخبرة (XP)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passScoreController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'نسبة النجاح (مثال: 80)'),
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
                final updatedLevel = level.copyWith(
                  title: titleController.text.trim(),
                  order: int.tryParse(orderController.text.trim()) ?? level.order,
                  xpReward: int.tryParse(xpController.text.trim()) ?? level.xpReward,
                  passThreshold: int.tryParse(passScoreController.text.trim()) ?? level.passThreshold,
                );
                teacherBloc.add(UpdateLevel(updatedLevel));
                Navigator.pop(dialogContext);
              },
              child: const Text('تحديث'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteLevelDialog(BuildContext context, LevelModel level) {
    final teacherBloc = context.read<TeacherBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف المستوى'),
          content: Text('هل أنت متأكد من رغبتك في حذف المستوى "${level.title}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                teacherBloc.add(DeleteLevel(widget.categoryId, level.id));
                Navigator.pop(dialogContext);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndImportCSV() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final csvString = utf8.decode(bytes);
        if (mounted) {
           context.read<TeacherBloc>().add(ImportLessonsCSV(widget.categoryId, csvString));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في قراءة الملف: $e')));
      }
    }
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
              onPressed: () => context.go('/teacher/categories'),
            ),
            const SizedBox(width: 8),
            Text('المستويات للفئة: ${widget.categoryName}', style: AppTextStyles.heading3),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _pickAndImportCSV,
              icon: const Icon(Icons.upload_file),
              label: const Text('استيراد دروس (CSV)'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showAddLevelDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة مستوى جديد'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Card(
            child: BlocConsumer<TeacherBloc, TeacherState>(
              listener: (context, state) {
                if (state is TeacherImportSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم استيراد المستويات والدروس بنجاح!'), backgroundColor: AppColors.success),
                  );
                } else if (state is TeacherError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                  );
                }
              },
              buildWhen: (previous, current) {
                // Only rebuild table if it's a related state
                return current is TeacherLoading || current is TeacherLevelsLoaded || current is TeacherImporting || current is TeacherError;
              },
              builder: (context, state) {
                if (state is TeacherLoading || state is TeacherImporting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TeacherError) {
                  return Center(child: Text(state.message));
                }

                if (state is TeacherLevelsLoaded) {
                  if (state.levels.isEmpty) {
                    return const Center(child: Text('لا توجد مستويات حالياً'));
                  }

                  return SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppColors.beige),
                        columns: const [
                          DataColumn(label: Text('العنوان')),
                          DataColumn(label: Text('الترتيب')),
                          DataColumn(label: Text('نقاط XP')),
                          DataColumn(label: Text('نسبة النجاح')),
                          DataColumn(label: Text('الحالة')),
                          DataColumn(label: Text('الإجراءات')),
                        ],
                        rows: state.levels.map((level) {
                          return DataRow(cells: [
                            DataCell(Text(level.title)),
                            DataCell(Text(level.order.toString())),
                            DataCell(Text(level.xpReward.toString())),
                            DataCell(Text('${level.passThreshold}%')),
                            DataCell(
                              Chip(
                                label: Text(
                                  level.isActive ? 'نشط' : 'معطل',
                                  style: TextStyle(color: level.isActive ? AppColors.success : AppColors.error),
                                ),
                                backgroundColor: (level.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: AppColors.primaryBrownLight),
                                    onPressed: () => _showEditLevelDialog(context, level),
                                    tooltip: 'تعديل المستوى',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: AppColors.error),
                                    onPressed: () => _showDeleteLevelDialog(context, level),
                                    tooltip: 'حذف المستوى',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.menu_book, color: AppColors.primaryBrown),
                                    onPressed: () => context.go('/teacher/categories/${widget.categoryId}/levels/${level.id}/lesson', extra: level.title),
                                    tooltip: 'الدروس',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.question_answer, color: AppColors.xpGold),
                                    onPressed: () => context.go('/teacher/categories/${widget.categoryId}/levels/${level.id}/questions', extra: level.title),
                                    tooltip: 'الأسئلة',
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
