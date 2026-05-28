import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'bloc/teacher_bloc.dart';
import 'bloc/teacher_event.dart';
import 'bloc/teacher_state.dart';
import '../../categories/domain/category_model.dart';

class CategoryManagerScreen extends StatefulWidget {
  const CategoryManagerScreen({super.key});

  @override
  State<CategoryManagerScreen> createState() => _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends State<CategoryManagerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadCategories());
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final iconController = TextEditingController();
    final orderController = TextEditingController();
    final teacherBloc = context.read<TeacherBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة فئة جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الفئة (مثال: العقيدة)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(labelText: 'الرمز (إيموجي، مثال: 📖)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: orderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الترتيب (مثال: 1)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final category = CategoryModel(
                  id: '',
                  name: nameController.text.trim(),
                  icon: iconController.text.trim(),
                  order: int.tryParse(orderController.text.trim()) ?? 0,
                  createdBy: 'teacher', // Using placeholder for now
                  createdAt: DateTime.now(),
                  isActive: true,
                );
                teacherBloc.add(AddCategory(category));
                Navigator.pop(dialogContext);
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context, CategoryModel category) {
    final nameController = TextEditingController(text: category.name);
    final iconController = TextEditingController(text: category.icon);
    final orderController = TextEditingController(text: category.order.toString());
    final teacherBloc = context.read<TeacherBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تعديل الفئة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الفئة (مثال: العقيدة)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(labelText: 'الرمز (إيموجي، مثال: 📖)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: orderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الترتيب (مثال: 1)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedCategory = category.copyWith(
                  name: nameController.text.trim(),
                  icon: iconController.text.trim(),
                  order: int.tryParse(orderController.text.trim()) ?? category.order,
                );
                teacherBloc.add(UpdateCategory(updatedCategory));
                Navigator.pop(dialogContext);
              },
              child: const Text('تحديث'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, CategoryModel category) {
    final teacherBloc = context.read<TeacherBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف الفئة'),
          content: Text('هل أنت متأكد من رغبتك في حذف الفئة "${category.name}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                teacherBloc.add(DeleteCategory(category.id));
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('جميع الفئات', style: AppTextStyles.heading3),
            ElevatedButton.icon(
              onPressed: () => _showAddCategoryDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة فئة جديدة'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Card(
            child: BlocBuilder<TeacherBloc, TeacherState>(
              builder: (context, state) {
                if (state is TeacherLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TeacherError) {
                  return Center(child: Text(state.message));
                }

                if (state is TeacherCategoriesLoaded) {
                  if (state.categories.isEmpty) {
                    return const Center(child: Text('لا توجد فئات حالياً'));
                  }

                  return SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppColors.beige),
                        columns: const [
                          DataColumn(label: Text('الرمز')),
                          DataColumn(label: Text('اسم الفئة')),
                          DataColumn(label: Text('الترتيب')),
                          DataColumn(label: Text('الحالة')),
                          DataColumn(label: Text('الإجراءات')),
                        ],
                        rows: state.categories.map((category) {
                          return DataRow(cells: [
                            DataCell(Text(category.icon, style: const TextStyle(fontSize: 24))),
                            DataCell(Text(category.name)),
                            DataCell(Text(category.order.toString())),
                            DataCell(
                              Chip(
                                label: Text(
                                  category.isActive ? 'نشط' : 'معطل',
                                  style: TextStyle(color: category.isActive ? AppColors.success : AppColors.error),
                                ),
                                backgroundColor: (category.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: AppColors.primaryBrownLight),
                                    onPressed: () => _showEditCategoryDialog(context, category),
                                    tooltip: 'تعديل الفئة',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: AppColors.error),
                                    onPressed: () => _showDeleteCategoryDialog(context, category),
                                    tooltip: 'حذف الفئة',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.list, color: AppColors.primaryBrown),
                                    onPressed: () {
                                      context.go('/teacher/categories/${category.id}/levels', extra: category.name);
                                    },
                                    tooltip: 'المستويات',
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
