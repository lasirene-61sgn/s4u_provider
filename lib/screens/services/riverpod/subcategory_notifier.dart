import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../model/subcategory_model.dart';

class SubCategoryState {
  final List<SubCategoryModel> subcategories;
  final bool isLoading;
  final String? error;

  SubCategoryState({
    this.subcategories = const [],
    this.isLoading = false,
    this.error,
  });

  SubCategoryState copyWith({
    List<SubCategoryModel>? subcategories,
    bool? isLoading,
    String? error,
  }) {
    return SubCategoryState(
      subcategories: subcategories ?? this.subcategories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SubCategoryNotifier extends Notifier<SubCategoryState> {
  @override
  SubCategoryState build() {
    return SubCategoryState();
  }

  Future<void> loadSubCategoriesByCategory(String categoryId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.subcategoriesByCategory(categoryId)}'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded is List ? decoded : (decoded['data'] ?? []);
        final subcategories = data.map((e) => SubCategoryModel.fromJson(e)).toList();
        state = state.copyWith(subcategories: subcategories, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load subcategories');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = SubCategoryState();
  }
}

final subCategoryProvider = NotifierProvider<SubCategoryNotifier, SubCategoryState>(() => SubCategoryNotifier());
