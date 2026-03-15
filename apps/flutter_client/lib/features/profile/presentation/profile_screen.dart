import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/profile_notifier.dart';
import '../../auth/domain/auth_notifier.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(profileNotifierProvider.notifier).updateProfile(
            displayName: _nameController.text.trim(),
          );
      if (mounted) {
        setState(() => _editing = false);
        context.showSnackBar('Profile updated!');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Update failed', isError: true);
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await context.showConfirmDialog(
      title: AppStrings.logout,
      content: 'Are you sure you want to log out?',
      confirmText: AppStrings.logout,
      isDanger: true,
    );
    if (confirmed == true && mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final profileState = ref.watch(profileNotifierProvider);

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.accent,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.heading2
                          .copyWith(color: AppColors.primary),
                    )
                  : null,
            ),
            const SizedBox(height: AppSizes.md),
            if (!_editing) ...[
              Text(user.displayName, style: AppTextStyles.heading3),
              Text(user.email,
                  style: AppTextStyles.body.copyWith(color: AppColors.grey500)),
              const SizedBox(height: AppSizes.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  user.role.displayName,
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.primaryDark),
                ),
              ),
            ] else ...[
              Form(
                key: _formKey,
                child: AppTextField(
                  label: AppStrings.fullName,
                  controller: _nameController,
                  validator: (v) =>
                      Validators.minLength(v, 2, fieldName: 'Name'),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: AppStrings.cancel,
                      variant: AppButtonVariant.outlined,
                      onPressed: () => setState(() => _editing = false),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: AppButton(
                      label: AppStrings.save,
                      onPressed: _save,
                      isLoading: profileState.isUpdating,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSizes.xxl),
            const Divider(),
            const SizedBox(height: AppSizes.md),
            AppButton(
              label: AppStrings.logout,
              variant: AppButtonVariant.danger,
              onPressed: _logout,
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    );
  }
}