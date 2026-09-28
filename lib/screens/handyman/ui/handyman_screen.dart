import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// keeping line 3 empty

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/image_viewer.dart';
import '../riverpod/handyman_notifier.dart';
import '../model/handyman_model.dart';
import 'handyman_form_screen.dart';
import 'handyman_detail_screen.dart';

const _purple = AppColors.primary; 
const _dark = AppColors.primaryDark;
const _grey = AppColors.textMuted;
const _purpleLight = AppColors.bgLighterPurple;

class HandymanScreen extends ConsumerStatefulWidget {
  const HandymanScreen({super.key});

  @override
  ConsumerState<HandymanScreen> createState() => _HandymanScreenState();
}

class _HandymanScreenState extends ConsumerState<HandymanScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(handymenProvider.notifier).loadMore();
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
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const HandymanFormScreen()),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Handyman'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF635BFF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Builder(builder: (context) {
                    final showJoiningDate = state.handymen.any((h) => h.approvedDate != null && h.approvedDate!.isNotEmpty);
                    final showAddress = state.handymen.any((h) => h.address.isNotEmpty);
                    if (isMobile) return const SizedBox.shrink();
                    return Container(
                      color: const Color(0xFF635BFF),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const SizedBox(width: 40, child: Icon(Icons.check_box_outline_blank, color: Colors.white, size: 18)),
                          const Expanded(flex: 2, child: Text('Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                          if (showJoiningDate) const Expanded(child: Text('Joining Date', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                          const Expanded(flex: 2, child: Text('Provider', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                          const Expanded(child: Text('Contact Number', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                          if (showAddress) const Expanded(child: Text('Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                          const Expanded(child: Text('Wallet Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                          const Expanded(child: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                          const SizedBox(width: 80, child: Text('Action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        ],
                      ),
                    );
                  }),
                  Expanded(
                    child: Builder(builder: (context) {
                      if (state.isLoading && state.handymen.isEmpty) return const Center(child: CircularProgressIndicator(color: _purple));
                      if (state.error != null && state.handymen.isEmpty) {
                        return Center(child: Text('Error: ${state.error}', style: const TextStyle(color: _grey)));
                      }
                      final list = state.handymen;
                      if (list.isEmpty) {
                        return const Center(
                          child: Text('No data available in table', style: TextStyle(color: AppColors.textSecondary)),
                        );
                      }
                      final showJoiningDate = list.any((h) => h.approvedDate != null && h.approvedDate!.isNotEmpty);
                      final showAddress = list.any((h) => h.address.isNotEmpty);
                      
                      return ListView.separated(
                        controller: _scrollController,
                        itemCount: list.length + (state.isFetchingMore ? 1 : 0),
                        separatorBuilder: (c, i) => isMobile ? const SizedBox(height: 8) : const Divider(height: 1, color: AppColors.borderLight),
                        itemBuilder: (c, i) {
                          if (i == list.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                            );
                          }
                          final h = list[i];
                          return _HandymanTableRow(
                            handyman: h,
                            showJoiningDate: showJoiningDate,
                            showAddress: showAddress,
                            editingId: state.editingId,
                            onEdit: () async {
                              final success = await ref.read(handymenProvider.notifier).fetchHandymanDetail(h.id);
                              if (success && context.mounted) {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => HandymanFormScreen(handyman: h)));
                              }
                            },
                            onDelete: () => _showDeleteDialog(context, ref, h),
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
                            Text('Showing ${state.handymen.isNotEmpty ? 1 : 0} to ${state.handymen.length} of ${state.handymen.length} entries', style: const TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(onPressed: null, icon: const Icon(Icons.chevron_left)),
                            if (state.handymen.isNotEmpty)
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

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Handyman handyman) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Consumer(
        builder: (context, ref, _) {
          final isDeleting = ref.watch(handymenProvider).deletingId == handyman.id;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
                SizedBox(width: 10),
                Text('Delete Member', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ],
            ),
            content: Text(
              'Are you sure you want to delete "${handyman.name}"?', 
              style: const TextStyle(color: _grey, fontSize: 14, height: 1.5)
            ),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => Navigator.pop(c), 
                child: const Text('Cancel', style: TextStyle(color: _grey, fontWeight: FontWeight.w600))
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: isDeleting ? null : () async {
                  await ref.read(handymenProvider.notifier).deleteHandyman(handyman.id);
                  if (context.mounted) Navigator.pop(c);
                },
                child: isDeleting 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      ),
    );
  }
}

