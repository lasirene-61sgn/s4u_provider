import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/image_viewer.dart';
import 'add_promotional_banner_screen.dart';
import '../riverpod/promotional_banner_notifier.dart';

class ProviderPromotionalBannerScreen extends ConsumerStatefulWidget {
  const ProviderPromotionalBannerScreen({super.key});

  @override
  ConsumerState<ProviderPromotionalBannerScreen> createState() => _ProviderPromotionalBannerScreenState();
}

class _ProviderPromotionalBannerScreenState extends ConsumerState<ProviderPromotionalBannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(promotionalBannerProvider.notifier).fetchAllBanners();
    });
  }

  @override
  Widget build(BuildContext context) {
    const bool isMobile = true;
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
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPromotionalBannerScreen()));
                                    },
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Add New'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF635BFF),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
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
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPromotionalBannerScreen()));
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add New'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF635BFF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                        SizedBox(width: 40, child: Icon(Icons.check_box_outline_blank, color: Colors.white, size: 18)),
                        Expanded(flex: 1, child: Text('ID  ↓ ↑', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Banner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Date Range  ↓ ↑', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 1, child: Text('Type  ↓ ↑', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 1, child: Text('Status  ↓ ↑', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Service ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        SizedBox(width: 80, child: Text('Action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildBannerList(),
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
                            const Text('Showing 0 to 0 of 0 entries', style: TextStyle(color: AppColors.textMuted)),
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

  Widget _buildBannerList() {
    final state = ref.watch(promotionalBannerProvider);
    const bool isMobile = true;

    if (state.isFetching && state.banners.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text(state.error!, style: const TextStyle(color: Colors.red)));
    }

    if (state.banners.isEmpty) {
      return const Center(
        child: Text('No banners available in table', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.separated(
      itemCount: state.banners.length,
      separatorBuilder: (context, index) => isMobile ? const SizedBox(height: 8) : const Divider(height: 1, color: AppColors.borderLight),
      itemBuilder: (context, index) {
        final banner = state.banners[index];
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
                    if (banner.bannerAttachment != null && banner.bannerAttachment!.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          if (banner.bannerAttachment != null && banner.bannerAttachment!.isNotEmpty) {
                            ImageViewer.show(context, NetworkImage(banner.bannerAttachment!));
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(image: NetworkImage(banner.bannerAttachment!), fit: BoxFit.cover),
                          ),
                          child: banner.bannerAttachment!.isEmpty ? const Icon(Icons.image, color: Colors.grey) : null,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        banner.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: (banner.status == 'ACTIVE' ? Colors.green : Colors.red).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(banner.status, style: TextStyle(color: banner.status == 'ACTIVE' ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text('${banner.startDate ?? ''} to ${banner.endDate ?? ''}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.label_outline, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(banner.bannerType ?? '-', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddPromotionalBannerScreen(banner: banner)));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.bgLighterPurple, foregroundColor: AppColors.primary, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    state.deletingBannerId == banner.id 
                        ? const SizedBox(width: 32, height: 32, child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)))
                        : ElevatedButton.icon(
                            onPressed: () {
                              _showDeleteConfirm(context, banner.id!);
                            },
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
              Expanded(flex: 1, child: Text(banner.id?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.w500))),
              Expanded(
                flex: 2, 
                child: Row(
                  children: [
                    if (banner.bannerAttachment != null && banner.bannerAttachment!.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          if (banner.bannerAttachment != null && banner.bannerAttachment!.isNotEmpty) {
                            ImageViewer.show(context, NetworkImage(banner.bannerAttachment!));
                          }
                        },
                        child: Container(
                          width: 30, height: 30, margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            image: DecorationImage(image: NetworkImage(banner.bannerAttachment!), fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    Expanded(child: Text(banner.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500))),
                  ]
                )
              ),
              Expanded(flex: 2, child: Text('${banner.startDate ?? ''} to ${banner.endDate ?? ''}', style: const TextStyle(color: AppColors.textSecondary))),
              Expanded(flex: 1, child: Text(banner.bannerType ?? '-', style: const TextStyle(fontWeight: FontWeight.w500))),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: banner.status == 'ACTIVE' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    banner.status,
                    style: TextStyle(
                      color: banner.status == 'ACTIVE' ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Expanded(flex: 2, child: Text(banner.serviceId ?? '-', style: const TextStyle(color: AppColors.textSecondary))),
              SizedBox(
                width: 80,
                child: Row(
                  children: [
                    InkWell(onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddPromotionalBannerScreen(banner: banner)));
                    }, child: const Icon(Icons.edit, size: 18, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    state.deletingBannerId == banner.id
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : InkWell(
                            onTap: () {
                              _showDeleteConfirm(context, banner.id!);
                            }, 
                            child: const Icon(Icons.delete, size: 18, color: Colors.red)
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Banner'),
        content: const Text('Are you sure you want to delete this promotional banner?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(promotionalBannerProvider.notifier).deleteBanner(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
