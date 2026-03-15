import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/startup_notifier.dart';
import '../../auth/domain/auth_notifier.dart';
import '../../funding_rounds/domain/round_notifier.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/enums/user_role.dart';
import '../../../shared/models/startup_model.dart';
import '../../../shared/models/funding_round_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../core/utils/formatters.dart';

class StartupDetailScreen extends ConsumerWidget {
  final String startupId;

  const StartupDetailScreen({super.key, required this.startupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(startupDetailProvider(startupId));
    final user = ref.watch(authNotifierProvider).user;

    return startupAsync.when(
      loading: () => const Scaffold(body: Center(child: LoadingIndicator())),
      error: (e, _) => Scaffold(body: ErrorView(message: e.toString())),
      data: (startup) {
        if (startup == null) {
          return const Scaffold(body: ErrorView(message: 'Startup not found'));
        }
        final s = startup as StartupModel;
        final isOwner = user?.uid == s.founderId;

        return Scaffold(
          appBar: AppBar(
            title: Text(s.name),
            actions: [
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push('/startups/$startupId/edit'),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StartupHeader(startup: s),
                const SizedBox(height: AppSizes.lg),
                _InfoSection(startup: s),
                const SizedBox(height: AppSizes.lg),
                _RoundsSection(startupId: startupId, isOwner: isOwner),
              ],
            ),
          ),
          floatingActionButton: isOwner
              ? FloatingActionButton.extended(
                  onPressed: () =>
                      context.push('/startups/$startupId/rounds/create'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Round'),
                  backgroundColor: AppColors.primary,
                )
              : null,
        );
      },
    );
  }
}

class _StartupHeader extends StatelessWidget {
  final StartupModel startup;
  const _StartupHeader({required this.startup});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: startup.logoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: Image.network(startup.logoUrl!, fit: BoxFit.cover),
                )
              : const Icon(Icons.rocket_launch_rounded,
                  size: 36, color: AppColors.primary),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(startup.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              Text(startup.industry,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.primary)),
              if (startup.location != null)
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.grey500),
                    const SizedBox(width: 2),
                    Text(startup.location!,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final StartupModel startup;
  const _InfoSection({required this.startup});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSizes.sm),
        Text(startup.description, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSizes.md),
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.xs,
          children: [
            _Chip(Icons.group_outlined, '${startup.teamSize} people'),
            if (startup.website != null)
              _Chip(Icons.link, startup.website!),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm, vertical: AppSizes.xs),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.grey600),
          const SizedBox(width: 4),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.grey600)),
        ],
      ),
    );
  }
}

class _RoundsSection extends ConsumerWidget {
  final String startupId;
  final bool isOwner;

  const _RoundsSection({required this.startupId, required this.isOwner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundsAsync = ref.watch(startupRoundsProvider(startupId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Funding Rounds',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSizes.sm),
        roundsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => const Text('Error loading rounds'),
          data: (rounds) {
            if (rounds.isEmpty) {
              return const Text('No funding rounds yet.',
                  style: TextStyle(color: AppColors.grey500));
            }
            return Column(
              children: rounds
                  .map((r) => _RoundTile(
                      round: r as FundingRoundModel,
                      startupId: startupId))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _RoundTile extends StatelessWidget {
  final FundingRoundModel round;
  final String startupId;
  const _RoundTile({required this.round, required this.startupId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: InkWell(
        onTap: () => context.push('/startups/$startupId/rounds/${round.id}'),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(round.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: round.isOpen
                          ? AppColors.approvedBg
                          : AppColors.grey100,
                      borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull),
                    ),
                    child: Text(
                      round.status.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: round.isOpen
                            ? AppColors.approvedText
                            : AppColors.grey600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              LinearProgressIndicator(
                value: round.progressPercent / 100,
                backgroundColor: AppColors.grey200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
                borderRadius:
                    BorderRadius.circular(AppSizes.radiusFull),
              ),
              const SizedBox(height: AppSizes.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppFormatters.currencyCompact(round.raisedAmount),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                  Text(
                    'of ${AppFormatters.currencyCompact(round.targetAmount)}',
                    style: const TextStyle(color: AppColors.grey500, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}