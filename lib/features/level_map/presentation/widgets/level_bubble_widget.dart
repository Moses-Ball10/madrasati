import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/progress_model.dart';
import '../../../../core/utils/arabic_helpers.dart';

class LevelBubbleWidget extends StatelessWidget {
  final LevelStatus status;
  final int stars;
  final int xpReward;
  final String title;
  final VoidCallback onTap;

  const LevelBubbleWidget({
    super.key,
    required this.status,
    required this.stars,
    required this.xpReward,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBubble(),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: status == LevelStatus.locked ? AppColors.textLight : AppColors.textDark,
              fontWeight: status == LevelStatus.locked ? FontWeight.w400 : FontWeight.bold,
            ),
          ),
          if (status == LevelStatus.completed)
            _buildStars()
          else if (status == LevelStatus.unlocked)
            _buildXpBadge(),
        ],
      ),
    ).animate().scale(
      duration: 200.ms, 
      begin: const Offset(0.9, 0.9), 
      end: const Offset(1, 1),
    );
  }

  Widget _buildBubble() {
    Color bgColor;
    IconData icon;
    Color iconColor = AppColors.white;

    switch (status) {
      case LevelStatus.completed:
        bgColor = AppColors.primaryBrown;
        icon = Icons.check_rounded;
        break;
      case LevelStatus.unlocked:
        bgColor = AppColors.primaryBrownLight;
        icon = Icons.play_arrow_rounded;
        break;
      case LevelStatus.locked:
      default:
        bgColor = AppColors.beigeDark;
        icon = Icons.lock_outline_rounded;
        iconColor = AppColors.textLight;
        break;
    }

    Widget bubble = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: status != LevelStatus.locked
            ? [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(icon, color: iconColor, size: 32),
      ),
    );

    if (status == LevelStatus.unlocked) {
      // Add glowing ring for current level
      bubble = Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryBrownLight, width: 2),
        ),
        child: bubble,
      ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
        begin: const Offset(1, 1),
        end: const Offset(1.05, 1.05),
        duration: 1.seconds,
      );
    }

    return bubble;
  }

  Widget _buildStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Icon(
          index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
          color: index < stars ? AppColors.xpGold : AppColors.beigeDark,
          size: 16,
        );
      }),
    );
  }

  Widget _buildXpBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.xpGold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        ArabicHelpers.formatXp(xpReward),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primaryBrownDark,
          fontWeight: FontWeight.bold,
          fontSize: 8,
        ),
      ),
    );
  }
}
