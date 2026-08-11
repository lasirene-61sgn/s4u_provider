import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../riverpod/post_job_notifier.dart';
import '../model/post_job_model.dart';
import '../../../core/widgets/image_viewer.dart';

class PostJobDetailScreen extends ConsumerStatefulWidget {
  final int jobId;
  const PostJobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<PostJobDetailScreen> createState() => _PostJobDetailScreenState();
}

class _PostJobDetailScreenState extends ConsumerState<PostJobDetailScreen> {
  final _bidCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(postJobProvider.notifier).fetchJobDetail(widget.jobId));
  }

  @override
  void dispose() {
    _bidCtrl.dispose();
    super.dispose();
  }

  void _showBidDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Place Bid'),
          content: TextField(
            controller: _bidCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Bid Amount',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(_bidCtrl.text);
                if (val != null && val > 0) {
                  Navigator.pop(context);
                  ref.read(postJobProvider.notifier).saveBid(widget.jobId, val);
                } else {
                  Get.snackbar('Error', 'Please enter a valid amount');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Submit Bid', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postJobProvider);
    final job = state.detailJob;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Request Details', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
      ),
      body: state.isDetailLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : state.detailError != null
              ? Center(child: Text(state.detailError!, style: const TextStyle(color: Colors.red)))
              : job == null
                  ? const Center(child: Text('Job not found.'))
                  : RefreshIndicator(
                      onRefresh: () => ref.read(postJobProvider.notifier).fetchJobDetail(widget.jobId),
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                     color: job.status.toLowerCase() == 'requested'
                                        ? Colors.orange.withValues(alpha: 0.1)
                                        : AppColors.primaryLight.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    job.status.toUpperCase(),
                                    style: TextStyle(
                                      color: job.status.toLowerCase() == 'requested' ? Colors.orange : AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Price: \$${job.price.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (job.description != null && job.description!.isNotEmpty) ...[
                              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              Text(job.description!, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                              const SizedBox(height: 24),
                            ],
                            
                            if (job.services.isNotEmpty) ...[
                              const Text('Requested Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 12),
                              ...job.services.map((s) => _buildServiceItem(s)),
                              const SizedBox(height: 24),
                            ],

                            const Text('Bids', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 12),
                            if (state.isBidsLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
                              )
                            else if (state.bidsError != null)
                              Text(state.bidsError!, style: const TextStyle(color: Colors.red, fontSize: 13))
                            else if (state.bids.isEmpty)
                              const Text('No bids placed yet.', style: TextStyle(color: AppColors.textMuted))
                            else
                              ...state.bids.map((b) => _buildBidItem(b)),
                              
                            const SizedBox(height: 80), // Padding for bottom button
                          ],
                        ),
                      ),
                    ),
      bottomSheet: job != null && job.canBid
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: ElevatedButton(
                onPressed: state.isBidding ? null : _showBidDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: state.isBidding
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Place a Bid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          : null,
    );
  }

  Widget _buildServiceItem(PostJobService service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            if (service.categoryName != null) ...[
              const SizedBox(height: 4),
              Text('Category: ${service.categoryName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
            if (service.attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: service.attachments.length,
                  separatorBuilder: (c, i) => const SizedBox(width: 8),
                  itemBuilder: (c, i) {
                    final url = service.attachments[i];
                    return GestureDetector(
                      onTap: () => ImageViewer.show(context, NetworkImage(url)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(url, width: 60, height: 60, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBidItem(BidItem bid) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      color: AppColors.bgLighterPurple.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bid Amount: \$${bid.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Status: ${bid.status}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
