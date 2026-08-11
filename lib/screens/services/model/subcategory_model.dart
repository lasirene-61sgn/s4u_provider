import 'category_model.dart';

class SubCategoryModel {
  final int id;
  final String name;
  final String status;
  final CategoryModel? category;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.status,
    this.category,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      status: json['status']?.toString() == '1' ? 'ACTIVE' : (json['status']?.toString() == '0' ? 'INACTIVE' : json['status']?.toString() ?? 'ACTIVE'),
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      if (category != null) 'category': category!.toJson(),
    };
  }
}
