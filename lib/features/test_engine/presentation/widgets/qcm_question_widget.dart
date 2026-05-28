import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/question_model.dart';
import '../bloc/test_state.dart';

class QcmQuestionWidget extends StatelessWidget {
  final QuestionModel question;
  final TestState state;
  final ValueChanged<int> onSelect;

  const QcmQuestionWidget({
    super.key,
    required this.question,
    required this.state,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    bool hasRevealed = state is TestAnswerRevealed;
    TestInProgress? inProgressState;
    TestAnswerRevealed? revealedState;

    if (hasRevealed) {
      revealedState = state as TestAnswerRevealed;
      inProgressState = revealedState.currentState;
    } else if (state is TestInProgress) {
      inProgressState = state as TestInProgress;
    }

    int? selectedIndex = inProgressState?.selectedAnswer as int?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.beige,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'اختيار من متعدد',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBrown),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          question.question,
          style: AppTextStyles.heading2,
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 32),
        ...List.generate(question.options.length, (index) {
          final option = question.options[index];
          final isSelected = selectedIndex == index;
          
          Color borderColor = AppColors.beigeDark;
          Color bgColor = AppColors.white;
          Color textColor = AppColors.textDark;

          if (hasRevealed) {
            if (index == question.correctIndex) {
              borderColor = AppColors.success;
              bgColor = AppColors.success.withValues(alpha: 0.1);
              textColor = AppColors.success;
            } else if (isSelected && index != question.correctIndex) {
              borderColor = AppColors.error;
              bgColor = AppColors.error.withValues(alpha: 0.1);
              textColor = AppColors.error;
            }
          } else if (isSelected) {
            borderColor = AppColors.primaryBrown;
            bgColor = AppColors.beigeLight;
            textColor = AppColors.primaryBrown;
          }

          Widget card = GestureDetector(
            onTap: hasRevealed ? null : () => onSelect(index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: borderColor, width: isSelected || hasRevealed ? 2 : 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected && !hasRevealed ? AppColors.primaryBrown : AppColors.beige,
                      border: Border.all(
                        color: hasRevealed && index == question.correctIndex
                            ? AppColors.success
                            : (isSelected && !hasRevealed ? AppColors.primaryBrown : AppColors.beigeDark),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        AppConstants.optionLabels[index],
                        style: TextStyle(
                          color: isSelected && !hasRevealed ? AppColors.white : AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: AppTextStyles.bodyLarge.copyWith(color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          );

          // Reveal animations
          if (hasRevealed) {
            if (index == question.correctIndex) {
              card = card.animate().scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.05, 1.05),
                    duration: 300.ms,
                  ).then().scale(
                    begin: const Offset(1.05, 1.05),
                    end: const Offset(1, 1),
                  ).tint(color: AppColors.success, duration: 300.ms);
            } else if (isSelected && index != question.correctIndex) {
              card = card.animate().shakeX(duration: 400.ms).tint(color: AppColors.error, duration: 400.ms);
            }
          } else {
             // Initial entry animation
             card = card.animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.2, end: 0);
          }

          return card;
        }),
      ],
    );
  }
}
