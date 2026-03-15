import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/investment_notifier.dart';
import '../../auth/domain/auth_notifier.dart';
import '../../funding_rounds/domain/round_notifier.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/formatters.dart';
import '../../../services/blockchain_service.dart';
import '../../../shared/models/funding_round_model.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_view.dart';
import 'package:uuid/uuid.dart';

class InvestScreen extends ConsumerStatefulWidget {
  final String startupId;
  final String roundId;

  const InvestScreen({
    super.key,
    required this.startupId,
    required this.roundId,
  });

  @override
  ConsumerState<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends ConsumerState<InvestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  BlockchainReceipt? _receipt;
  String _statusMessage = '';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _invest(FundingRoundModel round) async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text);
    if (amount < round.minInvestment) {
      context.showSnackBar(
        'Minimum investment is ${AppFormatters.currency(round.minInvestment)}',
        isError: true,
      );
      return;
    }

    final confirmed = await context.showConfirmDialog(
      title: 'Confirm Investment',
      content:
          'Invest ${AppFormatters.currency(amount)} in ${round.startupName}?\n\nThis will be recorded on the Ethereum blockchain.',
      confirmText: 'Confirm & Invest',
    );
    if (confirmed != true || !mounted) return;

    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Processing investment...';
    });

    try {
      final investmentId = const Uuid().v4();

      // Step 1 - Record in Firestore via Cloud Function
      setState(() => _statusMessage = '📝 Recording investment...');
      await ref.read(investFormNotifierProvider.notifier).invest({
        'roundId': widget.roundId,
        'startupId': widget.startupId,
        'amount': amount,
        'investmentId': investmentId,
      });

      // Step 2 - Record on Blockchain
      setState(() => _statusMessage = '⛓️ Writing to blockchain...');
      final receipt = await BlockchainService.recordInvestment(
        investmentId: investmentId,
        investorId: user.uid,
        startupId: widget.startupId,
        roundId: widget.roundId,
        amountUsd: amount,
      );

      setState(() {
        _receipt = receipt;
        _isLoading = false;
        _statusMessage = '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '';
      });
      if (mounted) {
        context.showSnackBar(
          ref.read(investFormNotifierProvider).error?.message ??
              'Investment failed',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roundAsync = ref.watch(roundDetailProvider(widget.roundId));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: roundAsync.when(
            loading: () => const Center(child: LoadingIndicator(color: Colors.white)),
            error: (e, _) => ErrorView(message: e.toString()),
            data: (round) {
              if (round == null) {
                return const ErrorView(message: 'Round not found');
              }
              final r = round as FundingRoundModel;
              return _receipt != null
                  ? _SuccessView(receipt: _receipt!, round: r)
                  : _InvestForm(
                      round: r,
                      amountController: _amountController,
                      formKey: _formKey,
                      isLoading: _isLoading,
                      statusMessage: _statusMessage,
                      onInvest: () => _invest(r),
                    );
            },
          ),
        ),
      ),
    );
  }
}

class _InvestForm extends StatelessWidget {
  final FundingRoundModel round;
  final TextEditingController amountController;
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final String statusMessage;
  final VoidCallback onInvest;

  const _InvestForm({
    required this.round,
    required this.amountController,
    required this.formKey,
    required this.isLoading,
    required this.statusMessage,
    required this.onInvest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App bar
        Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Invest',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                // Round info card
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            round.startupName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            round.title,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: AppSizes.md),
                          LinearProgressIndicator(
                            value: round.progressPercent / 100,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.accentGreen),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppFormatters.currencyCompact(round.raisedAmount),
                                style: const TextStyle(
                                  color: AppColors.accentGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${round.progressPercent.toStringAsFixed(0)}% of ${AppFormatters.currencyCompact(round.targetAmount)}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _MiniStat(
                                  'Min Investment',
                                  AppFormatters.currencyCompact(
                                      round.minInvestment)),
                              _MiniStat('Deadline',
                                  AppFormatters.date(round.deadline)),
                              _MiniStat(
                                  'Investors', '${round.investorCount}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                // Blockchain badge
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    gradient: AppColors.blockchainGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.link, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Blockchain Protected',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Your investment is recorded immutably on Ethereum Sepolia',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                // Amount input
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (v) =>
                        Validators.positiveNumber(v, fieldName: 'Amount'),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Investment Amount (USD)',
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.attach_money,
                          color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusLg),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusLg),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusLg),
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2),
                      ),
                      errorStyle: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                if (isLoading)
                  Column(
                    children: [
                      const LoadingIndicator(color: Colors.white),
                      const SizedBox(height: 12),
                      Text(statusMessage,
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  )
                else
                  GradientButton(
                    label: 'Confirm Investment',
                    gradient: AppColors.greenGradient,
                    icon: Icons.trending_up_rounded,
                    onPressed: onInvest,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label,
            style:
                TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final BlockchainReceipt receipt;
  final FundingRoundModel round;

  const _SuccessView({required this.receipt, required this.round});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.greenGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGreen.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 56),
          ),
          const SizedBox(height: AppSizes.lg),
          const Text(
            'Investment Confirmed! 🎉',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your investment in ${round.startupName} has been recorded.',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xl),
          // Blockchain receipt card
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.blockchainGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.link,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Blockchain Receipt',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        if (receipt.isMock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Demo',
                                style: TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: AppSizes.sm),
                    _ReceiptRow('Network', receipt.network),
                    _ReceiptRow('Amount',
                        AppFormatters.currency(receipt.amountUsd)),
                    _ReceiptRow('TX Hash', receipt.shortHash),
                    _ReceiptRow('Time',
                        AppFormatters.dateTime(receipt.timestamp)),
                    const SizedBox(height: AppSizes.md),
                    // Copy hash button
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: receipt.txHash));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('TX Hash copied!'),
                            backgroundColor: AppColors.accentGreen,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.copy,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                receipt.txHash,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          GradientButton(
            label: 'Done',
            gradient: AppColors.primaryGradient,
            onPressed: () {
              context.go('/dashboard');
            },
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReceiptRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}