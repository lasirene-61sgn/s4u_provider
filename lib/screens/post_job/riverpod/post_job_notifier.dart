import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../model/post_job_model.dart';
import '../../profile/riverpod/profile_notifier.dart';

class PostJobState {
  final bool isListLoading;    // loading for job list
  final bool isDetailLoading;  // loading for job detail
  final bool isBidsLoading;    // loading for bids list
  final bool isBidding;        // saving a bid
  final List<PostJob> jobs;
  final PostJob? detailJob;
  final List<BidItem> bids;
  final String? listError;
  final String? detailError;
  final String? bidsError;

  PostJobState({
    this.isListLoading = false,
    this.isDetailLoading = false,
    this.isBidsLoading = false,
    this.isBidding = false,
    this.jobs = const [],
    this.detailJob,
    this.bids = const [],
    this.listError,
    this.detailError,
    this.bidsError,
  });

  PostJobState copyWith({
    bool? isListLoading,
    bool? isDetailLoading,
    bool? isBidsLoading,
    bool? isBidding,
    List<PostJob>? jobs,
    PostJob? detailJob,
    List<BidItem>? bids,
    String? listError,
    String? detailError,
    String? bidsError,
  }) {
    return PostJobState(
      isListLoading: isListLoading ?? this.isListLoading,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      isBidsLoading: isBidsLoading ?? this.isBidsLoading,
      isBidding: isBidding ?? this.isBidding,
      jobs: jobs ?? this.jobs,
      detailJob: detailJob ?? this.detailJob,
      bids: bids ?? this.bids,
      listError: listError,
      detailError: detailError,
      bidsError: bidsError,
    );
  }
}

class PostJobNotifier extends Notifier<PostJobState> {
  final ApiClient _api = ApiClient();

  @override
  PostJobState build() => PostJobState();

  // ── LIST ──────────────────────────────────────────────────────────────────
  Future<void> fetchJobs() async {
    state = state.copyWith(isListLoading: true, listError: null);
    try {
      final res = await _api.get(endpoint: ApiConstants.getPostJobs);
      // _handleResponse wraps as {status:1, data: rawBody}
      // rawBody shape: {pagination:{}, data:[...]}
      final rawBody = res?['data'];
      final list = rawBody is Map ? rawBody['data'] : null;

      if (res?['status'] == 1 && list is List) {
        final jobs = list
            .map((e) => PostJob.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(isListLoading: false, jobs: jobs);
      } else {
        final msg = rawBody is Map
            ? rawBody['message']?.toString() ?? 'Failed to load jobs'
            : 'Failed to load jobs';
        state = state.copyWith(isListLoading: false, listError: msg);
      }
    } catch (e) {
      state = state.copyWith(isListLoading: false, listError: e.toString());
    }
  }

  // ── DETAIL (POST — server requires POST for this endpoint) ────────────────
  Future<void> fetchJobDetail(int id) async {
    state = state.copyWith(isDetailLoading: true, detailError: null, detailJob: null, bids: []);
    try {
      final res = await _api.post(
        endpoint: ApiConstants.getPostJobDetail,
        body: {'post_request_id': id},
      );
      final rawBody = res?['data'];
      
      Map<String, dynamic>? jobData;
      if (rawBody is Map<String, dynamic>) {
        if (rawBody.containsKey('post_request_detail') && rawBody['post_request_detail'] is Map) {
          jobData = rawBody['post_request_detail'] as Map<String, dynamic>;
        } else if (rawBody.containsKey('data') && rawBody['data'] is Map) {
          jobData = rawBody['data'] as Map<String, dynamic>;
        } else {
          jobData = rawBody;
        }
      }

      if (res?['status'] == 1 && jobData != null) {
        final detail = PostJob.fromJson(jobData);
        
        List<BidItem> extractedBids = [];
        if (rawBody is Map && rawBody.containsKey('bider_data') && rawBody['bider_data'] is List) {
          extractedBids = (rawBody['bider_data'] as List).map((e) => BidItem.fromJson(e)).toList();
        }
        
        state = state.copyWith(isDetailLoading: false, detailJob: detail, bids: extractedBids);
        
        // Only fetch bids separately if bider_data wasn't included
        if (!rawBody.containsKey('bider_data')) {
           await fetchBids(id);
        }
      } else {
        final msg = rawBody is Map
            ? rawBody['message']?.toString() ?? 'Failed to load detail'
            : 'Failed to load detail';
        state = state.copyWith(isDetailLoading: false, detailError: msg);
      }
    } catch (e) {
      state = state.copyWith(isDetailLoading: false, detailError: e.toString());
    }
  }

  // ── BIDS LIST (POST — same pattern as detail) ─────────────────────────────
  Future<void> fetchBids(int jobId) async {
    state = state.copyWith(isBidsLoading: true, bidsError: null);
    try {
      final res = await _api.post(
        endpoint: ApiConstants.getBidList,
        body: {'post_request_id': jobId, 'post_job_id': jobId},
      );
      final rawBody = res?['data'];
      final list = rawBody is Map ? rawBody['data'] : null;

      if (res?['status'] == 1 && list is List) {
        final bids = list
            .map((e) => BidItem.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(isBidsLoading: false, bids: bids);
      } else {
        // empty bids is not an error — server may return empty list
        state = state.copyWith(isBidsLoading: false, bids: []);
      }
    } catch (e) {
      state = state.copyWith(isBidsLoading: false, bidsError: e.toString());
    }
  }

  // ── SAVE BID ──────────────────────────────────────────────────────────────
  Future<void> saveBid(int jobId, double price) async {
    state = state.copyWith(isBidding: true);
    try {
      final pId = ref.read(profileProvider).profile?.id ?? 0;
      final res = await _api.post(
        endpoint: ApiConstants.saveBid,
        body: {
          'post_request_id': jobId,
          'post_job_id': jobId,
          'provider_id': pId,
          'price': price,
          'amount': price
        },
      );
      state = state.copyWith(isBidding: false);

      bool success = false;
      String? msg;
      
      if (res != null) {
        if (res['status'] == 1 || res['status'] == true) {
          success = true;
        } else if (res['message'] != null && res['message'].toString().toLowerCase().contains('success')) {
          success = true;
          msg = res['message'].toString();
        } else if (res['data'] is Map && res['data']['message'] != null && res['data']['message'].toString().toLowerCase().contains('success')) {
           success = true;
           msg = res['data']['message'].toString();
        }
      }

      if (success) {
        Get.snackbar('Success', msg ?? 'Bid placed successfully!',
            backgroundColor: const Color(0xFFD1FAE5),
            colorText: const Color(0xFF065F46));
        fetchJobDetail(jobId);
      } else {
        final errorMsg = res?['data'] is Map
            ? res!['data']['message']?.toString() ?? res['message']?.toString() ?? 'Failed to place bid'
            : res?['message']?.toString() ?? res?['data']?.toString() ?? 'Failed to place bid';
        Get.snackbar('Error', errorMsg,
            backgroundColor: const Color(0xFFFFE4E6),
            colorText: const Color(0xFFE11D48));
      }
    } catch (e) {
      state = state.copyWith(isBidding: false);
      Get.snackbar('Error', e.toString(),
          backgroundColor: const Color(0xFFFFE4E6),
          colorText: const Color(0xFFE11D48));
    }
  }
}

final postJobProvider =
    NotifierProvider<PostJobNotifier, PostJobState>(() => PostJobNotifier());
