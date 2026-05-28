import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/arabic_helpers.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../data/leaderboard_repository.dart';
import 'bloc/leaderboard_bloc.dart';
import 'bloc/leaderboard_event.dart';
import 'bloc/leaderboard_state.dart';
import '../../auth/domain/user_model.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return BlocProvider(
      create: (context) => LeaderboardBloc(
        leaderboardRepository: LeaderboardRepository(),
      )..add(StartLeaderboardStream()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة المتصدرين'),
        ),
        body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
          builder: (context, state) {
            if (state is LeaderboardLoading || state is LeaderboardInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LeaderboardError) {
              return Center(child: Text(state.message));
            } else if (state is LeaderboardLoaded) {
              if (state.users.isEmpty) {
                return const Center(child: Text('لا يوجد متصدرين بعد'));
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  final isCurrentUser = user.uid == currentUser.uid;
                  return _buildLeaderboardRow(context, user, index + 1, isCurrentUser);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildLeaderboardRow(BuildContext context, UserModel user, int rank, bool isCurrentUser) {
    // Top 3 colors
    Color? rankColor;
    if (rank == 1) rankColor = const Color(0xFFFFD700); // Gold
    else if (rank == 2) rankColor = const Color(0xFFC0C0C0); // Silver
    else if (rank == 3) rankColor = const Color(0xFFCD7F32); // Bronze
    else rankColor = AppColors.beigeDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.primaryBrownLight.withValues(alpha: 0.1) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser ? AppColors.primaryBrown : AppColors.beigeDark,
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              alignment: Alignment.center,
              child: Text(
                ArabicHelpers.toArabicNumber(rank),
                style: AppTextStyles.heading3.copyWith(color: rank <= 3 ? rankColor : AppColors.textLight),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: rank <= 3 ? rankColor.withValues(alpha: 0.2) : AppColors.beige,
              child: Text(
                user.initials,
                style: TextStyle(
                  color: rank <= 3 ? rankColor : AppColors.primaryBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          user.name,
          style: AppTextStyles.heading3.copyWith(
            color: isCurrentUser ? AppColors.primaryBrown : AppColors.textDark,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.xpGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${ArabicHelpers.toArabicNumber(user.xp)} XP',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.xpGold),
          ),
        ),
      ).animate().fadeIn(delay: (50 * rank).ms).slideX(begin: 0.1, end: 0),
    );
  }
}
