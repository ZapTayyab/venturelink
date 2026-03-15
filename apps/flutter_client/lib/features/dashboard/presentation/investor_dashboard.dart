import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/domain/auth_notifier.dart';
import '../../startups/domain/startup_notifier.dart';
import '../../funding_rounds/domain/round_notifier.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/startup_model.dart';
import '../../../shared/models/funding_round_model.dart';
import '../../../shared/widgets/loading_indicator.dart';

class InvestorDashboard extends ConsumerWidget {
  const InvestorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user!;
    final openRoundsAsync = ref.watch(openRoundsProvider);
    final startupsAsync = ref.watch(approvedStartupsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Beautiful gradient app bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    CustomPaint(
                      painter: _DashboardPatternPainter(),
                      size: Size(MediaQuery.of(context).size.width, 200),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                    Colors.white.withOpacity(0.2),
                                child: Text(
                                  user.displayName.isNotEmpty
                                      ? user.displayName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    user.displayName,
                                    style: const TextStyle(
                                      color: const Color(0xFF111827),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () =>
                                    context.push(RouteNames.profile),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person_outline,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Role badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.trending_up,
                                    color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                const Text(
                                  'Investor Account',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white),
                onPressed: () => context.push(RouteNames.myInvestments),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick action cards
                  _QuickActions(),
                  const SizedBox(height: AppSizes.lg),

                  // Open rounds section
                  _SectionHeader(
                    title: 'Open Funding Rounds',
                    actionLabel: 'See All',
                    onAction: () => context.push(RouteNames.startupList),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  openRoundsAsync.when(
                    loading: () =>
                        const Center(child: LoadingIndicator()),
                    error: (e, _) => _ErrorCard(message: e.toString()),
                    data: (rounds) {
                      final list = rounds.cast<FundingRoundModel>();
                      if (list.isEmpty) {
                        return _EmptyCard(
                          icon: Icons.search_off,
                          message: 'No open rounds at the moment',
                        );
                      }
                      return Column(
                        children: list
                            .take(5)
                            .map((r) => _OpenRoundCard(round: r))
                            .toList(),
                      );
                    },
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Featured startups
                  _SectionHeader(
                    title: 'Featured Startups',
                    actionLabel: 'Browse',
                    onAction: () => context.push(RouteNames.startupList),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  startupsAsync.when(
                    loading: () =>
                        const Center(child: LoadingIndicator()),
                    error: (e, _) => _ErrorCard(message: e.toString()),
                    data: (startups) {
                      final list = startups.cast<StartupModel>();
                      if (list.isEmpty) {
                        return _EmptyCard(
                          icon: Icons.business_outlined,
                          message: 'No startups yet',
                        );
                      }
                      return SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: list.take(6).length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppSizes.sm),
                          itemBuilder: (_, i) =>
                              _StartupChip(startup: list[i]),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            title: 'Browse\nStartups',
            icon: Icons.explore_outlined,
            gradient: AppColors.primaryGradient,
            onTap: () => context.push(RouteNames.startupList),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: _ActionCard(
            title: 'My\nInvestments',
            icon: Icons.account_balance_wallet_outlined,
            gradient: AppColors.greenGradient,
            onTap: () => context.push(RouteNames.myInvestments),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: _ActionCard(
            title: 'Open\nRounds',
            icon: Icons.bar_chart_rounded,
            gradient: AppColors.goldGradient,
            onTap: () => context.push(RouteNames.startupList),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OpenRoundCard extends StatelessWidget {
  final FundingRoundModel round;
  const _OpenRoundCard({required this.round});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context
          .push('/startups/${round.startupId}/rounds/${round.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.rocket_launch_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        round.startupName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        round.title,
                        style: TextStyle(
                          color: AppColors.grey500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppFormatters.currencyCompact(round.targetAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'target',
                      style: TextStyle(
                          color: AppColors.grey400, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: round.progressPercent / 100,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  round.progressPercent > 75
                      ? AppColors.success
                      : AppColors.primary,
                ),
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${round.progressPercent.toStringAsFixed(0)}% funded',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 11, color: AppColors.grey400),
                    const SizedBox(width: 3),
                    Text(
                      'Closes ${AppFormatters.date(round.deadline)}',
                      style: const TextStyle(
                          color: AppColors.grey400, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupChip extends StatelessWidget {
  final StartupModel startup;
  const _StartupChip({required this.startup});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/startups/${startup.id}'),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.rocket_launch_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              startup.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              startup.industry,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.rejectedBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Text(message,
          style: const TextStyle(color: AppColors.rejectedText)),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.grey300, size: 40),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(color: AppColors.grey400)),
        ],
      ),
    );
  }
}

class _DashboardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (double i = 0; i < size.width + size.height; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(0, i), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}