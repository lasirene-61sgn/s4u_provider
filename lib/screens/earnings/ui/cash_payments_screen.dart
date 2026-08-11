import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../riverpod/cash_payment_notifier.dart';

class CashPaymentsScreen extends ConsumerStatefulWidget {
  const CashPaymentsScreen({super.key});

  @override
  ConsumerState<CashPaymentsScreen> createState() => _CashPaymentsScreenState();
}

class _CashPaymentsScreenState extends ConsumerState<CashPaymentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(cashPaymentProvider.notifier).fetchCashPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    const bool isMobile = true;
    final state = ref.watch(cashPaymentProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cash Detail Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard('Today Cash', '₹${state.todayCash}', Icons.today, Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard('Total Cash in Hand', '₹${state.totalCashInHand}', Icons.account_balance_wallet, Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Cash Payments List
          Expanded(
            child: Container(
              decoration: isMobile ? null : BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
              child: Column(
                children: [
                  if (!isMobile) Container(
                    color: const Color(0xFF635BFF),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: const Row(
                      children: [
                        Expanded(child: Text('Booking ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Method', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Date', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state.isLoading && state.payments.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state.error != null && state.payments.isEmpty) {
                          return Center(child: Text('Error: ${state.error}', style: const TextStyle(color: AppColors.textSecondary)));
                        }
                        if (state.payments.isEmpty) {
                          return const Center(child: Text('No cash payments found', style: TextStyle(color: AppColors.textSecondary)));
                        }
                        
                        return ListView.separated(
                          itemCount: state.payments.length,
                          separatorBuilder: (_, __) => isMobile ? const SizedBox(height: 8) : const Divider(height: 1, color: AppColors.borderLight),
                          itemBuilder: (context, index) {
                            final p = state.payments[index];
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
                                        Text('Booking #${p.bookingId}', style: const TextStyle(color: Color(0xFF635BFF), fontSize: 16, fontWeight: FontWeight.bold)),
                                        Text('₹${p.totalAmount}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.success)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(p.customerName.isNotEmpty ? p.customerName : 'Unknown Customer', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.payment_outlined, size: 16, color: AppColors.textSecondary),
                                        const SizedBox(width: 8),
                                        Text(p.paymentMethod.isNotEmpty ? p.paymentMethod : '-', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                          child: Text(p.paymentStatus.isNotEmpty ? p.paymentStatus : '-', style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                                        const SizedBox(width: 8),
                                        Text(p.date.split(' ').first, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
                                  Expanded(child: Text('#${p.bookingId}', style: const TextStyle(fontSize: 13))),
                                  Expanded(flex: 2, child: Text(p.customerName.isNotEmpty ? p.customerName : '-', style: const TextStyle(fontSize: 13))),
                                  Expanded(child: Text(p.paymentMethod.isNotEmpty ? p.paymentMethod : '-', style: const TextStyle(fontSize: 13))),
                                  Expanded(child: Text('₹${p.totalAmount}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                                  Expanded(child: Text(p.paymentStatus.isNotEmpty ? p.paymentStatus : '-', style: const TextStyle(fontSize: 13, color: AppColors.success))),
                                  Expanded(child: Text(p.date.split(' ').first, style: const TextStyle(fontSize: 13, color: AppColors.textMuted))),
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

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
