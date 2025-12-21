/// CampusNav - Home Screen
///
/// Main navigation hub with role-based options.
/// Shows different actions for User vs Admin roles.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/animation_config.dart';
import '../../state/app_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CampusNav'),
        centerTitle: true,
        actions: [
          // Role toggle (for demo)
          IconButton(
            icon: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person),
            tooltip: isAdmin ? 'Switch to User' : 'Switch to Admin',
            onPressed: () {
              ref.read(authProvider.notifier).toggleRole();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              _buildWelcomeCard(context, currentUser.name, isAdmin),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 12),

              // Action Grid
              _buildActionGrid(context, isAdmin),

              const SizedBox(height: 24),

              // Admin-only section
              if (isAdmin) ...[
                Text(
                  'Admin Tools',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 12),
                _buildAdminSection(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String? name, bool isAdmin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAdmin
              ? [AppColors.accent, AppColors.accentDark]
              : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isAdmin ? AppColors.accent : AppColors.primary)
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome${name != null ? ", $name" : ""}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isAdmin ? 'Administrator Mode' : 'User Mode',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isAdmin
                ? 'Manage campus data and review feedback'
                : 'Find your way around campus',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AnimationDurations.medium)
        .slideY(begin: 0.2, curve: AnimationCurves.enter);
  }

  Widget _buildActionGrid(BuildContext context, bool isAdmin) {
    final actions = [
      _ActionItem(
        icon: Icons.search,
        label: 'Search',
        color: AppColors.primary,
        onTap: () => Navigator.pushNamed(context, '/search'),
      ),
      _ActionItem(
        icon: Icons.navigation,
        label: 'Navigate',
        color: AppColors.pathColor,
        onTap: () => Navigator.pushNamed(context, '/navigation'),
      ),
      _ActionItem(
        icon: Icons.qr_code_scanner,
        label: 'Scan QR',
        color: AppColors.accent,
        onTap: () => Navigator.pushNamed(context, '/location_init'),
      ),
      _ActionItem(
        icon: Icons.people,
        label: 'Find People',
        color: AppColors.warning,
        onTap: () => Navigator.pushNamed(context, '/search'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionCard(action, index);
      },
    );
  }

  Widget _buildActionCard(_ActionItem action, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                action.label,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: AnimationDurations.standard,
        )
        .scale(begin: const Offset(0.9, 0.9), curve: AnimationCurves.enter);
  }

  Widget _buildAdminSection(BuildContext context) {
    return Column(
      children: [
        _buildAdminTile(
          context,
          icon: Icons.add_location_alt,
          title: 'Add Campus Data',
          subtitle: 'Buildings, rooms, personnel',
          onTap: () => Navigator.pushNamed(context, '/admin'),
        ),
        const SizedBox(height: 12),
        _buildAdminTile(
          context,
          icon: Icons.feedback,
          title: 'Review Feedback',
          subtitle: 'User-submitted corrections',
          onTap: () {
            // TODO: Navigate to feedback review
          },
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: AnimationDurations.medium);
  }

  Widget _buildAdminTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.accent),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
