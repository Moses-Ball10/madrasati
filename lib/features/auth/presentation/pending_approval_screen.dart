import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

/// Pending approval screen — shown when student is registered but not yet approved
class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Waiting icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBrownLight,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '⏳',
                    style: TextStyle(fontSize: 56),
                  ),
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.05, 1.05),
                    duration: 2000.ms,
                  ),

              const SizedBox(height: 32),

              Text(
                'في انتظار الموافقة',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              Text(
                'تم تسجيل حسابك بنجاح!\nيرجى الانتظار حتى يتم مراجعة طلبك والموافقة عليه من قبل الإدارة.',
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 16),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.beigeDark,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primaryBrown,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'سيتم إشعارك عند الموافقة على حسابك',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 400.ms,
                  ),

              const SizedBox(height: 40),

              // Refresh button
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(const CheckAuthStatus());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('تحقق من حالة الطلب'),
                  );
                },
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 16),

              // Logout button
              TextButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(const LogoutRequested());
                },
                icon: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                ),
                label: Text(
                  'تسجيل الخروج',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
