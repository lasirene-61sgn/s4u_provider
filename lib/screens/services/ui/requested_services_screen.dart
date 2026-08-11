import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/image_viewer.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../riverpod/service_notifier.dart';
import '../model/service_model.dart';
import 'service_form_screen.dart';

class RequestedServicesScreen extends ConsumerStatefulWidget {
  const RequestedServicesScreen({super.key});

  @override
  ConsumerState<RequestedServicesScreen> createState() => _RequestedServicesScreenState();
}

class _RequestedServicesScreenState extends ConsumerState<RequestedServicesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(serviceProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    const bool isMobile = true;
    final state = ref.watch(serviceProvider);

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
                        Expanded(flex: 2, child: Text('Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Provider', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Price', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Builder(builder: (context) {
                      if (state.isLoading && state.services.isEmpty) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF635BFF)));
                      }
                      if (state.error != null && state.services.isEmpty) {
                        return Center(child: Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)));
                      }
                      final list = state.services.where((s) => s.serviceStatus.trim().toUpperCase() == 'PENDING').toList();
                      if (list.isEmpty) {
                        return const Center(
                          child: Text('No data available in table', style: TextStyle(color: AppColors.textSecondary)),
                        );
                      }
                      return ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (c, i) => isMobile ? const SizedBox(height: 8) : const Divider(height: 1, color: AppColors.borderLight),
                        itemBuilder: (context, index) {
                          final s = list[index];
                          return _buildRow(context, ref, s);
                        },
                      );
                    }),
                  ),
                  if (!isMobile) const Divider(height: 1, color: AppColors.borderLight),
                  if (!isMobile) Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Show ', style: TextStyle(color: AppColors.textSecondary)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.borderLight),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Text('10', style: TextStyle(color: AppColors.textSecondary)),
                                  SizedBox(width: 8),
                                  Icon(Icons.unfold_more, size: 16, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                            const Text(' entries', style: TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(width: 16),
                            const Text('Showing 1 to 1 of 1 entries', style: TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(onPressed: null, icon: const Icon(Icons.chevron_left)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFF635BFF), borderRadius: BorderRadius.circular(4)),
                              child: const Text('1', style: TextStyle(color: Colors.white)),
                            ),
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

  Widget _buildRow(BuildContext context, WidgetRef ref, ServiceModel s) {
    const bool isMobile = true;
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
                Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF635BFF)))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: (s.status == 'APPROVED' ? Colors.green : (s.status == 'PENDING' ? Colors.orange : Colors.red)).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(s.status, style: TextStyle(color: s.status == 'APPROVED' ? Colors.green : (s.status == 'PENDING' ? Colors.orange : Colors.red), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (s.image != null && s.image!.isNotEmpty) {
                      ImageViewer.show(context, NetworkImage(s.image!));
                    }
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: s.image != null && s.image!.isNotEmpty ? NetworkImage(s.image!) : null,
                    child: s.image == null || s.image!.isEmpty ? const Icon(Icons.image, size: 16, color: AppColors.textMuted) : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.providerName?.isNotEmpty == true ? s.providerName! : 'N/A', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
                      if (s.providerEmail?.isNotEmpty == true) Text(s.providerEmail!, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Category: ${s.categoryName ?? 'N/A'}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Text('₹${s.price ?? 0.00}-${s.priceType}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
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
          const SizedBox(width: 40, child: Icon(Icons.check_box_outline_blank, color: AppColors.borderLight, size: 18)),
          Expanded(
            flex: 2,
            child: Text(s.name, style: const TextStyle(color: Color(0xFF635BFF), fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (s.image != null && s.image!.isNotEmpty) {
                      ImageViewer.show(context, NetworkImage(s.image!));
                    }
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: s.image != null && s.image!.isNotEmpty ? NetworkImage(s.image!) : null,
                    child: s.image == null || s.image!.isEmpty ? const Icon(Icons.image, size: 16, color: AppColors.textMuted) : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.providerName?.isNotEmpty == true ? s.providerName! : 'N/A',
                        style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (s.providerEmail?.isNotEmpty == true)
                        Text(
                          s.providerEmail!,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Text(s.categoryName ?? 'N/A', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Expanded(child: Text('₹${s.price ?? 0.00}-${s.priceType}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                s.status,
                style: TextStyle(
                  color: s.status == 'APPROVED' ? Colors.green : (s.status == 'PENDING' ? Colors.orange : Colors.red),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
