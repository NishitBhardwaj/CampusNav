/// CampusNav - Admin Screen
///
/// Admin data entry interface for managing campus data.
/// Only accessible to users with Admin role.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/animation_config.dart';
import '../../state/app_providers.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    // Redirect non-admins
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Admin access required',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: AppColors.accent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Manage Campus Data',
              style: AppTextStyles.heading2,
            )
                .animate()
                .fadeIn(duration: AnimationDurations.standard),
            const SizedBox(height: 8),
            Text(
              'Add, edit, or remove campus information',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),

            // Data Management Cards
            _buildManagementCard(
              context,
              icon: Icons.business,
              title: 'Buildings',
              subtitle: 'Add or edit campus buildings',
              count: 0,
              onTap: () => _showAddDataDialog(context, 'Building'),
            ),
            _buildManagementCard(
              context,
              icon: Icons.layers,
              title: 'Floors',
              subtitle: 'Manage floor plans and maps',
              count: 0,
              onTap: () => _showAddDataDialog(context, 'Floor'),
            ),
            _buildManagementCard(
              context,
              icon: Icons.meeting_room,
              title: 'Rooms',
              subtitle: 'Add rooms and locations',
              count: 0,
              onTap: () => _showAddDataDialog(context, 'Room'),
            ),
            _buildManagementCard(
              context,
              icon: Icons.group,
              title: 'Personnel',
              subtitle: 'Manage faculty and staff',
              count: 0,
              onTap: () => _showAddDataDialog(context, 'Personnel'),
            ),
            _buildManagementCard(
              context,
              icon: Icons.account_tree,
              title: 'Departments',
              subtitle: 'Organize by department',
              count: 0,
              onTap: () => _showAddDataDialog(context, 'Department'),
            ),

            const SizedBox(height: 24),

            // Feedback Review Section
            Text(
              'Feedback Review',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 12),
            _buildFeedbackCard(context, ref),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAddMenu(context),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add),
        label: const Text('Quick Add'),
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required int count,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.accent),
        ),
        title: Text(title, style: AppTextStyles.body),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: onTap,
      ),
    )
        .animate()
        .fadeIn(duration: AnimationDurations.standard)
        .slideX(begin: 0.1, curve: AnimationCurves.enter);
  }

  Widget _buildFeedbackCard(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingFeedbackCountProvider);

    return Card(
      color: pendingCount > 0 ? AppColors.warning.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.feedback,
                  color: pendingCount > 0 ? AppColors.warning : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pendingCount > 0
                        ? '$pendingCount feedback items pending review'
                        : 'No pending feedback',
                    style: AppTextStyles.body,
                  ),
                ),
              ],
            ),
            if (pendingCount > 0) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Navigate to feedback review
                  },
                  child: const Text('Review Feedback'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddDataDialog(BuildContext context, String dataType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $dataType'),
        content: Text(
          'This will open the form to add a new $dataType.\n\n'
          '(Form implementation pending)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$dataType form coming soon!')),
              );
            },
            child: const Text('Open Form'),
          ),
        ],
      ),
    );
  }

  void _showQuickAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Add', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            _buildQuickAddOption(context, Icons.business, 'Building'),
            _buildQuickAddOption(context, Icons.meeting_room, 'Room'),
            _buildQuickAddOption(context, Icons.person_add, 'Personnel'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddOption(BuildContext context, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text('Add $label'),
      onTap: () {
        Navigator.pop(context);
        _showAddDataDialog(context, label);
      },
    );
  }
}
