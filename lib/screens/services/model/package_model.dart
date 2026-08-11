class PackageModel {
  final int? id;
  final String name;
  final String? description;
  final String? packageType;
  final int? categoryId;
  final int? subCategoryId;
  final int? serviceId;
  final double? price;
  final bool isFeatured;
  final String status;
  final String? imageUrl;

  PackageModel({
    this.id,
    required this.name,
    this.description,
    this.packageType,
    this.categoryId,
    this.subCategoryId,
    this.serviceId,
    this.price,
    this.isFeatured = false,
    this.status = 'ACTIVE',
    this.imageUrl,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    final List? services = json['services'] as List?;
    final Map<String, dynamic>? firstService = services != null && services.isNotEmpty ? services[0] : null;

    return PackageModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      packageType: json['package_type'] ?? json['packageType'],
      categoryId: json['category_id'] ?? json['categoryId'] ?? firstService?['category_id'],
      subCategoryId: json['subcategory_id'] ?? json['subCategoryId'] ?? firstService?['subcategory_id'],
      serviceId: json['service_id'] ?? json['serviceId'] ?? firstService?['id'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      isFeatured: (json['is_featured'] == 1 || json['isFeatured'] == true || json['is_featured'] == true || json['is_featured'] == '1'),
      status: json['status']?.toString() == '1' ? 'ACTIVE' : (json['status']?.toString() == '0' ? 'INACTIVE' : json['status']?.toString() ?? 'ACTIVE'),
      imageUrl: json['package_image'] ?? json['imageUrl'] ?? (json['attchments'] != null && (json['attchments'] as List).isNotEmpty ? json['attchments'][0] : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (packageType != null) 'package_type': packageType,
      if (categoryId != null) 'category_id': categoryId,
      if (subCategoryId != null) 'subcategory_id': subCategoryId,
      if (serviceId != null) 'service_id[0]': serviceId,
      if (price != null) 'price': price,
      'is_featured': isFeatured ? 1 : 0,
      'status': status == 'ACTIVE' ? 1 : 0,
      if (imageUrl != null) 'package_image': imageUrl,
    };
  }

  PackageModel copyWith({
    int? id,
    String? name,
    String? description,
    String? packageType,
    int? categoryId,
    int? subCategoryId,
    int? serviceId,
    double? price,
    bool? isFeatured,
    String? status,
    String? imageUrl,
  }) {
    return PackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      packageType: packageType ?? this.packageType,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      serviceId: serviceId ?? this.serviceId,
      price: price ?? this.price,
      isFeatured: isFeatured ?? this.isFeatured,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
