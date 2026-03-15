import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/admin_notifier.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/enums/startup_status.dart';
import '../../../shared/models/startup_model.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';

class AdminStartupListScreen extends ConsumerStatefulWidget {
  const AdminStartupListScreen({super.key});

  @override
  ConsumerState<AdminStartupListScreen> createState() =>
      _AdminStartupListScreenState();
}

class _AdminStartupListScreenState
    extends ConsumerState<AdminStartupListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminNotifierProvider.notifier).loadMetrics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metricsState = ref.watch(adminNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminPanel),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'All Startups'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (metricsState.metrics != null)
            _MetricsBanner(metrics: metricsState.metrics!),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _PendingStartupsList(),
                _AllStartupsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsBanner extends StatelessWidget {
  final Map<String, dynamic> metrics;
  const _MetricsBanner({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Metric('Startups', metrics['totalStartups']?.toString() ?? '-'),
          _Metric('Investors', metrics['totalInvestors']?.toString() ?? '-'),
          _Metric(
              'Raised',
              AppFormatters.currencyCompact(
                  (metrics['totalRaised'] as num?)?.toDouble() ?? 0)),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        Text(label,
            style: const TextStyle(color: AppColors.accent, fontSize: 12)),
      ],
    );
  }
}

class _PendingStartupsList extends ConsumerWidget {
  const _PendingStartupsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pendingStartupsAdminProvider);
    return async.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (startups) {
        if (startups.isEmpty) {
          return const EmptyStateView(
            title: 'No pending startups',
            subtitle: 'All caught up! 🎉',
            icon: Icons.check_circle_outline,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.md),
          itemCount: startups.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
          itemBuilder: (_, i) => _AdminStartupCard(startup: startups[i]),
        );
      },
    );
  }
}

class _AllStartupsList extends ConsumerWidget {
  const _AllStartupsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allStartupsAdminProvider);
    return async.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (startups) {
        if (startups.isEmpty) {
          return const EmptyStateView(
            title: 'No startups found',
            icon: Icons.business_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.md),
          itemCount: startups.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
          itemBuilder: (_, i) => _AdminStartupCard(startup: startups[i]),
        );
      },
    );
  }
}

class _AdminStartupCard extends StatelessWidget {
  final StartupModel startup;
  const _AdminStartupCard({required this.startup});

  Color get _statusColor => switch (startup.status) {
        StartupStatus.approved => AppColors.success,
        StartupStatus.rejected => AppColors.error,
        StartupStatus.pending => AppColors.warning,
        _ => AppColors.grey500,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/admin/startups/${startup.id}'),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(startup.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(startup.industry,
                        style: const TextStyle(color: AppColors.grey500, fontSize: 12)),
                    Text('by ${startup.founderName}',
                        style: const TextStyle(color: AppColors.grey400, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  startup.status.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              const Icon(Icons.chevron_right, color: AppColors.grey400),
            ],
          ),
        ),
      ),
    );
  }
}