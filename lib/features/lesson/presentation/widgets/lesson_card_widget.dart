import 'package:flutter/material.dart';
import '../../domain/lesson_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class LessonCardWidget extends StatelessWidget {
  final String icon;
  final String categoryName;
  final String title;
  final String body;

  const LessonCardWidget({
    super.key,
    required this.icon,
    required this.categoryName, // Optional: if we want to display the category badge
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.beigeDark),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            if (categoryName.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  categoryName,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryBrownLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              body,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primaryBrownLight,
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
