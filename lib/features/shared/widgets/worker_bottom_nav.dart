import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';

/// Shared bottom navigation for Frontline Worker screens
/// Provides consistent navigation across Home, My Work, Patients, and Profile
class WorkerBottomNav extends StatelessWidget {
  final int currentIndex;

  const WorkerBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Orange accent color for active state (Swasthya Orange from design system)
    const activeColor = Color(0xFFE85D04);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                activeColor: activeColor,
                onTap: () {
                  if (currentIndex != 0) {
                    // Use go for bottom nav to maintain clean stack
                    context.go(AppRoutes.workerHome);
                  }
                },
              ),
              _NavItem(
                icon: Icons.work_outline_rounded,
                label: 'My Work',
                isActive: currentIndex == 1,
                activeColor: activeColor,
                onTap: () {
                  if (currentIndex != 1) {
                    context.go(AppRoutes.myWork);
                  }
                },
              ),
              _NavItem(
                icon: Icons.people_outline_rounded,
                label: 'Patients',
                isActive: currentIndex == 2,
                activeColor: activeColor,
                onTap: () {
                  if (currentIndex != 2) {
                    context.go(AppRoutes.workerPatients);
                  }
                },
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isActive: currentIndex == 3,
                activeColor: activeColor,
                onTap: () {
                  if (currentIndex != 3) {
                    context.go(AppRoutes.workerProfile);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : AppColors.textSecondary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
