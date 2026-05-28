import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/arabic_helpers.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../data/result_repository.dart';
import 'bloc/result_bloc.dart';
import 'bloc/result_event.dart';
import 'bloc/result_state.dart';

class ResultScreen extends StatelessWidget {
  final String categoryId;
  final String levelId;
  final int score;
  final int stars;
  final int correctAnswers;
  final int totalQuestions;
  final int timeSeconds;

  const ResultScreen({
    super.key,
    required this.categoryId,
    required this.levelId,
    required this.score,
    required this.stars,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    final passed = stars >= 1;

    return BlocProvider(
      create: (context) => ResultBloc(
        resultRepository: ResultRepository(),
      )..add(SaveResult(
          userId: user.uid,
          categoryId: categoryId,
          levelId: levelId,
          score: score,
          stars: stars,
        )),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: SafeArea(
          child: Stack(
            children: [
              if (passed) _buildConfettiBackground(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      passed ? 'أحسنت يا بطل!' : 'حاول مرة أخرى',
                      style: AppTextStyles.heading1,
                      textAlign: TextAlign.center,
                    ).animate().fadeIn().scale(),
                    
                    const SizedBox(height: 32),
                    
                    if (passed)
                      _buildStarsRow()
                    else
                      Text('😔', style: const TextStyle(fontSize: 80)).animate().shakeX(),
                    
                    const SizedBox(height: 48),
                    
                    _buildStatsGrid(),
                    
                    if (passed) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.xpGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          ArabicHelpers.formatXp(AppConstants.xpForStars(stars)),
                          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryBrownDark),
                        ),
                      ).animate().fadeIn(delay: 600.ms).scale(),
                    ],
                    
                    const Spacer(),
                    
                    BlocBuilder<ResultBloc, ResultState>(
                      builder: (context, state) {
                        final isSaving = state is ResultSaving;
                        
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isSaving ? null : () {
                                  if (passed) {
                                    context.go('/level-map/$categoryId'); // Return to map
                                  } else {
                                    context.go('/test/$categoryId/$levelId'); // Retry
                                  }
                                },
                                child: isSaving 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.white))
                                  : Text(passed ? 'المستوى التالي →' : 'إعادة الاختبار'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: isSaving ? null : () {
                                if (passed) {
                                  context.go('/test/$categoryId/$levelId'); // Retry to improve
                                } else {
                                  context.go('/lesson/$categoryId/$levelId'); // Review lesson
                                }
                              },
                              child: Text(passed ? 'إعادة المحاولة' : 'مراجعة الدرس'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool earned = index < stars;
        return Padding(
          padding: EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            bottom: index == 1 ? 24.0 : 0.0, // Middle star slightly higher
          ),
          child: Icon(
            earned ? Icons.star_rounded : Icons.star_outline_rounded,
            color: earned ? AppColors.xpGold : AppColors.beigeDark,
            size: index == 1 ? 80 : 64,
          ).animate(
            delay: (200 + (index * 200)).ms,
          ).scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            curve: Curves.elasticOut,
            duration: 800.ms,
          ),
        );
      }),
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.beigeDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('النتيجة', ArabicHelpers.toArabicPercentage(score), AppColors.success),
          _buildStatItem('الصحيح', ArabicHelpers.formatOfTotal(correctAnswers, totalQuestions), AppColors.primaryBrown),
          _buildStatItem('الوقت', ArabicHelpers.formatTimeArabic(timeSeconds), AppColors.xpGold),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.heading3.copyWith(color: color)),
      ],
    );
  }

  Widget _buildConfettiBackground(BuildContext context) {
    // Simple colored circles expanding to simulate confetti since we don't have Lottie files
    return Stack(
      children: List.generate(20, (index) {
        return Positioned(
          left: MediaQuery.of(context).size.width / 2,
          top: MediaQuery.of(context).size.height / 3,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: [AppColors.success, AppColors.xpGold, AppColors.primaryBrownLight][index % 3],
              shape: BoxShape.circle,
            ),
          )
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .custom(
            duration: 2000.ms,
            builder: (context, value, child) {
              final val = value as double;
              final dx = (index % 5 - 2) * 80 * val;
              final dy = (index ~/ 5 - 2) * 80 * val + (val * val * 200); // Gravity effect
              return Transform.translate(
                offset: Offset(dx, dy),
                child: Opacity(
                  opacity: 1 - val,
                  child: child,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
