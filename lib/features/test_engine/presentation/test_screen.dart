import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/arabic_helpers.dart';
import '../data/test_repository.dart';
import 'bloc/test_bloc.dart';
import 'bloc/test_event.dart';
import 'bloc/test_state.dart';
import 'widgets/qcm_question_widget.dart';
import 'widgets/fill_blank_question_widget.dart';
import '../domain/question_model.dart';

class TestScreen extends StatelessWidget {
  final String categoryId;
  final String levelId;

  const TestScreen({super.key, required this.categoryId, required this.levelId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TestBloc(
        testRepository: TestRepository(),
      )..add(LoadTest(categoryId: categoryId, levelId: levelId)),
      child: BlocConsumer<TestBloc, TestState>(
        listener: (context, state) {
          if (state is TestCompleted) {
            context.go('/result/${state.categoryId}/${state.levelId}', extra: {
              'score': state.score,
              'correctAnswers': state.correctAnswers,
              'totalQuestions': state.totalQuestions,
              'timeSeconds': state.timeSeconds,
              'stars': _calculateStars(state.score),
            });
          }
        },
        builder: (context, state) {
          if (state is TestLoading || state is TestInitial) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (state is TestEmpty) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('لا توجد أسئلة في هذا الاختبار')),
            );
          } else if (state is TestError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text(state.message)),
            );
          }
          
          bool hasRevealed = state is TestAnswerRevealed;
          TestInProgress? inProgressState;
          if (hasRevealed) {
            inProgressState = (state as TestAnswerRevealed).currentState;
          } else if (state is TestInProgress) {
            inProgressState = state;
          }

          if (inProgressState == null) return const SizedBox();

          return Scaffold(
            appBar: _buildAppBar(context, inProgressState),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildQuestion(context, inProgressState.currentQuestion, state),
                  ),
                ),
                _buildBottomBar(context, state, inProgressState),
              ],
            ),
          );
        },
      ),
    );
  }

  int _calculateStars(int scorePercent) {
    if (scorePercent >= 95) return 3;
    if (scorePercent >= 75) return 2;
    if (scorePercent >= 70) return 1;
    return 0;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, TestInProgress state) {
    final progress = (state.currentIndex) / state.questions.length;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('إنهاء الاختبار؟'),
              content: const Text('هل أنت متأكد من الخروج؟ سيتم فقدان تقدمك في هذا الاختبار.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('متابعة الاختبار'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.go('/level-map/${categoryId}');
                  },
                  child: const Text('خروج', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
        },
      ),
      title: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primaryBrownDark,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: List.generate(3, (index) {
              return Icon(
                index < state.hearts ? Icons.favorite : Icons.favorite_border,
                color: AppColors.error,
                size: 20,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, QuestionModel question, TestState state) {
    if (question.type == QuestionType.qcm) {
      return QcmQuestionWidget(
        question: question,
        state: state,
        onSelect: (val) => context.read<TestBloc>().add(AnswerSelected(val)),
      );
    } else {
      return FillBlankQuestionWidget(
        question: question,
        state: state,
        onSelect: (val) => context.read<TestBloc>().add(AnswerSelected(val)),
      );
    }
  }

  Widget _buildBottomBar(BuildContext context, TestState state, TestInProgress inProgressState) {
    final hasRevealed = state is TestAnswerRevealed;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: hasRevealed 
            ? (state.isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE))
            : AppColors.white,
        border: Border(
          top: BorderSide(
            color: hasRevealed 
              ? (state.isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFEF5350))
              : AppColors.beigeDark
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasRevealed) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: state.isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    state.isCorrect ? Icons.check : Icons.close,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.isCorrect ? 'إجابة صحيحة! 🎉' : 'إجابة خاطئة',
                        style: TextStyle(
                          color: state.isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (!state.isCorrect)
                        Text(
                          'الإجابة الصحيحة: ${state.correctAnswerText}',
                          style: const TextStyle(
                            color: Color(0xFFEF5350),
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: hasRevealed 
                  ? ElevatedButton.styleFrom(
                      backgroundColor: state.isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                    )
                  : (inProgressState.hasSelection 
                      ? null 
                      : ElevatedButton.styleFrom(
                          backgroundColor: AppColors.beigeDark,
                          foregroundColor: AppColors.textLight,
                        )),
              onPressed: inProgressState.hasSelection
                  ? () {
                      if (hasRevealed) {
                        context.read<TestBloc>().add(NextQuestion());
                      } else {
                        context.read<TestBloc>().add(AnswerConfirmed());
                      }
                    }
                  : null,
              child: Text(hasRevealed ? 'استمرار' : 'تأكيد'),
            ),
          ),
        ],
      ),
    );
  }
}
