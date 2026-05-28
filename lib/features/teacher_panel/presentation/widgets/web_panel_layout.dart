import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Base layout wrapper for all Web Panels (Teacher & Admin)
class WebPanelLayout extends StatelessWidget {
  final Widget child;

  const WebPanelLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final user = authState.user;
    final isTeacher = user.isTeacher;
    final currentRoute = GoRouterState.of(context).matchedLocation;
    
    String title = 'لوحة التحكم';
    if (currentRoute == '/admin/dashboard') title = 'لوحة إدارة النظام';
    if (currentRoute == '/admin/users') title = 'إدارة المستخدمين';
    if (currentRoute == '/admin/registrations') title = 'طلبات التسجيل';
    if (currentRoute == '/teacher/dashboard') title = 'لوحة تحكم المعلم';
    if (currentRoute == '/teacher/categories') title = 'إدارة الفئات والمستويات';

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: AppColors.primaryBrown,
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Text(
                  'لوحة التحكم',
                  style: TextStyle(
                    color: AppColors.beigeLight,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isTeacher ? 'حساب المعلم' : 'حساب الإدارة',
                  style: const TextStyle(
                    color: AppColors.beigeDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(color: AppColors.primaryBrownLight),
                
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: isTeacher
                        ? _buildTeacherMenu(context, currentRoute)
                        : _buildAdminMenu(context, currentRoute),
                  ),
                ),
                
                const Divider(color: AppColors.primaryBrownLight),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.beigeLight),
                  title: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(color: AppColors.beigeLight),
                  ),
                  onTap: () => context.read<AuthBloc>().add(const LogoutRequested()),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border: Border(bottom: BorderSide(color: AppColors.beigeDark)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: AppTextStyles.heading2),
                      Row(
                        children: [
                          Text(user.name, style: AppTextStyles.labelMedium),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            backgroundColor: AppColors.beige,
                            child: Text(user.initials, style: AppTextStyles.labelMedium),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Body
                Expanded(
                  child: Container(
                    color: AppColors.scaffoldBg,
                    padding: const EdgeInsets.all(32),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTeacherMenu(BuildContext context, String currentRoute) {
    return [
      _buildMenuItem(context, 'الرئيسية', Icons.dashboard, '/teacher/dashboard', currentRoute),
      _buildMenuItem(context, 'الفئات والمستويات', Icons.category, '/teacher/categories', currentRoute),
      // View only students could go here
    ];
  }

  List<Widget> _buildAdminMenu(BuildContext context, String currentRoute) {
    return [
      _buildMenuItem(context, 'الرئيسية', Icons.dashboard, '/admin/dashboard', currentRoute),
      _buildMenuItem(context, 'طلبات التسجيل', Icons.pending_actions, '/admin/registrations', currentRoute),
      _buildMenuItem(context, 'المستخدمين', Icons.people, '/admin/users', currentRoute),
    ];
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, String route, String currentRoute) {
    // Check if the current route starts with the target route (for nested routes like /teacher/categories/...)
    final isActive = currentRoute == route || (route != '/teacher/dashboard' && route != '/admin/dashboard' && currentRoute.startsWith(route));
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppColors.white : AppColors.beigeDark,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? AppColors.white : AppColors.beigeDark,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppColors.primaryBrownDark,
      onTap: () {
        if (!isActive) context.go(route);
      },
    );
  }
}
