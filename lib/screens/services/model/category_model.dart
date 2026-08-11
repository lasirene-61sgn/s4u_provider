class CategoryModel {
  final int id;
  final String name;
  final String status;
  final String? imageUrl;
  final bool isFeatured;
  final String? commissionType;
  final double? commissionValue;

  CategoryModel({
    required this.id,
    required this.name,
    required this.status,
    this.imageUrl,
    this.isFeatured = false,
    this.commissionType,
    this.commissionValue,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      status: json['status']?.toString() == '1' ? 'ACTIVE' : (json['status']?.toString() == '0' ? 'INACTIVE' : json['status']?.toString() ?? 'ACTIVE'),
      imageUrl: json['imageUrl'],
      isFeatured: json['isFeatured'] ?? false,
      commissionType: json['commissionType'],
      commissionValue: json['commissionValue'] != null ? (json['commissionValue'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'imageUrl': imageUrl,
      'isFeatured': isFeatured,
      'commissionType': commissionType,
      'commissionValue': commissionValue,
    };
  }
}
