import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/arabic_helpers.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../../auth/presentation/bloc/auth_event.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          return Scaffold(
            appBar: AppBar(
              title: const Text('حسابي'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    // Settings not fully specified, simple placeholder
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  _buildHeader(user),
                  const SizedBox(height: 32),
                  _buildStatsGrid(user),
                  const SizedBox(height: 32),
                  _buildBadgesSection(user),
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextButton.icon(
                      onPressed: () => context.read<AuthBloc>().add(const LogoutRequested()),
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      label: Text(
                        'تسجيل الخروج',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildHeader(user) {
    final currentLevel = AppConstants.userLevel(user.xp);
    final xpProgress = AppConstants.xpProgress(user.xp);
    
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primaryBrownLight.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryBrown, width: 2),
          ),
          child: Center(
            child: Text(
              user.initials,
              style: AppTextStyles.heading1.copyWith(color: AppColors.primaryBrown),
            ),
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        
        const SizedBox(height: 16),
        
        Text(
          user.name,
          style: AppTextStyles.heading2,
        ).animate().fadeIn(delay: 200.ms),
        
        const SizedBox(height: 4),
        
        Text(
          'تاريخ الانضمام: ${ArabicHelpers.formatDateArabic(user.createdAt)}',
          style: AppTextStyles.caption,
        ).animate().fadeIn(delay: 300.ms),
        
        const SizedBox(height: 24),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('المستوى ${ArabicHelpers.toArabicNumber(currentLevel)}', style: AppTextStyles.labelMedium),
                  Text('المستوى ${ArabicHelpers.toArabicNumber(currentLevel + 1)}', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textLight)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: xpProgress,
                backgroundColor: AppColors.beigeDark,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.xpGold),
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 8),
              Text(
                '${ArabicHelpers.toArabicNumber(AppConstants.xpInCurrentLevel(user.xp))} / ${ArabicHelpers.toArabicNumber(AppConstants.xpPerLevel)} XP',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildStatsGrid(user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatBox('🔥', '${ArabicHelpers.toArabicNumber(user.streak)}', 'أيام متتالية'),
          _buildStatBox('✨', '${ArabicHelpers.toArabicNumber(user.xp)}', 'نقطة XP'),
          _buildStatBox('🏆', '${ArabicHelpers.toArabicNumber(user.badges.length)}', 'شارات'),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatBox(String icon, String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.beigeDark),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الإنجازات', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          if (user.badges.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.beige,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'أكمل الدروس للحصول على شارات',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                textAlign: TextAlign.center,
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: user.badges.length,
              itemBuilder: (context, index) {
                final badgeId = user.badges[index];
                return _buildBadge(badgeId, index);
              },
            ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildBadge(String badgeId, int index) {
    final name = AppConstants.badgeLabels[badgeId] ?? badgeId;
    final icon = AppConstants.badgeIcons[badgeId] ?? '🏅';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.xpGold.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.xpGold.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              name,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBrownDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (700 + (index * 100)).ms).scale();
  }
}
