import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';

/// Shared bottom navigation for Patient screens
/// Provides consistent navigation across Home, Appointments, Health Records, and Profile
class PatientBottomNav extends StatelessWidget {
  final int currentIndex;

  const PatientBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
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
                onTap: () {
                  if (currentIndex != 0) {
                    context.go(AppRoutes.patientHome);
                  }
                },
              ),
              _NavItem(
                icon: Icons.calendar_month_rounded,
                label: 'Appointments',
                isActive: currentIndex == 1,
                onTap: () {
                  if (currentIndex != 1) {
                    context.go(AppRoutes.appointmentsList);
                  }
                },
              ),
              _NavItem(
                icon: Icons.folder_shared_rounded,
                label: 'Records',
                isActive: currentIndex == 2,
                onTap: () {
                  if (currentIndex != 2) {
                    context.go(AppRoutes.healthLocker);
                  }
                },
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: currentIndex == 3,
                onTap: () {
                  if (currentIndex != 3) {
                    context.go(AppRoutes.patientProfile);
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
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textSecondary;

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
