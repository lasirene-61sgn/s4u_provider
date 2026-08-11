import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/image_viewer.dart';
import '../riverpod/service_detail_notifier.dart';

class ServiceDetailScreen extends StatelessWidget {
  final int serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        serviceIdProvider.overrideWithValue(serviceId),
      ],
      child: const _ServiceDetailScreenContent(),
    );
  }
}

class _ServiceDetailScreenContent extends ConsumerWidget {
  const _ServiceDetailScreenContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(serviceDetailNotifierProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Service Detail'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDark,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(state.error!, style: const TextStyle(color: Colors.red, fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(serviceDetailNotifierProvider.notifier).retry();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final detailModel = state.detail;
    final service = detailModel?.serviceDetail;
    final provider = detailModel?.provider;
    final addons = detailModel?.serviceAddon ?? [];
    final relatedServices = detailModel?.relatedService ?? [];
    
    final hasImages = service?.image != null && service!.image!.isNotEmpty;
    final imageUrl = service?.image;

    final String name = service?.name ?? 'Service Detail';
    final String priceFormat = '₹${service?.price ?? 0}';
    final String type = service?.priceType ?? 'fixed';
    final String category = service?.categoryName ?? 'Uncategorized';
    final String subCategory = service?.subcategoryName ?? '';
    final String duration = service?.duration ?? '';
    final String description = service?.description ?? '';
    final String visitType = service?.visitType?.replaceAll('_', ' ') ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(name, style: const TextStyle(color: AppColors.primaryDark, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        actions: [
          if (service?.isFeatured == true)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('FEATURED', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image Carousel or Banner
            if (hasImages)
              GestureDetector(
                onTap: () {
                  if (imageUrl != null) ImageViewer.show(context, NetworkImage(imageUrl));
                },
                child: SizedBox(
                  height: 250,
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 180,
                color: AppColors.primary.withOpacity(0.1),
                child: const Center(child: Icon(Icons.design_services, size: 64, color: AppColors.primary)),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Core Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(category, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 0.5)),
                                  const SizedBox(height: 6),
                                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark, height: 1.2)),
                                  if (subCategory.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(subCategory, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(priceFormat, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  Text(type.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: AppColors.borderLight),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (duration.isNotEmpty) ...[
                              const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(duration, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 16),
                            ],
                            if (visitType.isNotEmpty) ...[
                              const Icon(Icons.directions_run, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(visitType.toUpperCase(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                            const Spacer(),
                            if (service?.discount != null && service!.discount! > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                child: Text('${service.discount}% OFF', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                              )
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Provider Info
                  if (provider != null) ...[
                    const SizedBox(height: 24),
                    const Text('Service Provider', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (provider.profileImage != null) ImageViewer.show(context, NetworkImage(provider.profileImage!));
                            },
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.borderLight,
                              backgroundImage: provider.profileImage != null ? NetworkImage(provider.profileImage!) : null,
                              child: provider.profileImage == null ? const Icon(Icons.person, color: Colors.grey) : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(provider.displayName.isNotEmpty ? provider.displayName : 'Unknown', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                if (provider.designation != null && provider.designation!.isNotEmpty)
                                  Text(provider.designation!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 12, color: AppColors.textMuted),
                                    const SizedBox(width: 2),
                                    Expanded(child: Text(provider.cityName ?? 'N/A', style: const TextStyle(color: AppColors.textMuted, fontSize: 12), overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (provider.contactNumber != null && provider.contactNumber!.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.phone, color: AppColors.primary),
                              onPressed: () {}, // Can add launcher later
                            )
                        ],
                      ),
                    ),
                  ],

                  // Description
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('About Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
                    ),
                  ],

                  // Addons
                  if (addons.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Available Add-ons', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    const SizedBox(height: 12),
                    ...addons.map((addon) {
                      final addonImg = addon.image;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight.withOpacity(0.5)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: addonImg != null
                              ? GestureDetector(
                                  onTap: () {
                                    if (addonImg != null) ImageViewer.show(context, NetworkImage(addonImg));
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(addonImg, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                                  ),
                                )
                              : Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(color: AppColors.bgLighterPurple, borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.extension, color: AppColors.primary),
                                ),
                          title: Text(addon.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          trailing: Text('₹${addon.price}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15)),
                        ),
                      );
                    }).toList(),
                  ],

                  // Related Services
                  if (relatedServices.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Text('Related Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedServices.length,
                        separatorBuilder: (ctx, i) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final rel = relatedServices[index];
                          final relImg = rel.image;
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(serviceId: rel.id)));
                            },
                            child: Container(
                              width: 160,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderLight.withOpacity(0.5)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (relImg != null) ImageViewer.show(context, NetworkImage(relImg));
                                    },
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      child: relImg != null
                                          ? Image.network(relImg, height: 90, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(height: 90, color: Colors.grey[200], child: const Icon(Icons.broken_image)))
                                          : Container(height: 90, color: AppColors.bgLighterPurple, width: double.infinity, child: const Icon(Icons.design_services, color: AppColors.primary)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(rel.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text(rel.priceFormat.isNotEmpty ? rel.priceFormat : '₹${rel.price}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ));
  }
}
