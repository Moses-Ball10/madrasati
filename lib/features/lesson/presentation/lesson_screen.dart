import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/arabic_helpers.dart';
import '../data/lesson_repository.dart';
import 'bloc/lesson_bloc.dart';
import 'bloc/lesson_event.dart';
import 'bloc/lesson_state.dart';
import 'widgets/lesson_card_widget.dart';

class LessonScreen extends StatefulWidget {
  final String categoryId;
  final String levelId;

  const LessonScreen({
    super.key,
    required this.categoryId,
    required this.levelId,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext(BuildContext context, LessonLoaded state) {
    if (state.isLastCard) {
      context.go('/test/${widget.categoryId}/${widget.levelId}');
    } else {
      context.read<LessonBloc>().add(NextCard());
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPrevious(BuildContext context, LessonLoaded state) {
    if (state.currentIndex > 0) {
      context.read<LessonBloc>().add(PreviousCard());
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LessonBloc(
        lessonRepository: LessonRepository(),
      )..add(LoadLesson(categoryId: widget.categoryId, levelId: widget.levelId)),
      child: BlocConsumer<LessonBloc, LessonState>(
        listener: (context, state) {
          if (state is LessonEmpty) {
            // Skip directly to test if no lesson cards
            context.go('/test/${widget.categoryId}/${widget.levelId}');
          }
        },
        builder: (context, state) {
          if (state is LessonLoading || state is LessonInitial) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (state is LessonError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text(state.message)),
            );
          } else if (state is LessonLoaded) {
            return Scaffold(
              backgroundColor: AppColors.scaffoldBg,
              appBar: _buildAppBar(context, state),
              body: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(), // Managed by buttons
                      itemCount: state.lesson.cards.length,
                      itemBuilder: (context, index) {
                        final card = state.lesson.cards[index];
                        return LessonCardWidget(
                          icon: card.icon,
                          categoryName: '', // Could pass if available
                          title: card.title,
                          body: card.body,
                        ).animate().fadeIn().slideX(begin: 0.1, end: 0);
                      },
                    ),
                  ),
                  _buildBottomControls(context, state),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, LessonLoaded state) {
    final progress = (state.currentIndex + 1) / state.lesson.cards.length;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('الخروج من الدرس؟'),
              content: const Text('هل أنت متأكد من الخروج قبل إنهاء الدرس؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('متابعة الدرس'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.go('/level-map/${widget.categoryId}');
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
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            ArabicHelpers.formatOfTotal(state.currentIndex + 1, state.lesson.cards.length),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, LessonLoaded state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.beigeDark)),
      ),
      child: Column(
        children: [
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(state.lesson.cards.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == state.currentIndex
                      ? AppColors.primaryBrown
                      : AppColors.beigeDark,
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (state.currentIndex > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _onPrevious(context, state),
                    child: const Text('السابق'),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _onNext(context, state),
                  child: Text(state.isLastCard ? 'ابدأ الاختبار' : 'التالي →'),
                ),
              ),
            ],
          ),
          if (!state.isLastCard) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/test/${widget.categoryId}/${widget.levelId}'),
              child: const Text('تخطي للاختبار'),
            ),
          ] else
            const SizedBox(height: 48), // Match spacing
        ],
      ),
    );
  }
}
