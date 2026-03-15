import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/investment_notifier.dart';
import '../../auth/domain/auth_notifier.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/investment_model.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';

class MyInvestmentsScreen extends ConsumerWidget {
  const MyInvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    if (user == null) return const SizedBox.shrink();

    final investmentsAsync = ref.watch(myInvestmentsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myInvestments)),
      body: investmentsAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (investments) {
          final list = investments.cast<InvestmentModel>();
          if (list.isEmpty) {
            return const EmptyStateView(
              title: 'No investments yet',
              subtitle: 'Browse startups and invest in promising rounds.',
              icon: Icons.trending_up_outlined,
            );
          }

          final total = list.fold(0.0, (sum, i) => sum + i.amount);

          return Column(
            children: [
              _TotalBanner(total: total, count: list.length),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.md),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSizes.sm),
                  itemBuilder: (context, index) =>
                      _InvestmentTile(investment: list[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TotalBanner extends StatelessWidget {
  final double total;
  final int count;
  const _TotalBanner({required this.total, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      color: AppColors.primary,
      child: Column(
        children: [
          Text(
            AppFormatters.currency(total),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Total across $count investment${count == 1 ? '' : 's'}',
            style: const TextStyle(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class _InvestmentTile extends StatelessWidget {
  final InvestmentModel investment;
  const _InvestmentTile({required this.investment});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (investment.status) {
      InvestmentStatus.confirmed => AppColors.success,
      InvestmentStatus.failed => AppColors.error,
      InvestmentStatus.refunded => AppColors.warning,
      _ => AppColors.grey500,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(Icons.rocket_launch_rounded,
                  color: AppColors.primary),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    investment.startupName,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    investment.roundTitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.grey600),
                  ),
                  Text(
                    AppFormatters.relativeTime(investment.createdAt),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.grey400),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.currency(investment.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    investment.status.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}