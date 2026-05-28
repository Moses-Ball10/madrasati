import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/user_model.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/pending_approval_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/level_map/presentation/level_map_screen.dart';
import '../../features/lesson/presentation/lesson_screen.dart';
import '../../features/test_engine/presentation/test_screen.dart';
import '../../features/result/presentation/result_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/teacher_panel/presentation/teacher_dashboard_screen.dart';
import '../../features/teacher_panel/presentation/category_manager_screen.dart';
import '../../features/teacher_panel/presentation/level_manager_screen.dart';
import '../../features/teacher_panel/presentation/lesson_editor_screen.dart';
import '../../features/teacher_panel/presentation/question_editor_screen.dart';
import '../../features/admin_panel/presentation/admin_dashboard_screen.dart';
import '../../features/admin_panel/presentation/user_manager_screen.dart';
import '../../features/admin_panel/presentation/registration_requests_screen.dart';
import '../../features/admin_panel/presentation/bloc/admin_bloc.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/teacher_panel/data/teacher_repository.dart';
import '../../features/teacher_panel/presentation/bloc/teacher_bloc.dart';
import '../../features/teacher_panel/presentation/widgets/web_panel_layout.dart';
import '../theme/app_colors.dart';

/// App router with role-based guards
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();
  static final _adminShellKey = GlobalKey<NavigatorState>();
  static final _teacherShellKey = GlobalKey<NavigatorState>();

  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/login',
      refreshListenable: _AuthRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final currentPath = state.matchedLocation;
        final isAuthRoute =
            currentPath == '/login' || currentPath == '/register';

        // Not authenticated → go to login
        if (authState is AuthUnauthenticated || authState is AuthInitial) {
          return isAuthRoute ? null : '/login';
        }

        // Loading → stay put
        if (authState is AuthLoading) {
          return null;
        }

        // Error → go to login
        if (authState is AuthError) {
          return isAuthRoute ? null : '/login';
        }

        // Pending approval
        if (authState is AuthPendingApproval) {
          return currentPath == '/pending' ? null : '/pending';
        }

        // Rejected
        if (authState is AuthRejected) {
          return currentPath == '/pending' ? null : '/pending';
        }

        // Disabled
        if (authState is AuthDisabled) {
          return currentPath == '/pending' ? null : '/pending';
        }

        // Authenticated — route based on role
        if (authState is AuthAuthenticated) {
          final user = authState.user;

          // If on auth routes, redirect to proper home
          if (isAuthRoute || currentPath == '/pending') {
            return _homeRouteForRole(user.role);
          }

          // Teacher routes — web only
          if (currentPath.startsWith('/teacher')) {
            if (user.role != UserRole.teacher && user.role != UserRole.admin) {
              return _homeRouteForRole(user.role);
            }
            if (!kIsWeb) {
              return '/web-only';
            }
          }

          // Admin routes — web only
          if (currentPath.startsWith('/admin')) {
            if (user.role != UserRole.admin) {
              return _homeRouteForRole(user.role);
            }
            if (!kIsWeb) {
              return '/web-only';
            }
          }

          return null;
        }

        return '/login';
      },
      routes: [
        // ── Public routes ──
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/pending',
          builder: (context, state) => const PendingApprovalScreen(),
        ),
        GoRoute(
          path: '/web-only',
          builder: (context, state) => const _WebOnlyScreen(),
        ),

        // ── Student shell with bottom navigation ──
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) =>
              _StudentShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
            GoRoute(
              path: '/categories',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CategoriesScreen(),
              ),
            ),
            GoRoute(
              path: '/leaderboard',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: LeaderboardScreen(),
              ),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
              ),
            ),
          ],
        ),

        // ── Student standalone screens (no bottom nav) ──
        GoRoute(
          path: '/level-map/:categoryId',
          builder: (context, state) => LevelMapScreen(
            categoryId: state.pathParameters['categoryId']!,
          ),
        ),
        GoRoute(
          path: '/lesson/:categoryId/:levelId',
          builder: (context, state) => LessonScreen(
            categoryId: state.pathParameters['categoryId']!,
            levelId: state.pathParameters['levelId']!,
          ),
        ),
        GoRoute(
          path: '/test/:categoryId/:levelId',
          builder: (context, state) => TestScreen(
            categoryId: state.pathParameters['categoryId']!,
            levelId: state.pathParameters['levelId']!,
          ),
        ),
        GoRoute(
          path: '/result/:categoryId/:levelId',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return ResultScreen(
              categoryId: state.pathParameters['categoryId']!,
              levelId: state.pathParameters['levelId']!,
              score: extra['score'] as int? ?? 0,
              stars: extra['stars'] as int? ?? 0,
              correctAnswers: extra['correctAnswers'] as int? ?? 0,
              totalQuestions: extra['totalQuestions'] as int? ?? 0,
              timeSeconds: extra['timeSeconds'] as int? ?? 0,
            );
          },
        ),

        // ── Teacher Shell Route (web only) ──
        ShellRoute(
          navigatorKey: _teacherShellKey,
          builder: (context, state, child) => MultiRepositoryProvider(
            providers: [
              RepositoryProvider<TeacherRepository>(
                create: (context) => TeacherRepository(),
              ),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider<TeacherBloc>(
                  create: (context) => TeacherBloc(
                    teacherRepository: context.read<TeacherRepository>(),
                  ),
                ),
              ],
              child: WebPanelLayout(child: child),
            ),
          ),
          routes: [
            GoRoute(
              path: '/teacher/dashboard',
              pageBuilder: (context, state) => const NoTransitionPage(child: TeacherDashboardScreen()),
            ),
            GoRoute(
              path: '/teacher/categories',
              pageBuilder: (context, state) => const NoTransitionPage(child: CategoryManagerScreen()),
            ),
            GoRoute(
              path: '/teacher/categories/:categoryId/levels',
              pageBuilder: (context, state) => NoTransitionPage(child: LevelManagerScreen(
                categoryId: state.pathParameters['categoryId']!,
                categoryName: state.extra as String? ?? 'الفئة',
              )),
            ),
            GoRoute(
              path: '/teacher/categories/:categoryId/levels/:levelId/lesson',
              pageBuilder: (context, state) => NoTransitionPage(child: LessonEditorScreen(
                categoryId: state.pathParameters['categoryId']!,
                levelId: state.pathParameters['levelId']!,
                levelName: state.extra as String? ?? 'المستوى',
              )),
            ),
            GoRoute(
              path: '/teacher/categories/:categoryId/levels/:levelId/questions',
              pageBuilder: (context, state) => NoTransitionPage(child: QuestionEditorScreen(
                categoryId: state.pathParameters['categoryId']!,
                levelId: state.pathParameters['levelId']!,
                levelName: state.extra as String? ?? 'المستوى',
              )),
            ),
          ],
        ),

        // ── Admin Shell Route (web only) ──
        ShellRoute(
          navigatorKey: _adminShellKey,
          builder: (context, state, child) {
            // Provide AdminBloc here so all admin routes can access it
            return BlocProvider(
              create: (context) => AdminBloc(
                authRepository: context.read<AuthRepository>(),
              ),
              child: WebPanelLayout(child: child),
            );
          },
          routes: [
            GoRoute(
              path: '/admin/dashboard',
              pageBuilder: (context, state) => const NoTransitionPage(child: AdminDashboardScreen()),
            ),
            GoRoute(
              path: '/admin/users',
              pageBuilder: (context, state) => const NoTransitionPage(child: UserManagerScreen()),
            ),
            GoRoute(
              path: '/admin/registrations',
              pageBuilder: (context, state) => const NoTransitionPage(child: RegistrationRequestsScreen()),
            ),
          ],
        ),
      ],
    );
  }

  static String _homeRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return '/home';
      case UserRole.teacher:
        return kIsWeb ? '/teacher/dashboard' : '/web-only';
      case UserRole.admin:
        return kIsWeb ? '/admin/dashboard' : '/web-only';
    }
  }
}

