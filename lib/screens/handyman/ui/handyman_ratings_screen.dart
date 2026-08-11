import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/image_viewer.dart';
import '../model/handyman_rating_model.dart';
import '../riverpod/handyman_ratings_notifier.dart';

class HandymanRatingsScreen extends ConsumerStatefulWidget {
  const HandymanRatingsScreen({super.key});

  @override
  ConsumerState<HandymanRatingsScreen> createState() => _HandymanRatingsScreenState();
}

class _HandymanRatingsScreenState extends ConsumerState<HandymanRatingsScreen> {
  int _entriesPerPage = 10;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(handymanRatingsProvider.notifier).loadRatings();
    });
  }

  @override
  Widget build(BuildContext context) {
    const bool isMobile = true;
    final state = ref.watch(handymanRatingsProvider);

    List<HandymanRatingModel> filteredRatings = state.ratings.where((rating) {
      final handymanName = rating.handymanName.toLowerCase();
      final customerName = rating.customerName.toLowerCase();
      final search = _searchQuery.toLowerCase();
      return handymanName.contains(search) || customerName.contains(search);
    }).toList();
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
                        Expanded(flex: 2, child: Text('Handyman', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Rating', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: (state.isLoading && state.ratings.isEmpty)
                        ? const Center(child: CircularProgressIndicator())
                        : filteredRatings.isEmpty
                            ? const Center(
                                child: Text('No data available in table', style: TextStyle(color: AppColors.textSecondary)),
                              )
                            : ListView.separated(
                                itemCount: filteredRatings.length,
                                separatorBuilder: (ctx, i) => isMobile ? const SizedBox(height: 8) : const Divider(height: 1, color: AppColors.borderLight),
                                itemBuilder: (ctx, index) {
                                  final rating = filteredRatings[index];
                                  final handymanName = rating.handymanName;
                                  final handymanImage = rating.handymanImage;
                                  final customerName = rating.customerName;
                                  final score = rating.rating.toString();
                                  final review = rating.review;

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
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (handymanImage != null) ImageViewer.show(context, NetworkImage(handymanImage));
                                                    },
                                                    child: CircleAvatar(
                                                      radius: 18,
                                                      backgroundColor: Colors.grey.shade200,
                                                      backgroundImage: handymanImage != null ? NetworkImage(handymanImage) : null,
                                                      child: handymanImage == null ? const Icon(Icons.person, size: 18, color: Colors.grey) : null,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(handymanName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark)),
                                                      const SizedBox(height: 2),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.star, color: Colors.amber, size: 14),
                                                          const SizedBox(width: 4),
                                                          Text(score, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(color: const Color(0xFF635BFF).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                                child: Text(customerName, style: const TextStyle(color: Color(0xFF635BFF), fontSize: 12, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                          if (review.isNotEmpty) ...[
                                            const SizedBox(height: 16),
                                            const Divider(height: 1, color: AppColors.borderLight),
                                            const SizedBox(height: 12),
                                            const Text('Review:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 4),
                                            Text(review, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontStyle: FontStyle.italic)),
                                          ],
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
                                                  if (handymanImage != null) ImageViewer.show(context, NetworkImage(handymanImage));
                                                },
                                                child: CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: Colors.grey.shade200,
                                                  backgroundImage: handymanImage != null ? NetworkImage(handymanImage) : null,
                                                  child: handymanImage == null ? const Icon(Icons.person, size: 16, color: Colors.grey) : null,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(child: Text(handymanName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(customerName, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star, color: Colors.amber, size: 14),
                                              const SizedBox(width: 4),
                                              Text(score, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(review, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), overflow: TextOverflow.ellipsis, maxLines: 2),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.borderLight),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _entriesPerPage,
                                  isDense: true,
                                  items: [10, 25, 50, 100].map((val) => DropdownMenuItem(value: val, child: Text('$val', style: const TextStyle(fontSize: 13)))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _entriesPerPage = val);
                                  },
                                ),
                              ),
                            ),
                            const Text(' entries', style: TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(width: 16),
                            Text('Showing 1 to ${filteredRatings.length} of ${filteredRatings.length} entries', style: const TextStyle(color: AppColors.textMuted)),
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
