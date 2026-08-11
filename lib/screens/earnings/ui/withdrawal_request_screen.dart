import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../riverpod/payout_notifier.dart';
import '../../provider_info/riverpod/bank_notifier.dart';
import '../../provider_info/model/bank_model.dart';

class WithdrawalRequestScreen extends ConsumerStatefulWidget {
  const WithdrawalRequestScreen({super.key});

  @override
  ConsumerState<WithdrawalRequestScreen> createState() => _WithdrawalRequestScreenState();
}

class _WithdrawalRequestScreenState extends ConsumerState<WithdrawalRequestScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(payoutProvider.notifier).fetchPayouts();
      ref.read(bankProvider.notifier).fetchBanks();
    });
  }

  @override
  Widget build(BuildContext context) {
    const bool isMobile = true;
    final state = ref.watch(payoutProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: isMobile ? null : BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showWithdrawDialog(context, ref),
                          icon: const Icon(Icons.account_balance_wallet),
                          label: const Text('Request Payout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile) Container(
                    color: const Color(0xFF635BFF),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: const Row(
                      children: [
                        Expanded(child: Text('ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Description', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Method', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Date', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state.isLoading && state.payouts.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state.error != null && state.payouts.isEmpty) {
                          return Center(child: Text('Error: ${state.error}', style: const TextStyle(color: AppColors.textSecondary)));
                        }
                        if (state.payouts.isEmpty) {
                          return const Center(child: Text('No payout requests found', style: TextStyle(color: AppColors.textSecondary)));
                        }
                        
                        return ListView.separated(
                          itemCount: state.payouts.length,
                          separatorBuilder: (_, __) => isMobile ? const SizedBox(height: 8) : const Divider(height: 1, color: AppColors.borderLight),
                          itemBuilder: (context, index) {
                            final p = state.payouts[index];
                            if (isMobile) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.borderLight),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Payout #${p.id}', style: const TextStyle(color: Color(0xFF635BFF), fontSize: 16, fontWeight: FontWeight.bold)),
                                        Text('₹${p.amount}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.account_balance, size: 16, color: AppColors.textSecondary),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(p.paymentMethod.toUpperCase(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold))),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.description_outlined, size: 16, color: AppColors.textSecondary),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(p.description.isNotEmpty ? p.description : '-', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                                        const SizedBox(width: 8),
                                        Text(p.createdAt.split('T').first, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(child: Text('#${p.id}', style: const TextStyle(fontSize: 13))),
                                  Expanded(flex: 2, child: Text(p.description.isNotEmpty ? p.description : '-', style: const TextStyle(fontSize: 13))),
                                  Expanded(child: Text(p.paymentMethod.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                                  Expanded(child: Text('₹${p.amount}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                                  Expanded(child: Text(p.createdAt.split('T').first, style: const TextStyle(fontSize: 13, color: AppColors.textMuted))),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => const _RequestPayoutDialog(),
    );
  }
}

class _RequestPayoutDialog extends ConsumerStatefulWidget {
  const _RequestPayoutDialog();

  @override
  ConsumerState<_RequestPayoutDialog> createState() => _RequestPayoutDialogState();
}

class _RequestPayoutDialogState extends ConsumerState<_RequestPayoutDialog> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _paymentMethod = 'bank';
  BankModel? _selectedBank;

  @override
  Widget build(BuildContext context) {
    final bankState = ref.watch(bankProvider);
    final payoutState = ref.watch(payoutProvider);

    final inputDeco = InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        width: 400,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                const Text('Request Payout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textPrimary)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Amount', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              decoration: inputDeco.copyWith(
                prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.textMuted),
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              decoration: inputDeco,
              items: const [
                DropdownMenuItem(value: 'bank', child: Text('Bank Transfer', style: TextStyle(fontWeight: FontWeight.w500))),
                DropdownMenuItem(value: 'wallet', child: Text('Digital Wallet', style: TextStyle(fontWeight: FontWeight.w500))),
                DropdownMenuItem(value: 'cash', child: Text('Cash', style: TextStyle(fontWeight: FontWeight.w500))),
              ],
              onChanged: (val) {
                setState(() {
                  _paymentMethod = val!;
                });
              },
            ),
            if (_paymentMethod == 'bank') ...[
              const SizedBox(height: 20),
              const Text('Select Bank', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              if (bankState.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)))
              else if (bankState.banks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade100)),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(child: Text('No banks available. Please add a bank first.', style: TextStyle(color: Colors.red, fontSize: 12))),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<BankModel>(
                  value: _selectedBank,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  decoration: inputDeco,
                  hint: const Text('Select a bank'),
                  items: bankState.banks.map((b) => DropdownMenuItem(value: b, child: Text('${b.bankName} - ${b.accountNo}'))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedBank = val;
                    });
                  },
                ),
            ],
            const SizedBox(height: 20),
            const Text('Description (Optional)', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              decoration: inputDeco.copyWith(hintText: 'e.g. Weekly withdrawal'),
              maxLines: 2,
            ),
            if (payoutState.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(payoutState.error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: payoutState.isSubmitting ? null : () async {
                  if (_amountCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
                    return;
                  }
                  if (_paymentMethod == 'bank' && _selectedBank == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a bank')));
                    return;
                  }
                  
                  final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid amount')));
                    return;
                  }

                  await ref.read(payoutProvider.notifier).requestPayout(amount, _paymentMethod, _selectedBank?.id ?? 0, _descCtrl.text);
                  if (mounted && ref.read(payoutProvider).error == null) {
                    Navigator.pop(context);
                  }
                },
                child: payoutState.isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