/// Bottom navigation shell for student app
class _StudentShell extends StatefulWidget {
  final Widget child;

  const _StudentShell({required this.child});

  @override
  State<_StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<_StudentShell> {
  static const _tabs = [
    '/home',
    '/categories',
    '/leaderboard',
    '/profile',
  ];

  bool _isOffline = false;
  late final Stream<List<dynamic>> _connectivityStream;

  @override
  void initState() {
    super.initState();
    // Using simple polling or stream depending on package capability
    // For simplicity with generic types, we rely on a custom periodic check or real stream
    _checkInitialConnection();
  }
  
  Future<void> _checkInitialConnection() async {
     // A simple fallback if we don't have direct stream access without importing the package properly here
     // In a real app we'd use Connectivity().onConnectivityChanged
     // Since we don't want to overcomplicate the router with connectivity logic, we'll keep it simple
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Basic offline banner - could be hooked up to a global bloc in reality
          // For now, it's a UI placeholder that would be triggered by network state
          if (_isOffline)
            Container(
              width: double.infinity,
              color: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: const Text(
                'أنت غير متصل بالإنترنت. سيتم تخزين تقدمك محلياً.',
                style: TextStyle(color: AppColors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateIndex(context),
        onTap: (index) => GoRouter.of(context).go(_tabs[index]),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'الدروس',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'المتصدرون',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }

  int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }
}

/// Screen shown when teacher/admin tries to access web panel on mobile
class _WebOnlyScreen extends StatelessWidget {
  const _WebOnlyScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.computer,
                size: 80,
                color: AppColors.primaryBrownLight,
              ),
              const SizedBox(height: 24),
              Text(
                'استخدم المتصفح',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'لوحة التحكم متاحة فقط عبر متصفح الويب.\nيرجى فتح الرابط في المتصفح للوصول إلى لوحة التحكم.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textLight,
                      height: 1.7,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Listenable that refreshes the router when auth state changes
class _AuthRefreshStream extends ChangeNotifier {
  _AuthRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
