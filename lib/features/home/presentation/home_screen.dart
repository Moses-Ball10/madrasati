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
import '../../auth/presentation/bloc/auth_event.dart';
import '../../categories/domain/category_model.dart';
import '../data/home_repository.dart';
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    
    return BlocProvider(
      create: (context) => HomeBloc(
        homeRepository: HomeRepository(),
      )..add(LoadHomeData(user.uid)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppConstants.appName),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(LoadHomeData(user.uid));
            context.read<AuthBloc>().add(const CheckAuthStatus());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(context, user),
                const SizedBox(height: 24),
                _buildCategoriesSection(context),
                const SizedBox(height: 24),
                _buildContinueSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, user) {
    final currentLevel = AppConstants.userLevel(user.xp);
    final xpProgress = AppConstants.xpProgress(user.xp);
    final currentLevelXp = AppConstants.xpInCurrentLevel(user.xp);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primaryBrown,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.beigeLight,
                child: Text(
                  user.initials,
                  style: AppTextStyles.heading2.copyWith(color: AppColors.primaryBrown),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً، ${user.name}',
                      style: AppTextStyles.heading3.copyWith(color: AppColors.beigeLight),
                    ),
                    Text(
                      'المستوى ${ArabicHelpers.toArabicNumber(currentLevel)}',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.beigeDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ArabicHelpers.toArabicNumber(currentLevelXp)} / ${ArabicHelpers.toArabicNumber(AppConstants.xpPerLevel)} XP',
                style: AppTextStyles.caption.copyWith(color: AppColors.beigeLight),
              ),
              const Icon(Icons.star_rounded, color: AppColors.xpGold, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: xpProgress,
            backgroundColor: AppColors.primaryBrownDark,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.xpGold),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('🔥', '${ArabicHelpers.toArabicNumber(user.streak)} يوم', 'الاستمرارية'),
              _buildStatItem('🏆', ArabicHelpers.toArabicNumber(user.badges.length), 'الشارات'),
              _buildStatItem('✨', ArabicHelpers.toArabicNumber(user.xp), 'مجموع النقاط'),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.labelMedium.copyWith(color: AppColors.beigeLight)),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.beigeDark)),
      ],
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الفئات', style: AppTextStyles.heading3),
              TextButton(
                onPressed: () => context.go('/categories'),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading || state is HomeInitial) {
                return _buildCategoriesShimmer();
              } else if (state is HomeLoaded) {
                if (state.categories.isEmpty) {
                  return const Center(child: Text('لا توجد فئات بعد'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return _buildCategoryChip(context, category, index);
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

  Widget _buildCategoriesShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Shimmer.fromColors(
          baseColor: AppColors.beige,
          highlightColor: AppColors.beigeLight,
          child: Container(
            width: 90,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, CategoryModel category, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => context.go('/level-map/${category.id}'),
        child: Container(
          width: 90,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(category.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDark),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ).animate().fadeIn(delay: (100 * index).ms).scale(),
      ),
    );
  }

  Widget _buildContinueSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('واصل من حيث توقفت', style: AppTextStyles.heading3),
        ),
        const SizedBox(height: 16),
        BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
               return const Center(child: CircularProgressIndicator());
            } else if (state is HomeLoaded) {
              if (state.recentLevels.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.beigeDark),
                    ),
                    child: Column(
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 16),
                        Text(
                          'ابدأ رحلة التعلم الآن!',
                          style: AppTextStyles.labelMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: state.recentLevels.length,
                itemBuilder: (context, index) {
                  final data = state.recentLevels[index];
                  return _buildRecentLevelCard(context, data, index);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildRecentLevelCard(BuildContext context, Map<String, dynamic> data, int index) {
    final level = data['level'];
    final category = data['category'];
    final progress = data['progress'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/lesson/${category.id}/${level.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(category.icon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: AppTextStyles.caption.copyWith(color: AppColors.primaryBrownLight),
                    ),
                    Text(
                      level.title,
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.bestScore / 100,
                      backgroundColor: AppColors.beigeDark,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryBrownLight),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (200 + (index * 100)).ms).slideX(begin: 0.1, end: 0);
  }
}
