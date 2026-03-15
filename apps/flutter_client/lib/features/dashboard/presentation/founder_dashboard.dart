import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/domain/auth_notifier.dart';
import '../../startups/domain/startup_notifier.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routing/route_names.dart';
import '../../../shared/enums/startup_status.dart';
import '../../../shared/models/startup_model.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/gradient_button.dart';

class FounderDashboard extends ConsumerWidget {
  const FounderDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user!;
    final startupsAsync = ref.watch(founderStartupsProvider(user.uid));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF302B63), Color(0xFF6C63FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.rocket_launch_rounded,
                                color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Founder Dashboard',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                user.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => context.push(RouteNames.profile),
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
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.white),
                onPressed: () => context.push(RouteNames.createStartup),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  startupsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (startups) {
                      final list = startups.cast<StartupModel>();
                      final approved = list
                          .where((s) =>
                              s.status == StartupStatus.approved)
                          .length;
                      final pending = list
                          .where(
                              (s) => s.status == StartupStatus.pending)
                          .length;
                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              value: list.length.toString(),
                              label: 'Total\nStartups',
                              gradient: AppColors.primaryGradient,
                              icon: Icons.business_outlined,
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: _StatCard(
                              value: approved.toString(),
                              label: 'Approved',
                              gradient: AppColors.greenGradient,
                              icon: Icons.check_circle_outline,
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: _StatCard(
                              value: pending.toString(),
                              label: 'Pending',
                              gradient: AppColors.goldGradient,
                              icon: Icons.hourglass_empty,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.lg),
                  const Text(
                    'My Startups',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  startupsAsync.when(
                    loading: () =>
                        const Center(child: LoadingIndicator()),
                    error: (e, _) => Text('Error: $e'),
                    data: (startups) {
                      final list = startups.cast<StartupModel>();
                      return Column(
                        children: [
                          ...list.map((s) => _FounderStartupCard(startup: s)),
                          const SizedBox(height: AppSizes.md),
                          GradientButton(
                            label: '+ Add New Startup',
                            gradient: AppColors.primaryGradient,
                            icon: Icons.add,
                            onPressed: () =>
                                context.push(RouteNames.createStartup),
                          ),
                        ],
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

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final LinearGradient gradient;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _FounderStartupCard extends StatelessWidget {
  final StartupModel startup;
  const _FounderStartupCard({required this.startup});

  LinearGradient get _statusGradient => switch (startup.status) {
        StartupStatus.approved => AppColors.greenGradient,
        StartupStatus.rejected => const LinearGradient(
            colors: [AppColors.error, Color(0xFFFF8FA3)]),
        _ => AppColors.goldGradient,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/startups/${startup.id}'),
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.rocket_launch_rounded,
                  color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startup.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    startup.industry,
                    style: const TextStyle(
                      color: AppColors.grey500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: _statusGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                startup.status.displayName,
                style: const TextStyle(
                  color: const Color(0xFF111827),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}