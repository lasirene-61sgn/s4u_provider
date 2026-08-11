import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/image_viewer.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../riverpod/handyman_notifier.dart';

class HandymanRequestScreen extends ConsumerStatefulWidget {
  const HandymanRequestScreen({super.key});

  @override
  ConsumerState<HandymanRequestScreen> createState() => _HandymanRequestScreenState();
}

class _HandymanRequestScreenState extends ConsumerState<HandymanRequestScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(handymenProvider.notifier).loadMorePending();
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
    final pendingHandymen = state.pendingHandymen;

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
                        Expanded(child: Text('Joining Date', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Contact Number', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('City', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        SizedBox(width: 100, child: Text('Action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Builder(builder: (context) {
                      if (state.isLoadingPending && state.pendingHandymen.isEmpty) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }
                      if (state.error != null && pendingHandymen.isEmpty) {
                        return Center(child: Text('Error: ${state.error}', style: const TextStyle(color: AppColors.textMuted)));
                      }
                      return pendingHandymen.isEmpty
                          ? const Center(
                              child: Text('No data available in table', style: TextStyle(color: AppColors.textSecondary)),
                            )
                          : ListView.separated(
                              controller: _scrollController,
                              itemCount: pendingHandymen.length + (state.isFetchingMorePending ? 1 : 0),
                              separatorBuilder: (context, index) => isMobile ? const SizedBox(height: 8) : const Divider(height: 1, color: AppColors.borderLight),
                              itemBuilder: (context, index) {
                                if (index == pendingHandymen.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                  );
                                }
                                final h = pendingHandymen[index];
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
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (h.profileImage != null) ImageViewer.show(context, NetworkImage(h.profileImage!));
                                                      },
                                                      child: CircleAvatar(
                                                        radius: 20,
                                                        backgroundImage: h.profileImage != null ? NetworkImage(h.profileImage!) : null,
                                                        child: h.profileImage == null ? const Icon(Icons.person, size: 20) : null,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                          Text(h.email.isEmpty ? 'N/A' : h.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  h.status ?? 'PENDING',
                                                  style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                                              const SizedBox(width: 8),
                                              Text(h.mobile.isEmpty ? 'N/A' : h.mobile, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                                              const SizedBox(width: 8),
                                              Expanded(child: Text(h.city.isEmpty ? 'N/A' : h.city, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500))),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                                              const SizedBox(width: 8),
                                              Text(joinDate, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          const Divider(height: 1, color: AppColors.borderLight),
                                          const SizedBox(height: 16),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: state.approvingId == h.id
                                                ? const Padding(padding: EdgeInsets.only(right: 16, bottom: 8), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))
                                                : ElevatedButton(
                                                    onPressed: () {
                                                      ref.read(handymenProvider.notifier).approveHandyman(h.id);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.green,
                                                      foregroundColor: Colors.white,
                                                    ),
                                                    child: const Text('Approve'),
                                                  ),
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
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  if (h.profileImage != null) ImageViewer.show(context, NetworkImage(h.profileImage!));
                                                },
                                                child: CircleAvatar(
                                                  radius: 16,
                                                  backgroundImage: h.profileImage != null ? NetworkImage(h.profileImage!) : null,
                                                  child: h.profileImage == null ? const Icon(Icons.person, size: 16) : null,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(child: Text(h.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                                            ],
                                          )
                                        ),
                                        Expanded(child: Text(joinDate, style: const TextStyle(color: AppColors.textSecondary))),
                                        Expanded(flex: 2, child: Text(h.email.isEmpty ? 'N/A' : h.email, style: const TextStyle(color: AppColors.textSecondary))),
                                        Expanded(child: Text(h.mobile.isEmpty ? 'N/A' : h.mobile, style: const TextStyle(color: AppColors.textSecondary))),
                                        Expanded(child: Text(h.city.isEmpty ? 'N/A' : h.city, style: const TextStyle(color: AppColors.textSecondary))),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              h.status ?? 'PENDING',
                                              style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              state.approvingId == h.id 
                                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                                                : ElevatedButton(
                                                    onPressed: () {
                                                      ref.read(handymenProvider.notifier).approveHandyman(h.id);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.green,
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    ),
                                                    child: const Text('Approve'),
                                                  ),
                                            ],
                                          ),
                                        ),
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
                            Text('Showing 1 to ${pendingHandymen.length} of ${pendingHandymen.length} entries', style: const TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                        Row(
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