class _HandymanTableRow extends StatelessWidget {
  
  final Handyman handyman;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showJoiningDate;
  final bool showAddress;
  final int editingId;

  const _HandymanTableRow({
    required this.handyman,
    required this.onEdit,
    required this.onDelete,
    required this.showJoiningDate,
    required this.showAddress,
    required this.editingId,
  });

  Color get _statusColor {
    switch (handyman.status) {
      case 'ACTIVE': return Colors.green;
      case 'INACTIVE': return Colors.orange;
      case 'PENDING': return Colors.blue;
      default: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final img = handyman.profileImage != null && handyman.profileImage!.isNotEmpty ? NetworkImage(handyman.profileImage!) : const AssetImage('assets/s4u_logo.jpeg') as ImageProvider;
                          ImageViewer.show(context, img);
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: handyman.profileImage != null && handyman.profileImage!.isNotEmpty ? NetworkImage(handyman.profileImage!) : const AssetImage('assets/s4u_logo.jpeg') as ImageProvider, // Replace with network image if available
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(handyman.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(handyman.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(handyman.status ?? 'PENDING', style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(handyman.mobile ?? 'N/A', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
            if (showAddress && handyman.address.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(handyman.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ],
            if (showJoiningDate && handyman.approvedDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(handyman.approvedDate!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => HandymanDetailScreen(handymanId: handyman.id)));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.bgLighterPurple, foregroundColor: AppColors.primary, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  icon: const Icon(Icons.visibility_outlined, size: 16), label: const Text('View'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.bgLighterPurple, foregroundColor: AppColors.primary, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1), foregroundColor: Colors.red, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  icon: const Icon(Icons.delete_outline, size: 16), label: const Text('Delete'),
                ),
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
          const SizedBox(width: 40, child: Icon(Icons.check_box_outline_blank, color: AppColors.textMuted, size: 18)),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (handyman.profileImage != null && handyman.profileImage!.isNotEmpty) {
                      ImageViewer.show(context, NetworkImage(handyman.profileImage!));
                    }
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: _purpleLight,
                    backgroundImage: handyman.profileImage != null && handyman.profileImage!.isNotEmpty 
                        ? NetworkImage(handyman.profileImage!) 
                        : null,
                    child: handyman.profileImage == null || handyman.profileImage!.isEmpty
                        ? Text(handyman.name.isNotEmpty ? handyman.name[0].toUpperCase() : 'H', style: const TextStyle(fontSize: 14, color: _purple, fontWeight: FontWeight.bold))
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(handyman.name, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(handyman.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showJoiningDate) Expanded(child: Builder(builder: (_) {
            final date = handyman.approvedDate;
            String joinDate = '-';
            if (date != null && date.length >= 10) {
              try {
                final dt = DateTime.parse(date);
                final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                joinDate = '${months[dt.month - 1]} ${dt.day},\n${dt.year}\n${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')} ${dt.hour < 12 ? 'AM' : 'PM'}';
              } catch (_) {
                joinDate = date.substring(0, 10);
              }
            }
            return Text(joinDate, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12));
          })),
          const Expanded(flex: 2, child: Text('-', style: TextStyle(color: AppColors.textSecondary))), // Provider Name (Not in UI, so just dash)
          Expanded(child: Text(handyman.mobile.isNotEmpty ? handyman.mobile : '-', style: const TextStyle(color: AppColors.textSecondary))),
          if (showAddress) Expanded(child: Text(handyman.address.isNotEmpty ? handyman.address : '-', style: const TextStyle(color: AppColors.textSecondary))),
          const Expanded(child: Text('₹0.00', style: TextStyle(color: AppColors.textSecondary))),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(handyman.status ?? 'UNKNOWN', style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(
            width: 130,
            child: Row(
              children: [
                Tooltip(
                  message: 'View',
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => HandymanDetailScreen(handymanId: handyman.id)));
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _purpleLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.visibility_outlined, size: 16, color: _purple),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Edit',
                  child: InkWell(
                    onTap: editingId == handyman.id ? () {} : onEdit,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _purpleLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: editingId == handyman.id
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: _purple, strokeWidth: 2))
                          : const Icon(Icons.edit_outlined, size: 16, color: _purple),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Delete',
                  child: InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




