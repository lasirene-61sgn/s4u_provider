import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../riverpod/handyman_notifier.dart';

class UnassignedHandymanScreen extends ConsumerStatefulWidget {
  const UnassignedHandymanScreen({super.key});

  @override
  ConsumerState<UnassignedHandymanScreen> createState() => _UnassignedHandymanScreenState();
}

class _UnassignedHandymanScreenState extends ConsumerState<UnassignedHandymanScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(handymenProvider.notifier).loadMoreUnassigned();
      }
    });
    Future.microtask(() => ref.read(handymenProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bool isMobile = true;
    final state = ref.watch(handymenProvider);
    final unassigned = state.unassignedHandymen;

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

                  if (!isMobile) Container(
                    color: const Color(0xFF635BFF),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: const Row(
                      children: [
                        SizedBox(width: 40, child: Icon(Icons.check_box_outline_blank, color: Colors.white, size: 18)),
                        Expanded(child: Text('Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Joining Date', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Provider', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Contact Number', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Wallet Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        SizedBox(width: 80, child: Text('Action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Builder(builder: (context) {
                      if (state.isLoadingUnassigned) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }
                      if (state.error != null && unassigned.isEmpty) {
                        return Center(child: Text('Error: ${state.error}', style: const TextStyle(color: AppColors.textMuted)));
                      }
                      return unassigned.isEmpty
                          ? const Center(
                              child: Text('No data available in table', style: TextStyle(color: AppColors.textSecondary)),
                            )
                          : ListView.separated(
                              controller: _scrollController,
                              itemCount: unassigned.length + (state.isFetchingMoreUnassigned ? 1 : 0),
                              separatorBuilder: (context, index) => isMobile ? const SizedBox(height: 8) : const Divider(height: 1, color: AppColors.borderLight),
                              itemBuilder: (context, index) {
                                if (index == unassigned.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                  );
                                }
                                final h = unassigned[index];
                                final joinDate = h.createdAt != null && h.createdAt!.length >= 10
                                    ? h.createdAt!.substring(0, 10)
                                    : 'N/A';
                                
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
                                            Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark)),
                                            Text(joinDate, style: const TextStyle(color: AppColors.textSecondary)),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Mobile: ${h.mobile.isEmpty ? 'N/A' : h.mobile}', style: const TextStyle(color: AppColors.textSecondary)),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                h.status ?? 'UNASSIGNED',
                                                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Address: ${h.address.isEmpty ? 'N/A' : h.address}', style: const TextStyle(color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      Expanded(child: Text(joinDate, style: const TextStyle(color: AppColors.textSecondary))),
                                      const Expanded(child: Text('N/A', style: TextStyle(color: AppColors.textSecondary))), // Provider
                                      Expanded(child: Text(h.mobile.isEmpty ? 'N/A' : h.mobile, style: const TextStyle(color: AppColors.textSecondary))),
                                      Expanded(child: Text(h.address.isEmpty ? 'N/A' : h.address, style: const TextStyle(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      const Expanded(child: Text('₹0', style: TextStyle(color: AppColors.textSecondary))), // Wallet Amount
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            h.status ?? 'UNASSIGNED',
                                            style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 80, child: Row(children: [Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary)])),
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
