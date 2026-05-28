import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/arabic_helpers.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../domain/progress_model.dart';
import '../data/level_repository.dart';
import 'bloc/level_map_bloc.dart';
import 'bloc/level_map_event.dart';
import 'bloc/level_map_state.dart';
import 'widgets/level_bubble_widget.dart';
import 'widgets/winding_path_painter.dart';

class LevelMapScreen extends StatelessWidget {
  final String categoryId;

  const LevelMapScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return BlocProvider(
      create: (context) => LevelMapBloc(
        levelRepository: LevelRepository(),
      )..add(LoadLevelMap(categoryId: categoryId, userId: user.uid)),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          title: BlocBuilder<LevelMapBloc, LevelMapState>(
            builder: (context, state) {
              if (state is LevelMapLoaded) {
                return Text(state.category.name);
              }
              return const Text('المستويات');
            },
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/categories'), // or context.pop() depending on flow
          ),
        ),
        body: Stack(
          children: [
            // Islamic floating decorations background
            _buildDecorationsBackground(context),
            
            // Main content
            BlocBuilder<LevelMapBloc, LevelMapState>(
              builder: (context, state) {
                if (state is LevelMapLoading || state is LevelMapInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is LevelMapError) {
                  return Center(child: Text(state.message));
                } else if (state is LevelMapLoaded) {
                  if (state.levelsData.isEmpty) {
                    return const Center(child: Text('لا توجد مستويات في هذه الفئة بعد'));
                  }
                  return _buildLevelPath(context, state.levelsData);
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorationsBackground(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final random = Random(42); // Fixed seed for consistent layout

    return IgnorePointer(
      child: Stack(
        children: List.generate(15, (index) {
          final decoration = AppConstants.islamicDecorations[
              random.nextInt(AppConstants.islamicDecorations.length)];
          return Positioned(
            left: random.nextDouble() * size.width,
            top: random.nextDouble() * size.height,
            child: Opacity(
              opacity: 0.12,
              child: Text(
                decoration,
                style: const TextStyle(fontSize: 32, color: AppColors.primaryBrownDark),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLevelPath(BuildContext context, List<Map<String, dynamic>> levelsData) {
    final positions = [
      Alignment.centerRight,
      Alignment.center,
      Alignment.centerLeft,
      Alignment.center,
    ];
    
    // We want the most recent/locked levels at the top visually?
    // Duolingo usually has start at bottom, current at top.
    // Since we are using a ListView, let's just make it normal (start at top) or reversed.
    // Let's do normal (order 1 at top) for simplicity in scrolling.
    
    const double itemHeight = 140.0; // Fixed height per item for the painter to work reliably

    return CustomPaint(
      painter: WindingPathPainter(
        levelCount: levelsData.length,
        alignments: positions,
        itemHeight: itemHeight,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 40),
        itemCount: levelsData.length,
        itemBuilder: (context, index) {
          final data = levelsData[index];
          final level = data['level'];
          final ProgressModel progress = data['progress'];
          final align = positions[index % positions.length];

          return SizedBox(
            height: itemHeight,
            child: Align(
              alignment: align,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LevelBubbleWidget(
                  status: progress.status,
                  stars: progress.stars,
                  xpReward: level.xpReward,
                  title: level.title,
                  onTap: () => _handleLevelTap(context, categoryId, level.id, progress),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleLevelTap(BuildContext context, String catId, String levId, ProgressModel progress) {
    if (progress.status == LevelStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عليك إكمال المستويات السابقة أولاً')),
      );
      return;
    }
    
    if (progress.status == LevelStatus.completed) {
      // Show bottom sheet to redo
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => _buildCompletedBottomSheet(context, catId, levId, progress),
      );
      return;
    }

    // Unlocked but not completed -> Go to lesson
    context.go('/lesson/$catId/$levId');
  }

  Widget _buildCompletedBottomSheet(BuildContext context, String catId, String levId, ProgressModel progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('المستوى مكتمل', style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  index < progress.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: index < progress.stars ? AppColors.xpGold : AppColors.beigeDark,
                  size: 40,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            'أفضل نتيجة: ${ArabicHelpers.toArabicPercentage(progress.bestScore)}',
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/lesson/$catId/$levId');
            },
            child: const Text('إعادة المحاولة (+١٠ نقاط)'),
          ),
        ],
      ),
    );
  }
}
