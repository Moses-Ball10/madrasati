import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/arabic_helpers.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../data/categories_repository.dart';
import 'bloc/categories_bloc.dart';
import 'bloc/categories_event.dart';
import 'bloc/categories_state.dart';
import '../domain/category_model.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return BlocProvider(
      create: (context) => CategoriesBloc(
        categoriesRepository: CategoriesRepository(),
      )..add(LoadCategories(user.uid)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الفئات'),
        ),
        body: BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesLoading || state is CategoriesInitial) {
              return _buildShimmerGrid();
            } else if (state is CategoriesError) {
              return Center(child: Text(state.message));
            } else if (state is CategoriesLoaded) {
              if (state.categoriesWithStats.isEmpty) {
                return const Center(child: Text('لا توجد فئات بعد'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<CategoriesBloc>().add(LoadCategories(user.uid));
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: state.categoriesWithStats.length,
                  itemBuilder: (context, index) {
                    final item = state.categoriesWithStats[index];
                    return _buildCategoryCard(context, item, index);
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.beige,
          highlightColor: AppColors.beigeLight,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> item, int index) {
    final CategoryModel category = item['category'];
    final int totalLevels = item['totalLevels'];
    final int completedLevels = item['completedLevels'];
    final double progress = totalLevels > 0 ? (completedLevels / totalLevels) : 0.0;
    
    return GestureDetector(
      onTap: () => context.go('/level-map/${category.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.beigeDark, width: 0.5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '${ArabicHelpers.toArabicNumber(totalLevels)} مستويات',
              style: AppTextStyles.caption.copyWith(color: AppColors.primaryBrownLight),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${ArabicHelpers.toArabicPercentage((progress * 100).toInt())}',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBrown),
                ),
                Text(
                  ArabicHelpers.formatOfTotal(completedLevels, totalLevels),
                  style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.beigeDark,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBrown),
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),
          ],
        ),
      ).animate().fadeIn(delay: (100 * index).ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}
