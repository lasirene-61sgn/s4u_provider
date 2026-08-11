import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../riverpod/handyman_earning_notifier.dart';
import '../model/handyman_earning_model.dart';

class HandymanEarningScreen extends ConsumerStatefulWidget {
  const HandymanEarningScreen({super.key});

  @override
  ConsumerState<HandymanEarningScreen> createState() => _HandymanEarningScreenState();
}

class _HandymanEarningScreenState extends ConsumerState<HandymanEarningScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(handymanEarningListProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    const bool isMobile = true;
    final state = ref.watch(handymanEarningListProvider);
    
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: isMobile ? null : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: isMobile ? [
                        Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Wrap(
                                spacing: 8, runSpacing: 8,
                                alignment: WrapAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                                    child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('Export', style: TextStyle(color: AppColors.textSecondary)), SizedBox(width: 8), Icon(Icons.download, size: 16, color: AppColors.textMuted)]),
                                  ),
                                ]
                              ),
                            ],
                          ),
                        ),
                      ] : [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Text('Export', style: TextStyle(color: AppColors.textSecondary)),
                                  SizedBox(width: 8),
                                  Icon(Icons.download, size: 16, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile) Container(
                    color: const Color(0xFF635BFF),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: const Row(
                      children: [
                        Expanded(child: Text('Handyman', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Pay Due', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Paid Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Total Earning', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        SizedBox(width: 80, child: Text('Action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Builder(builder: (context) {
                      if (state.isLoading && state.earnings.isEmpty) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      if (state.error != null) return Center(child: Text('Error: ${state.error}', style: const TextStyle(color: AppColors.textSecondary)));
                      if (state.earnings.isEmpty) return const Center(child: Text('No data available in table', style: TextStyle(color: AppColors.textSecondary)));
                      
                      return ListView.separated(
                        itemCount: state.earnings.length,
                        separatorBuilder: (context, index) => isMobile ? const SizedBox(height: 8) : const Divider(height: 1, color: AppColors.borderLight),
                        itemBuilder: (context, index) {
                          final item = state.earnings[index];
                          if (isMobile) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderLight),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(item.handymanName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark)),
                                      Text('Booking: ${item.bookingCount}', style: const TextStyle(color: AppColors.textSecondary)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Pay Due: ₹${item.payDue}', style: const TextStyle(color: AppColors.textSecondary)),
                                      Text('Paid: ₹${item.paidAmount}', style: const TextStyle(color: AppColors.textSecondary)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Total: ₹${item.totalEarning}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                                      const Icon(Icons.remove_red_eye_outlined, size: 20, color: AppColors.primary),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              children: [
                                Expanded(child: Text(item.handymanName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark))),
                                Expanded(child: Text(item.bookingCount, style: const TextStyle(color: AppColors.textSecondary))),
                                Expanded(child: Text('₹${item.payDue}', style: const TextStyle(color: AppColors.textSecondary))),
                                Expanded(child: Text('₹${item.paidAmount}', style: const TextStyle(color: AppColors.textSecondary))),
                                Expanded(child: Text('₹${item.totalEarning}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
                                const SizedBox(width: 80, child: Row(children: [Icon(Icons.remove_red_eye_outlined, size: 20, color: AppColors.primary)])),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  if (!isMobile) const Divider(height: 1, color: AppColors.borderLight),
                  if (!isMobile) Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 16.0,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('Show ', style: TextStyle(color: AppColors.textSecondary)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.borderLight),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('10', style: TextStyle(color: AppColors.textSecondary)),
                                  SizedBox(width: 8),
                                  Icon(Icons.unfold_more, size: 16, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                            const Text(' entries', style: TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(width: 16),
                            const Text('Showing 0 to 0 of 0 entries', style: TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: null, icon: const Icon(Icons.chevron_left)),
                            IconButton(onPressed: null, icon: const Icon(Icons.chevron_right)),
                          ],
                        ),
                      ],
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
