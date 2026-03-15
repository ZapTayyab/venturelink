import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/round_notifier.dart';
import '../../auth/domain/auth_notifier.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../core/constants/app_colors.dart';

class CreateRoundScreen extends ConsumerStatefulWidget {
  final String startupId;
  const CreateRoundScreen({super.key, required this.startupId});

  @override
  ConsumerState<CreateRoundScreen> createState() => _CreateRoundScreenState();
}

class _CreateRoundScreenState extends ConsumerState<CreateRoundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _minController = TextEditingController();
  DateTime? _deadline;

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _minController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      context.showSnackBar('Please select a deadline', isError: true);
      return;
    }

    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    try {
      await ref.read(roundFormNotifierProvider.notifier).createRound({
        'startupId': widget.startupId,
        'title': _titleController.text.trim(),
        'targetAmount': double.parse(_targetController.text),
        'minInvestment': double.parse(_minController.text),
        'deadline': _deadline!.toIso8601String(),
      });
      if (mounted) {
        context.showSnackBar('Funding round created!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          ref.read(roundFormNotifierProvider).error?.message ??
              'Failed to create round',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roundFormNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createRound)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxFormWidth),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Round Details', style: AppTextStyles.heading3),
                const SizedBox(height: AppSizes.lg),
                AppTextField(
                  label: AppStrings.roundTitle,
                  controller: _titleController,
                  validator: (v) => Validators.required(v, fieldName: 'Title'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  label: AppStrings.targetAmount,
                  controller: _targetController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (v) => Validators.positiveNumber(v, fieldName: 'Target amount'),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  label: AppStrings.minInvestment,
                  controller: _minController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (v) => Validators.positiveNumber(v, fieldName: 'Minimum investment'),
                ),
                const SizedBox(height: AppSizes.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text(AppStrings.deadline),
                  subtitle: Text(
                    _deadline != null
                        ? AppFormatters.date(_deadline!)
                        : 'Tap to select',
                    style: TextStyle(
                      color: _deadline != null ? null : Colors.grey,
                    ),
                  ),
                  onTap: _pickDeadline,
                  trailing: const Icon(Icons.chevron_right),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    side: const BorderSide(color: AppColors.grey300),
                  ),
                  tileColor: AppColors.white,
                ),
                const SizedBox(height: AppSizes.xl),
                AppButton(
                  label: 'Create Round',
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
