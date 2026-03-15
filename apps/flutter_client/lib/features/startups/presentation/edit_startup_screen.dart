import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/startup_notifier.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/startup_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_view.dart';

class EditStartupScreen extends ConsumerWidget {
  final String startupId;
  const EditStartupScreen({super.key, required this.startupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(startupDetailProvider(startupId));
    return startupAsync.when(
      loading: () => const Scaffold(body: Center(child: LoadingIndicator())),
      error: (e, _) => Scaffold(body: ErrorView(message: e.toString())),
      data: (startup) => startup == null
          ? const Scaffold(body: ErrorView(message: 'Not found'))
          : _EditForm(startup: startup as StartupModel),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  final StartupModel startup;
  const _EditForm({required this.startup});

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _industryController;
  late final TextEditingController _websiteController;
  late final TextEditingController _locationController;
  late final TextEditingController _teamSizeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.startup.name);
    _descController = TextEditingController(text: widget.startup.description);
    _industryController = TextEditingController(text: widget.startup.industry);
    _websiteController = TextEditingController(text: widget.startup.website ?? '');
    _locationController = TextEditingController(text: widget.startup.location ?? '');
    _teamSizeController =
        TextEditingController(text: widget.startup.teamSize.toString());
  }

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(startupFormNotifierProvider.notifier).updateStartup(
        widget.startup.id,
        {
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
          'industry': _industryController.text.trim(),
          'website': _websiteController.text.trim(),
          'location': _locationController.text.trim(),
          'teamSize': int.tryParse(_teamSizeController.text) ?? 1,
        },
      );
      if (mounted) {
        context.showSnackBar('Startup updated!');
        context.pop();
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Update failed', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(startupFormNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.editStartup)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                  label: AppStrings.startupName,
                  controller: _nameController,
                  validator: (v) =>
                      Validators.minLength(v, 2, fieldName: 'Startup name')),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                  label: AppStrings.startupDescription,
                  controller: _descController,
                  maxLines: 4,
                  validator: (v) =>
                      Validators.minLength(v, 20, fieldName: 'Description')),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                  label: AppStrings.industry,
                  controller: _industryController,
                  validator: (v) =>
                      Validators.required(v, fieldName: 'Industry')),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                  label: AppStrings.website,
                  controller: _websiteController,
                  keyboardType: TextInputType.url,
                  validator: Validators.url),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                  label: AppStrings.location,
                  controller: _locationController),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                label: AppStrings.teamSize,
                controller: _teamSizeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: AppSizes.xl),
              AppButton(
                label: AppStrings.save,
                onPressed: _save,
                isLoading: state.isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}