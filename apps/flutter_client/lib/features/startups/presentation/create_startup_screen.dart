import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/startup_notifier.dart';
import '../../auth/domain/auth_notifier.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class CreateStartupScreen extends ConsumerStatefulWidget {
  const CreateStartupScreen({super.key});

  @override
  ConsumerState<CreateStartupScreen> createState() => _CreateStartupScreenState();
}

class _CreateStartupScreenState extends ConsumerState<CreateStartupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _industryController = TextEditingController();
  final _websiteController = TextEditingController();
  final _locationController = TextEditingController();
  final _teamSizeController = TextEditingController(text: '1');

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _industryController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    _teamSizeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    try {
      await ref.read(startupFormNotifierProvider.notifier).createStartup({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'industry': _industryController.text.trim(),
        'website': _websiteController.text.trim(),
        'location': _locationController.text.trim(),
        'teamSize': int.tryParse(_teamSizeController.text) ?? 1,
      });
      if (mounted) {
        context.showSnackBar('Startup submitted for review!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          ref.read(startupFormNotifierProvider).error?.message ??
              'Failed to create startup',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(startupFormNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createStartup)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxFormWidth),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tell us about your startup', style: AppTextStyles.heading3),
                const SizedBox(height: AppSizes.lg),
                AppTextField(
                  label: AppStrings.startupName,
                  controller: _nameController,
                  validator: (v) => Validators.minLength(v, 2, fieldName: 'Startup name'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  label: AppStrings.startupDescription,
                  controller: _descController,
                  maxLines: 4,
                  validator: (v) => Validators.minLength(v, 20, fieldName: 'Description'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  label: AppStrings.industry,
                  controller: _industryController,
                  validator: (v) => Validators.required(v, fieldName: 'Industry'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  label: AppStrings.website,
                  controller: _websiteController,
                  keyboardType: TextInputType.url,
                  validator: Validators.url,
                  hint: 'https://yourcompany.com',
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  label: AppStrings.location,
                  controller: _locationController,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  label: AppStrings.teamSize,
                  controller: _teamSizeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => Validators.positiveNumber(v, fieldName: 'Team size'),
                ),
                const SizedBox(height: AppSizes.xl),
                AppButton(
                  label: 'Submit for Review',
                  onPressed: _submit,
                  isLoading: state.isSubmitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}