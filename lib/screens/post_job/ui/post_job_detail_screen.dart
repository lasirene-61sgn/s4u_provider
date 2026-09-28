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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Place Bid', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          content: TextField(
            controller: _bidCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Bid Amount',
              prefixText: '\$ ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(_bidCtrl.text);
                if (val != null && val > 0) {
                  Navigator.pop(context);
                  ref.read(postJobProvider.notifier).saveBid(widget.jobId, val);
                } else {
                  Get.snackbar('Error', 'Please enter a valid amount', backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
              ),
              child: const Text('Submit Bid', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      backgroundColor: AppColors.backgroundScaffold,
      appBar: AppBar(
        title: const Text('Request Details', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
      ),
      body: state.isDetailLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : state.detailError != null
              ? Center(child: Text(state.detailError!, style: const TextStyle(color: Colors.red)))
              : job == null
                  ? const Center(child: Text('Job not found.', style: TextStyle(color: AppColors.textMuted)))
                  : RefreshIndicator(
                      onRefresh: () => ref.read(postJobProvider.notifier).fetchJobDetail(widget.jobId),
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4)),
                                ],
                                border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          job.title,
                                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryDark, letterSpacing: -0.5),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: job.status.toLowerCase() == 'requested' ? Colors.orange.withValues(alpha: 0.1) : AppColors.primaryLight.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(color: job.status.toLowerCase() == 'requested' ? Colors.orange.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.3)),
                                        ),
                                        child: Text(
                                          job.status.toUpperCase(),
                                          style: TextStyle(color: job.status.toLowerCase() == 'requested' ? Colors.orange : AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Customer Info
                                  if (job.customerName != null) ...[
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: AppColors.bgLighterPurple,
                                          backgroundImage: job.customerProfile != null && job.customerProfile!.isNotEmpty
                                              ? NetworkImage(job.customerProfile!)
                                              : null,
                                          child: job.customerProfile == null || job.customerProfile!.isEmpty
                                              ? const Icon(Icons.person, color: AppColors.primary, size: 20)
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Customer', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                                            Text(job.customerName!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                          ],
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  const Divider(color: AppColors.borderLight),
                                  const SizedBox(height: 12),
                                  // Budget Area
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: AppColors.bgLighterPurple.withValues(alpha: 0.5), shape: BoxShape.circle),
                                        child: const Icon(Icons.monetization_on_rounded, size: 20, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Total Budget', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                                          Text('\$${job.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryDark, fontSize: 20)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (job.description != null && job.description!.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark)),
                                    const SizedBox(height: 8),
                                    Text(job.description!, style: const TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 13)),
                                  ],
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            if (job.services.isNotEmpty) ...[
                              const Row(
                                children: [
                                  Icon(Icons.design_services_rounded, size: 18, color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text('Requested Services', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryDark, letterSpacing: -0.5)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...job.services.map((s) => _buildServiceItem(s)),
                              const SizedBox(height: 24),
                            ],

                            const Row(
                              children: [
                                Icon(Icons.local_offer_rounded, size: 18, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text('Received Bids', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryDark, letterSpacing: -0.5)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (state.isBidsLoading)
                              const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)))
                            else if (state.bidsError != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                                child: Text(state.bidsError!, style: TextStyle(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.bold)),
                              )
                            else if (state.bids.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(Icons.inbox_rounded, size: 48, color: AppColors.borderLight),
                                    SizedBox(height: 12),
                                    Text('No bids placed yet.', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 4),
                                    Text('Be the first to place a bid on this job!', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                  ],
                                ),
                              )
                            else
                              ...state.bids.map((b) => _buildBidItem(b)),
                              
                            const SizedBox(height: 100), 
                          ],
                        ),
                      ),
                    ),
      bottomSheet: job != null && job.canBid
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -4))],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: state.isBidding ? null : _showBidDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: state.isBidding
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_offer_rounded, size: 20, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Place a Bid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          ],
                        ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildServiceItem(PostJobService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark)),
                      if (service.categoryName != null) ...[
                        const SizedBox(height: 4),
                        Text(service.categoryName!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                      if (service.type != null || service.duration != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (service.type != null && service.type!.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text(service.type!.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                              ),
                            if (service.duration != null && service.duration != '0')
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 12, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text('${service.duration} mins', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                          ],
                        )
                      ],
                      if (service.description != null && service.description != 'NA') ...[
                        const SizedBox(height: 8),
                        Text(service.description!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ]
                    ],
                  ),
                ),
                if (service.priceFormat != null && service.priceFormat != '₹0.00' && service.priceFormat != '\$0.00' && service.price != 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primaryLight.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(service.priceFormat ?? '\$${service.price}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13)),
                  ),
              ],
            ),
            if (service.attachments.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: service.attachments.length,
                  separatorBuilder: (c, i) => const SizedBox(width: 12),
                  itemBuilder: (c, i) {
                    final url = service.attachments[i];
                    return GestureDetector(
                      onTap: () => ImageViewer.show(context, NetworkImage(url)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(url, width: 70, height: 70, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(width: 70, height: 70, color: AppColors.bgLighterPurple, child: const Icon(Icons.image_not_supported, color: AppColors.primaryLight)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                image: bid.providerImage != null && bid.providerImage!.isNotEmpty
                    ? DecorationImage(image: NetworkImage(bid.providerImage!), fit: BoxFit.cover)
                    : null,
              ),
              child: bid.providerImage == null || bid.providerImage!.isEmpty
                  ? const Icon(Icons.person, color: AppColors.primary, size: 24)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bid.providerName != null && bid.providerName!.isNotEmpty)
                    Text(bid.providerName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('\$${bid.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary)),
                      if (bid.duration != null && bid.duration!.isNotEmpty && bid.duration != '0') ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.timer_outlined, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text('${bid.duration} mins', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                  if (bid.note != null && bid.note!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(bid.note!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bid.status.toLowerCase() == 'pending' ? Colors.orange : (bid.status.toLowerCase() == 'accepted' ? Colors.green : Colors.grey)
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(bid.status.toUpperCase(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
