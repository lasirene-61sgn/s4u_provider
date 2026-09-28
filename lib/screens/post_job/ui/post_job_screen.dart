import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../riverpod/post_job_notifier.dart';
import 'post_job_detail_screen.dart';
import '../model/post_job_model.dart';

class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(postJobProvider.notifier).fetchJobs());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postJobProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: state.isListLoading && state.jobs.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : state.listError != null
              ? Center(child: Text(state.listError!, style: const TextStyle(color: Colors.red)))
              : state.jobs.isEmpty
                  ? const Center(child: Text('No service requests found.', style: TextStyle(color: AppColors.textMuted)))
                  : RefreshIndicator(
                      onRefresh: () => ref.read(postJobProvider.notifier).fetchJobs(),
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.jobs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final job = state.jobs[index];
                          return _buildJobCard(job);
                        },
                      ),
                    ),
    );
  }

  Widget _buildJobCard(PostJob job) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Get.to(() => PostJobDetailScreen(jobId: job.id));
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark, letterSpacing: -0.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (job.createdAt != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  job.createdAt!.split('T').first,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: job.status.toLowerCase() == 'requested'
                            ? Colors.orange.withValues(alpha: 0.1)
                            : AppColors.primaryLight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: job.status.toLowerCase() == 'requested'
                              ? Colors.orange.withValues(alpha: 0.3)
                              : AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        job.status.toUpperCase(),
                        style: TextStyle(
                          color: job.status.toLowerCase() == 'requested' ? Colors.orange : AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                if (job.description != null && job.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    job.description!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgLighterPurple.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
                          ]
                        ),
                        child: const Icon(Icons.monetization_on_rounded, size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Budget', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                          Text(
                            '\$${job.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (job.canBid)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))
                            ]
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.local_offer_rounded, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Open for Bids', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (job.services.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.design_services_rounded, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text('Requested Services (${job.services.length})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...job.services.map((s) => Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: s.attachments.isNotEmpty
                              ? Image.network(
                                  s.attachments.first,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                                )
                              : _buildPlaceholderImage(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (s.categoryName != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  s.categoryName!,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (s.priceFormat != null && s.priceFormat != '₹0.00' && s.priceFormat != '\$0.00' && s.price != 0) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        s.priceFormat ?? '\$${s.price}',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  if (s.type != null && s.type!.isNotEmpty) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        s.type!.toUpperCase(),
                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  if (s.duration != null && s.duration != '0') ...[
                                    Row(
                                      children: [
                                        const Icon(Icons.timer_outlined, size: 12, color: AppColors.textMuted),
                                        const SizedBox(width: 4),
                                        Text('${s.duration} mins', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  if (s.visitType != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        s.visitType!.replaceAll('_', ' ').toUpperCase(),
                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                      ),
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.borderLight, size: 20),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 50,
      height: 50,
      color: AppColors.borderLight.withValues(alpha: 0.5),
      child: const Icon(Icons.design_services_outlined, color: AppColors.textMuted, size: 24),
    );
  }
}
