import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/domain/auth_notifier.dart';
import '../../admin/domain/admin_notifier.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/loading_indicator.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user!;
    final adminState = ref.watch(adminNotifierProvider);
    final pendingAsync = ref.watch(pendingStartupsAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(RouteNames.profile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user.displayName}', style: AppTextStyles.heading3),
            const SizedBox(height: AppSizes.lg),
            _QuickStatCards(metrics: adminState.metrics),
            const SizedBox(height: AppSizes.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pending Approvals', style: AppTextStyles.heading4),
                TextButton(
                  onPressed: () => context.push(RouteNames.adminPanel),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            pendingAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (list) => list.isEmpty
                  ? const Text('No pending reviews',
                      style: TextStyle(color: AppColors.grey500))
                  : Text(
                      '${list.length} startup${list.length == 1 ? '' : 's'} awaiting review',
                      style: const TextStyle(color: AppColors.warning),
                    ),
            ),
            const SizedBox(height: AppSizes.lg),
            ElevatedButton.icon(
              onPressed: () => context.push(RouteNames.adminPanel),
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Open Admin Panel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatCards extends StatelessWidget {
  final Map<String, dynamic>? metrics;
  const _QuickStatCards({this.metrics});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Startups',
            value: metrics?['totalStartups']?.toString() ?? '-',
            icon: Icons.rocket_launch_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: _StatCard(
            label: 'Total Users',
            value: metrics?['totalUsers']?.toString() ?? '-',
            icon: Icons.people_outline,
            color: AppColors.info,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: AppSizes.sm),
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: const TextStyle(color: AppColors.grey500, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}