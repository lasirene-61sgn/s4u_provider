import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../model/service_model.dart';
import '../../profile/riverpod/profile_notifier.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceState {
  final bool isLoading;
  final bool isFetchingMore;
  final List<ServiceModel> services;
  final List<ServiceModel> allServices;
  final String? error;
  final int page;
  final bool hasMore;

  ServiceState({
    this.isLoading = false,
    this.isFetchingMore = false,
    this.services = const [],
    this.allServices = const [],
    this.error,
    this.page = 1,
    this.hasMore = true,
  });

  ServiceState copyWith({
    bool? isLoading,
    bool? isFetchingMore,
    List<ServiceModel>? services,
    List<ServiceModel>? allServices,
    String? error,
    int? page,
    bool? hasMore,
  }) {
    return ServiceState(
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      services: services ?? this.services,
      allServices: allServices ?? this.allServices,
      error: error ?? this.error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ServiceNotifier extends Notifier<ServiceState> {
  final ApiClient _api = ApiClient();

  @override
  ServiceState build() => ServiceState(isLoading: true);

  Future<void> fetchServices({bool loadMore = false, String? search}) async {
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
    
    final res = await _api.get(endpoint: '/service-list', query: query);
    
    if (res != null) {
      List data = [];
      Map<String, dynamic>? pagination;
      
      if (res['data'] is List) {
        data = res['data'] as List;
        pagination = res['pagination'] as Map<String, dynamic>?;
      } else if (res['data'] is Map) {
        final Map<String, dynamic> responseData = res['data'];
        data = responseData['data'] is List ? responseData['data'] as List : [];
        pagination = responseData['pagination'] as Map<String, dynamic>?;
      } else if (res['data'] == null && res['pagination'] != null) {
        // Fallback if data is at root but null for some reason
        pagination = res['pagination'] as Map<String, dynamic>?;
      }

      final newServices = data.map((e) => ServiceModel.fromJson(e)).toList();
      
      final totalPages = pagination != null ? (pagination['totalPages'] as int? ?? 1) : 1;
      final hasNextPage = page < totalPages;

      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        services: loadMore ? [...state.services, ...newServices] : newServices,
        page: page,
        hasMore: hasNextPage,
      );
    } else {
      state = state.copyWith(isLoading: false, isFetchingMore: false, error: res?['message'] ?? 'Failed to load services');
    }
  }

  Future<void> loadMore() async {
    await fetchServices(loadMore: true);
  }

  Future<void> fetchAllServices() async {
    final res = await _api.get(endpoint: '/get-all-service-list');
    
    if (res != null && res['data'] != null) {
      List data = [];
      if (res['data'] is List) {
        data = res['data'] as List;
      } else if (res['data'] is Map && res['data']['data'] is List) {
        data = res['data']['data'] as List;
      }
      final allServicesList = data.map((e) => ServiceModel.fromJson(e)).toList();
      
      state = state.copyWith(allServices: allServicesList);
    }
  }

  Future<void> addService({
    required String name,
    required String description,
    required String categoryId,
    String? subcategoryId,
    required double price,
    required String priceType,
    String? duration,
    double? discount,
    required String status,
    String? visitType,
    String? selectAddress,
    String? providerAddressId,
    bool isFeatured = false,
    bool timeslot = false,
    bool advancedPayment = false,
    double? advancedPaymentAmount,
    int? providerId,
    String? providerName,
    String? providerEmail,
    PlatformFile? serviceAttachment,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'description': description,
      'category_id': categoryId,
      'price': price,
      'type': priceType.toLowerCase(),
      'status': status.toUpperCase() == 'ACTIVE' ? '1' : '0',
    };
    if (providerId != null) body['provider_id'] = providerId;
    if (subcategoryId != null && subcategoryId.isNotEmpty) body['subcategory_id'] = subcategoryId;
    if (duration != null) body['duration'] = duration;
    
    // Additional keys that were in the original code, adapted if needed
    if (discount != null) body['discount'] = discount;
    if (visitType != null) body['visit_type'] = visitType.toLowerCase();
    if (selectAddress != null) body['selectAddress'] = selectAddress;
    if (providerAddressId != null && providerAddressId != '0') body['provider_address_id'] = [providerAddressId];
    body['is_featured'] = isFeatured ? 1 : 0;
    body['is_slot'] = timeslot ? 1 : 0;
    body['is_enable_advance_payment'] = advancedPayment == false ? 0 : 1;
    if (advancedPayment == true) {
      if (advancedPaymentAmount != null) body['advance_payment_amount'] = advancedPaymentAmount;
    }

    final Map<String, dynamic> files = {};
    if (serviceAttachment != null) {
      files['service_attachment_0'] = serviceAttachment;
      body['attachment_count'] = '1';
    }

    try {
      final res = await _api.requestWithFiles(
        endpoint: '/service-save', 
        fields: body,
        files: files.isNotEmpty ? files : null,
      );
      if (res is Map && (res['status'] == 1 || res['status'] == true || res['service_id'] != null)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Service added successfully', backgroundColor: Colors.green, textColor: Colors.white);
        await fetchServices();
        Get.back();
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to add service', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }

  Future<void> updateService(int id, {
    required String name,
    required String description,
    required String categoryId,
    String? subcategoryId,
    required double price,
    required String priceType,
    String? duration,
    double? discount,
    required String status,
    String? visitType,
    String? selectAddress,
    String? providerAddressId,
    bool isFeatured = false,
    bool timeslot = false,
    bool advancedPayment = false,
    double? advancedPaymentAmount,
    PlatformFile? serviceAttachment,
  }) async {
    final body = <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'price': price,
      'type': priceType.toLowerCase(),
      'status': status.toUpperCase() == 'ACTIVE' ? '1' : '0',
    };
    if (subcategoryId != null && subcategoryId.isNotEmpty) body['subcategory_id'] = subcategoryId;
    if (duration != null) body['duration'] = duration;
    
    // Additional keys that were in the original code, adapted if needed
    if (discount != null) body['discount'] = discount;
    if (visitType != null) body['visit_type'] = visitType.toLowerCase();
    if (selectAddress != null) body['selectAddress'] = selectAddress;
    if (providerAddressId != null && providerAddressId != '0') body['provider_address_id'] = [providerAddressId];
    body['is_featured'] = isFeatured ? 1 : 0;
    body['is_slot'] = timeslot ? 1 : 0;
    body['is_enable_advance_payment'] = advancedPayment ? 1 : 0;
    if (advancedPayment) {
      if (advancedPaymentAmount != null) body['advance_payment_amount'] = advancedPaymentAmount;
    }

    final Map<String, dynamic> files = {};
    if (serviceAttachment != null) {
      files['service_attachment_0'] = serviceAttachment;
      body['attachment_count'] = '1';
    }

    try {
      final res = await _api.requestWithFiles(
        endpoint: '/service-save',
        fields: body,
        files: files.isNotEmpty ? files : null,
      );
      if (res is Map && (res['status'] == 1 || res['status'] == true || res['service_id'] != null)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Service updated successfully', backgroundColor: Colors.green, textColor: Colors.white);
        await fetchServices();
        Get.back();
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to update service', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }

  Future<void> deleteService(int id) async {
    try {
      final res = await _api.post(endpoint: '/service-delete/$id');
      if (res is Map && (res['status'] == 1 || res['status'] == true)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Service deleted successfully', backgroundColor: Colors.green, textColor: Colors.white);
        state = state.copyWith(
          services: state.services.where((s) => s.id != id).toList(),
        );
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to delete service', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }

  Future<Map<String, dynamic>?> getServiceDetail(int id) async {
    final res = await _api.post(endpoint: '/service-detail', body: {'service_id': id});
    if (res != null && res['status'] == 1 && res['data'] != null) {
      return res['data'];
    } else if (res != null && res['data'] == null) {
      return res; // Sometimes the response itself is the data without a nested data wrapper
    }
    return null;
  }

  Future<void> refresh() async => fetchServices();
}

final serviceProvider = NotifierProvider<ServiceNotifier, ServiceState>(() => ServiceNotifier());
