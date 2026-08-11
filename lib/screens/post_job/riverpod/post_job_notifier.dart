import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../model/post_job_model.dart';

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
        body: {'post_job_id': id},
      );
      final rawBody = res?['data'];
      // detail body can be {data: {...}} or the object directly
      final jobData = rawBody is Map && rawBody['data'] is Map
          ? rawBody['data'] as Map<String, dynamic>
          : rawBody is Map<String, dynamic>
              ? rawBody
              : null;

      if (res?['status'] == 1 && jobData != null) {
        final detail = PostJob.fromJson(jobData);
        state = state.copyWith(isDetailLoading: false, detailJob: detail);
        await fetchBids(id);
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
        body: {'post_job_id': jobId},
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
      final res = await _api.post(
        endpoint: ApiConstants.saveBid,
        body: {'post_job_id': jobId, 'price': price},
      );
      state = state.copyWith(isBidding: false);

      if (res?['status'] == 1 || res?['status'] == true) {
        Get.snackbar('Success', 'Bid placed successfully!',
            backgroundColor: const Color(0xFFD1FAE5),
            colorText: const Color(0xFF065F46));
        fetchJobDetail(jobId);
      } else {
        final msg = res?['data'] is Map
            ? res!['data']['message']?.toString() ?? 'Failed to place bid'
            : res?['data']?.toString() ?? 'Failed to place bid';
        Get.snackbar('Error', msg,
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
