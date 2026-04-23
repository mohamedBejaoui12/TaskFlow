import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/projects/presentation/screens/project_detail_screen.dart';
import '../../features/projects/presentation/screens/project_form_screen.dart';
import '../../features/projects/presentation/screens/projects_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/tasks/presentation/screens/task_form_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import 'router_notifier.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: notifier,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      if (session == null && !isAuthRoute) return '/login';
      if (session != null && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (_, state, child) => AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/projects', builder: (_, __) => const ProjectsScreen(), routes: [
            GoRoute(
              path: 'form',
              builder: (_, __) => const ProjectFormScreen(),
            ),
            GoRoute(
              path: 'form/:id',
              builder: (_, state) => ProjectFormScreen(projectId: state.pathParameters['id']),
            ),
            GoRoute(
              path: ':id',
              builder: (_, state) => ProjectDetailScreen(projectId: state.pathParameters['id']!),
            ),
          ]),
          GoRoute(path: '/tasks', builder: (_, __) => const TasksScreen(), routes: [
            GoRoute(
              path: 'form',
              builder: (_, __) => const TaskFormScreen(),
            ),
            GoRoute(
              path: 'form/:id',
              builder: (_, state) => TaskFormScreen(taskId: state.pathParameters['id']),
            ),
          ]),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  int _index() {
    if (location.startsWith('/projects')) return 1;
    if (location.startsWith('/tasks')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index(),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.folder_copy_outlined), label: 'Projects'),
          NavigationDestination(icon: Icon(Icons.task_alt_outlined), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/projects');
              break;
            case 2:
              context.go('/tasks');
              break;
            case 3:
              context.go('/settings');
              break;
          }
        },
      ),
    );
  }
}
