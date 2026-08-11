import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/image_viewer.dart';
import 'add_package_screen.dart';
import '../riverpod/package_notifier.dart';

class PackagesScreen extends ConsumerStatefulWidget {
  const PackagesScreen({super.key});

  @override
  ConsumerState<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends ConsumerState<PackagesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(packageProvider.notifier).loadMore();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(packageProvider.notifier).fetchAllPackages();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPackageScreen()));
                                    },
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Add Package'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF635BFF),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPackageScreen()));
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Package'),
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
                      ],
                    ),
                  ),
                  if (!isMobile) Container(
                    color: const Color(0xFF635BFF),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: const Row(
                      children: [
                        SizedBox(width: 40, child: Icon(Icons.check_box_outline_blank, color: Colors.white, size: 18)),
                        Expanded(child: Text('Image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Provider', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Price', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        SizedBox(width: 80, child: Text('Action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildPackageList(),
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

  Widget _buildPackageList() {
    final state = ref.watch(packageProvider);

    if (state.isLoading && state.packages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.packages.isEmpty) {
      return Center(child: Text(state.error!, style: const TextStyle(color: Colors.red)));
    }

    if (state.packages.isEmpty) {
      return const Center(
        child: Text('No packages available in table', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    const bool isMobile = true;
    return ListView.separated(
      controller: _scrollController,
      itemCount: state.packages.length + (state.isFetchingMore ? 1 : 0),
      separatorBuilder: (context, index) => isMobile ? const SizedBox(height: 16) : const Divider(height: 1, color: AppColors.borderLight),
      itemBuilder: (context, index) {
        if (index == state.packages.length) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(color: AppColors.primary),
          ));
        }

        final pkg = state.packages[index];
        if (isMobile) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pkg.imageUrl != null) ...[
                      GestureDetector(
                        onTap: () {
                          ImageViewer.show(context, NetworkImage(pkg.imageUrl!));
                        },
                        child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(pkg.imageUrl!, height: 60, width: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, size: 40, color: AppColors.textMuted))),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(pkg.name, style: const TextStyle(color: Color(0xFF635BFF), fontSize: 16, fontWeight: FontWeight.bold))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: pkg.status == 'ACTIVE' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(pkg.status, style: TextStyle(color: pkg.status == 'ACTIVE' ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Provider', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('\$${pkg.price ?? 0}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddPackageScreen(package: pkg)));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.bgLighterPurple, foregroundColor: AppColors.primary, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    state.deletingPackageId == pkg.id
                        ? const Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red)))
                        : ElevatedButton.icon(
                            onPressed: () async {
                              await ref.read(packageProvider.notifier).deletePackage(pkg.id!);
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
              Expanded(child: pkg.imageUrl != null ? GestureDetector(
                onTap: () {
                  ImageViewer.show(context, NetworkImage(pkg.imageUrl!));
                },
                child: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(pkg.imageUrl!, height: 40, width: 40, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, size: 30, color: AppColors.textMuted))),
              ) : const Icon(Icons.image, size: 30, color: AppColors.textMuted)),
              Expanded(flex: 2, child: Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.w500))),
              const Expanded(flex: 2, child: Text('Provider', style: TextStyle(color: AppColors.textSecondary))),
              Expanded(child: Text('\$${pkg.price ?? 0}', style: const TextStyle(fontWeight: FontWeight.w500))),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: pkg.status == 'ACTIVE' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    pkg.status,
                    style: TextStyle(
                      color: pkg.status == 'ACTIVE' ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Row(
                  children: [
                    InkWell(onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddPackageScreen(package: pkg)));
                    }, child: const Icon(Icons.edit, size: 18, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    state.deletingPackageId == pkg.id
                        ? const Padding(padding: EdgeInsets.all(2), child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red)))
                        : InkWell(
                            onTap: () async {
                              await ref.read(packageProvider.notifier).deletePackage(pkg.id!);
                            }, 
                            child: const Icon(Icons.delete, size: 18, color: Colors.red),
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
}
