import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/round_notifier.dart';
import '../../auth/domain/auth_notifier.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/enums/user_role.dart';
import '../../../shared/models/funding_round_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';

class RoundDetailScreen extends ConsumerWidget {
  final String startupId;
  final String roundId;

  const RoundDetailScreen({
    super.key,
    required this.startupId,
    required this.roundId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundAsync = ref.watch(roundDetailProvider(roundId));
    final user = ref.watch(authNotifierProvider).user;

    return roundAsync.when(
      loading: () => const Scaffold(body: Center(child: LoadingIndicator())),
      error: (e, _) => Scaffold(body: ErrorView(message: e.toString())),
      data: (round) {
        if (round == null) {
          return const Scaffold(body: ErrorView(message: 'Round not found'));
        }
        final r = round as FundingRoundModel;
        final isInvestor = user?.role == UserRole.investor;
        final canInvest = isInvestor && r.isOpen;

        return Scaffold(
          appBar: AppBar(title: Text(r.title)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RoundStats(round: r),
                const SizedBox(height: AppSizes.lg),
                _RoundInfo(round: r),
                const SizedBox(height: AppSizes.xl),
                if (canInvest)
                  AppButton(
                    label:
                        'Invest Now — Min ${AppFormatters.currencyCompact(r.minInvestment)}',
                    onPressed: () => context.push(
                        '/startups/$startupId/rounds/$roundId/invest'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoundStats extends StatelessWidget {
  final FundingRoundModel round;
  const _RoundStats({required this.round});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  label: 'Raised',
                  value: AppFormatters.currencyCompact(round.raisedAmount),
                  valueColor: AppColors.primary,
                ),
                _StatItem(
                  label: 'Target',
                  value: AppFormatters.currencyCompact(round.targetAmount),
                ),
                _StatItem(
                  label: 'Investors',
                  value: round.investorCount.toString(),
                ),
                _StatItem(
                  label: 'Progress',
                  value: AppFormatters.percentage(round.progressPercent),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            LinearProgressIndicator(
              value: round.progressPercent / 100,
              minHeight: 10,
              backgroundColor: AppColors.grey200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.grey500)),
      ],
    );
  }
}

class _RoundInfo extends StatelessWidget {
  final FundingRoundModel round;
  const _RoundInfo({required this.round});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Details',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSizes.sm),
        _InfoRow('Minimum Investment',
            AppFormatters.currency(round.minInvestment)),
        _InfoRow('Remaining',
            AppFormatters.currencyCompact(round.remainingAmount)),
        _InfoRow('Deadline', AppFormatters.date(round.deadline)),
        _InfoRow('Status', round.status.displayName),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.grey600)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}