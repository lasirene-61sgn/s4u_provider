import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../model/helpdesk_model.dart';

class HelpDeskState {
  final bool isLoading;
  final bool isFetchingMore;
  final List<HelpDeskTicket> tickets;
  final String? error;
  final int page;
  final bool hasMore;

  HelpDeskState({
    this.isLoading = false,
    this.isFetchingMore = false,
    this.tickets = const [],
    this.error,
    this.page = 1,
    this.hasMore = true,
  });

  HelpDeskState copyWith({
    bool? isLoading,
    bool? isFetchingMore,
    List<HelpDeskTicket>? tickets,
    String? error,
    int? page,
    bool? hasMore,
  }) {
    return HelpDeskState(
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      tickets: tickets ?? this.tickets,
      error: error ?? this.error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class HelpDeskNotifier extends Notifier<HelpDeskState> {
  final ApiClient _api = ApiClient();

  @override
  HelpDeskState build() => HelpDeskState(isLoading: true);

  Future<void> fetchTickets({bool loadMore = false, String? search}) async {
    if (loadMore) {
      if (!state.hasMore || state.isFetchingMore) return;
      state = state.copyWith(isFetchingMore: true, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null, page: 1, hasMore: true);
    }

    final page = loadMore ? state.page + 1 : 1;
    final query = <String, dynamic>{'page': page};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    final res = await _api.get(endpoint: '/helpdesk-list', query: query);

    if (res != null && res['data'] != null) {
      final Map<String, dynamic> responseData = res['data'];
      final List data = responseData['data'] ?? [];
      final newTickets = data.map((e) => HelpDeskTicket.fromJson(e)).toList();

      final pagination = responseData['pagination'] as Map<String, dynamic>?;
      final totalPages = pagination != null ? (pagination['totalPages'] as int? ?? 1) : 1;
      final hasNextPage = page < totalPages;

      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        tickets: loadMore ? [...state.tickets, ...newTickets] : newTickets,
        page: page,
        hasMore: hasNextPage,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        error: res?['message'] ?? 'Failed to load helpdesk tickets',
      );
    }
  }

  Future<void> loadMore() async {
    await fetchTickets(loadMore: true);
  }

  Future<bool> createTicket(String subject, String description) async {
    final res = await _api.post(
      endpoint: '/helpdesk-save',
      body: {
        'subject': subject,
        'description': description,
      },
    );
    if (res != null && res['status'] == 1) {
      fetchTickets();
      return true;
    }
    return false;
  }

  Future<bool> closeTicket(int id) async {
    final res = await _api.post(endpoint: '/helpdesk-closed/$id');
    if (res != null) {
      // Assuming success if it returns without error
      state = state.copyWith(
        tickets: state.tickets.map((t) => t.id == id ? HelpDeskTicket(
          id: t.id,
          subject: t.subject,
          description: t.description,
          status: 'closed',
          createdAt: t.createdAt,
          employeeName: t.employeeName,
          attachments: t.attachments,
        ) : t).toList(),
      );
      return true;
    }
    return false;
  }
}

final helpDeskProvider = NotifierProvider<HelpDeskNotifier, HelpDeskState>(() => HelpDeskNotifier());
