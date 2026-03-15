import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/admin_notifier.dart';
import '../../startups/domain/startup_notifier.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/enums/startup_status.dart';
import '../../../shared/models/startup_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';

class AdminStartupDetailScreen extends ConsumerStatefulWidget {
  final String startupId;
  const AdminStartupDetailScreen({super.key, required this.startupId});

  @override
  ConsumerState<AdminStartupDetailScreen> createState() =>
      _AdminStartupDetailScreenState();
}

class _AdminStartupDetailScreenState
    extends ConsumerState<AdminStartupDetailScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _moderate(String action, StartupModel startup) async {
    final note = _noteController.text.trim();
    final confirmed = await context.showConfirmDialog(
      title: action == 'approve' ? AppStrings.approve : AppStrings.reject,
      content:
          '${action == 'approve' ? 'Approve' : 'Reject'} "${startup.name}"?',
      confirmText: action == 'approve' ? AppStrings.approve : AppStrings.reject,
      isDanger: action == 'reject',
    );
    if (confirmed != true || !mounted) return;

    try {
      if (action == 'approve') {
        await ref
            .read(adminNotifierProvider.notifier)
            .approveStartup(startup.id, note: note.isEmpty ? null : note);
      } else {
        await ref
            .read(adminNotifierProvider.notifier)
            .rejectStartup(startup.id, note: note.isEmpty ? null : note);
      }
      if (mounted) {
        context.showSnackBar('Startup ${action}d successfully');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          ref.read(adminNotifierProvider).error?.message ??
              'Action failed',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final startupAsync = ref.watch(startupDetailProvider(widget.startupId));
    final adminState = ref.watch(adminNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Review Startup')),
      body: startupAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (startup) {
          if (startup == null) {
            return const ErrorView(message: 'Startup not found');
          }
          final s = startup as StartupModel;
          final isPending = s.status == StartupStatus.pending;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(s.industry,
                    style: const TextStyle(color: AppColors.primary)),
                const SizedBox(height: AppSizes.md),
                Text('Description',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(s.description),
                const SizedBox(height: AppSizes.md),
                _Row('Founder', s.founderName),
                if (s.website != null) _Row('Website', s.website!),
                if (s.location != null) _Row('Location', s.location!),
                _Row('Team Size', '${s.teamSize} people'),
                const SizedBox(height: AppSizes.xl),
                if (isPending) ...[
                  const Divider(),
                  const SizedBox(height: AppSizes.md),
                  Text(AppStrings.moderationNote,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSizes.sm),
                  AppTextField(
                    label: AppStrings.moderationNote,
                    controller: _noteController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: AppStrings.reject,
                          variant: AppButtonVariant.danger,
                          onPressed: adminState.isActing
                              ? null
                              : () => _moderate('reject', s),
                          isLoading: adminState.isActing,
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: AppButton(
                          label: AppStrings.approve,
                          onPressed: adminState.isActing
                              ? null
                              : () => _moderate('approve', s),
                          isLoading: adminState.isActing,
                        ),
                      ),
                    ],
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: s.status == StartupStatus.approved
                          ? AppColors.approvedBg
                          : AppColors.rejectedBg,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Text(
                      'Status: ${s.status.displayName}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: s.status == StartupStatus.approved
                            ? AppColors.approvedText
                            : AppColors.rejectedText,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.grey500, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}