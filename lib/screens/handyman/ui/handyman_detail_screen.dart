import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/image_viewer.dart';
import '../riverpod/handyman_detail_notifier.dart';
import '../model/handyman_detail_model.dart';

class HandymanDetailScreen extends ConsumerStatefulWidget {
  final int handymanId;

  const HandymanDetailScreen({super.key, required this.handymanId});

  @override
  ConsumerState<HandymanDetailScreen> createState() => _HandymanDetailScreenState();
}

class _HandymanDetailScreenState extends ConsumerState<HandymanDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(handymanDetailProvider.notifier).fetchHandymanDetail(widget.handymanId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(handymanDetailProvider);
    final detail = state.detail;

    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      appBar: AppBar(
        title: const Text('Handyman Details', style: TextStyle(color: AppColors.primaryDark, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!, style: const TextStyle(color: Colors.red)))
              : detail == null
                  ? const Center(child: Text('No details found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileCard(detail),
                          const SizedBox(height: 16),
                          _buildContactCard(detail),
                          const SizedBox(height: 16),
                          _buildStatsCard(detail),
                          if (_hasSkillsOrLanguages(detail)) ...[
                            const SizedBox(height: 16),
                            _buildSkillsLanguagesCard(detail),
                          ],
                          if (detail.whyChooseMeDescription != null && detail.whyChooseMeDescription!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildAboutCard(detail),
                          ],
                        ],
                      ),
                    ),
    );
  }

  bool _hasSkillsOrLanguages(HandymanDetail detail) {
    bool hasLang = detail.knownLanguages != null && detail.knownLanguages.toString().trim().isNotEmpty;
    bool hasSkills = detail.skills != null && detail.skills.toString().trim().isNotEmpty;
    return hasLang || hasSkills;
  }

  Widget _buildProfileCard(HandymanDetail detail) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (detail.profileImage != null && detail.profileImage!.isNotEmpty) {
                ImageViewer.show(context, NetworkImage(detail.profileImage!));
              }
            },
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.bgLighterPurple,
              backgroundImage: detail.profileImage != null && detail.profileImage!.isNotEmpty ? NetworkImage(detail.profileImage!) : null,
              child: detail.profileImage == null || detail.profileImage!.isEmpty ? const Icon(Icons.person, size: 40, color: AppColors.primary) : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${detail.firstName} ${detail.lastName}'.trim(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                if (detail.designation != null) ...[
                  const SizedBox(height: 4),
                  Text(detail.designation!, style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text('${detail.handymanRating ?? 0} Rating', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(HandymanDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Email', detail.email),
          const Divider(height: 24),
          _buildInfoRow(Icons.phone_outlined, 'Phone', detail.contactNumber),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.bgLighterPurple, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(HandymanDetail detail) {
    return Row(
      children: [
        Expanded(child: _buildStatItem('Services Booked', detail.totalServicesBooked?.toString() ?? '0', Icons.work_outline)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem('Status', detail.status == 1 ? 'Active' : 'Inactive', detail.status == 1 ? Icons.check_circle_outline : Icons.cancel_outlined, color: detail.status == 1 ? Colors.green : Colors.red)),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, color: color ?? AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color ?? AppColors.primaryDark)),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSkillsLanguagesCard(HandymanDetail detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.skills != null && detail.skills.toString().trim().isNotEmpty) ...[
            const Text('Skills', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            _buildTags(detail.skills.toString()),
          ],
          if (detail.knownLanguages != null && detail.knownLanguages.toString().trim().isNotEmpty) ...[
            if (detail.skills != null && detail.skills.toString().trim().isNotEmpty) const SizedBox(height: 16),
            const Text('Languages', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            _buildTags(detail.knownLanguages.toString()),
          ],
        ],
      ),
    );
  }

  Widget _buildTags(String text) {
    final tags = text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: AppColors.bgLighterPurple, borderRadius: BorderRadius.circular(20)),
        child: Text(tag, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
      )).toList(),
    );
  }

  Widget _buildAboutCard(HandymanDetail detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(detail.whyChooseMeTitle ?? 'About', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          const SizedBox(height: 8),
          Text(detail.whyChooseMeDescription ?? '', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
          if (detail.whyChooseMeReasons != null && detail.whyChooseMeReasons!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...detail.whyChooseMeReasons!.map((reason) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(reason, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                ],
              ),
            )),
          ]
        ],
      ),
    );
  }
}
