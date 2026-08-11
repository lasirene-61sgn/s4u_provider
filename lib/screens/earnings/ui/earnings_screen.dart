import 'package:flutter/material.dart';
import '../../../core/widgets/provider_top_bar.dart';
import '../../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../riverpod/earnings_notifier.dart';
import '../model/earnings_model.dart';
import '../../../core/api/api_client.dart';

// --- UI ---
class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(earningsProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(earningsProvider);

    if (state.error != null && state.earnings == null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    final data = state.earnings ?? Earnings();

    return Column(
      children: [
        const ProviderTopBar(
          title: 'Earnings',
          subtitle: 'Track your revenue and financial overview',
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 800
                            ? 3
                            : (constraints.maxWidth > 500 ? 2 : 1);
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: crossAxisCount == 1 ? 2.2 : 1.3,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          children: [
                            _EarningsCard(
                              title: 'Today',
                              value: '\$${data.today}',
                              color: const Color(0xFF3B82F6),
                              icon: Icons.today_rounded,
                              delay: 0,
                            ),
                            _EarningsCard(
                              title: 'This Month',
                              value: '\$${data.thisMonth}',
                              color: AppColors.warning,
                              icon: Icons.calendar_month_rounded,
                              delay: 100,
                            ),
                            _EarningsCard(
                              title: 'Total Earnings',
                              value: '\$${data.total}',
                              color: AppColors.success,
                              icon: Icons.account_balance_rounded,
                              delay: 200,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showWithdrawDialog(context),
                          icon: const Icon(Icons.account_balance_wallet),
                          label: const Text('Withdraw Funds'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 800 ? 16 : 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: data.transactions.isEmpty
                          ? const Center(
                              child: Text(
                                'No recent transactions available.',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.transactions.length,
                              separatorBuilder: (context, index) => const Divider(height: 32, color: AppColors.borderLight),
                              itemBuilder: (context, index) {
                                final txn = data.transactions[index];
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Booking #${txn.bookingId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text('Date: ${txn.date.split('T').first}', style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('+ ₹${txn.providerEarning.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.success)),
                                        const SizedBox(height: 4),
                                        Text('Total: ₹${txn.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    final amountCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Funds', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Amount'),
            const SizedBox(height: 8),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.currency_rupee)),
            ),
            const SizedBox(height: 16),
            const Text('Payment Details (Bank, UPI)'),
            const SizedBox(height: 8),
            TextField(
              controller: detailsCtrl,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              if (amountCtrl.text.isEmpty || detailsCtrl.text.isEmpty) return;
              try {
                await ApiClient().post(endpoint: '/withdraw-requests', body: {
                  'amount': double.tryParse(amountCtrl.text) ?? 0.0,
                  'paymentDetails': detailsCtrl.text,
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdraw request submitted successfully!')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final String title, value;
  final Color color;
  final IconData icon;
  final int delay;
  const _EarningsCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate(delay: delay.ms)
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
  }
}
