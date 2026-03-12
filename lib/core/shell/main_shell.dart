// lib/core/shell/main_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    _NavTab(label: 'Home',     emoji: '🏠', route: AppRoutes.home),
    _NavTab(label: 'Search',   emoji: '🔍', route: AppRoutes.search),
    _NavTab(label: 'Calendar', emoji: '📅', route: AppRoutes.calendar),
    _NavTab(label: 'Gardens',  emoji: '🌿', route: AppRoutes.gardens),
  ];

  int _indexForLocation(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _indexForLocation(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: idx,
          onTap: (i) => context.go(_tabs[i].route),
          items: _tabs
              .map((t) => BottomNavigationBarItem(
                    icon: Text(t.emoji,
                        style: TextStyle(
                          fontSize: 20,
                          // Slightly muted when not selected
                          color: idx == _tabs.indexOf(t)
                              ? null
                              : AppColors.warmGray,
                        )),
                    label: t.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({
    required this.label,
    required this.emoji,
    required this.route,
  });
  final String label;
  final String emoji;
  final String route;
}
