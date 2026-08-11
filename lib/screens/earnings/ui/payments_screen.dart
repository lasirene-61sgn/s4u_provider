import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../riverpod/payment_notifier.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  final bool cashOnly;
  const PaymentsScreen({super.key, this.cashOnly = false});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(paymentProvider.notifier).fetchPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    const bool isMobile = true;
    final paymentState = ref.watch(paymentProvider);

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
                        if (paymentState.isLoading && paymentState.payments.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (paymentState.error != null && paymentState.payments.isEmpty) {
                          return Center(child: Text('Error: ${paymentState.error}', style: const TextStyle(color: AppColors.textSecondary)));
                        }

                        final filtered = widget.cashOnly 
                          ? paymentState.payments.where((p) => p.paymentMethod.toUpperCase().contains('CASH') || p.paymentMethod.toUpperCase() == 'COD').toList() 
                          : paymentState.payments;
                          
                        if (filtered.isEmpty) {
                          return const Center(child: Text('No payments found', style: TextStyle(color: AppColors.textSecondary)));
                        }
                        
                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => isMobile ? const SizedBox(height: 8) : const Divider(height: 1, color: AppColors.borderLight),
                          itemBuilder: (context, index) {
                            final p = filtered[index];
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
}
