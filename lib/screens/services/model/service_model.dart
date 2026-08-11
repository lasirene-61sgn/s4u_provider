class ServiceModel {
  final int id;
  final String name;
  final String description;
  final String? categoryId;
  final String? categoryName;
  final String? subcategoryId;
  final String? subcategoryName;
  final String? image;
  final double? price;
  final String priceType;
  final String? duration;
  final double? discount;
  final String? visitType;
  final String? selectAddress;
  final String status;
  final String serviceStatus;
  final bool isFeatured;
  final bool timeslot;
  final bool advancedPayment;
  final double? advancedPaymentAmount;
  final String? createdAt;
  final String? providerName;
  final String? providerEmail;

  ServiceModel({
    required this.id,
    required this.name,
    this.description = '',
    this.categoryId,
    this.categoryName,
    this.subcategoryId,
    this.subcategoryName,
    this.image,
    this.price,
    this.priceType = 'Fixed',
    this.duration,
    this.discount,
    this.visitType,
    this.selectAddress,
    this.status = 'ACTIVE',
    this.serviceStatus = 'ACTIVE',
    this.isFeatured = false,
    this.timeslot = false,
    this.advancedPayment = false,
    this.advancedPaymentAmount,
    this.createdAt,
    this.providerName,
    this.providerEmail,
  });

  ServiceModel copyWith({
    int? id, String? name, String? description, String? categoryId, String? categoryName, String? subcategoryId, String? subcategoryName,
    String? image, double? price, String? priceType, String? duration, double? discount,
    String? visitType, String? selectAddress, String? status, String? serviceStatus, bool? isFeatured, bool? timeslot,
    bool? advancedPayment, double? advancedPaymentAmount, String? createdAt,
    String? providerName, String? providerEmail,
  }) {
    return ServiceModel(
      id: id ?? this.id, name: name ?? this.name, description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId, categoryName: categoryName ?? this.categoryName, 
      subcategoryId: subcategoryId ?? this.subcategoryId, subcategoryName: subcategoryName ?? this.subcategoryName,
      image: image ?? this.image, price: price ?? this.price, priceType: priceType ?? this.priceType,
      duration: duration ?? this.duration, discount: discount ?? this.discount,
      visitType: visitType ?? this.visitType, selectAddress: selectAddress ?? this.selectAddress,
      status: status ?? this.status, serviceStatus: serviceStatus ?? this.serviceStatus, isFeatured: isFeatured ?? this.isFeatured,
      timeslot: timeslot ?? this.timeslot, advancedPayment: advancedPayment ?? this.advancedPayment,
      advancedPaymentAmount: advancedPaymentAmount ?? this.advancedPaymentAmount,
      createdAt: createdAt ?? this.createdAt,
      providerName: providerName ?? this.providerName,
      providerEmail: providerEmail ?? this.providerEmail,
    );
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    String parsedServiceStatus = json['service_request_status']?.toString().toUpperCase() ?? '';
    if (parsedServiceStatus == 'APPROVE') parsedServiceStatus = 'APPROVED';

    String parsedStatus = json['status']?.toString() == '1' ? 'ACTIVE' : (json['status']?.toString() == '0' ? 'INACTIVE' : json['status']?.toString() ?? 'ACTIVE');
    if (parsedServiceStatus.isEmpty) parsedServiceStatus = parsedStatus;

    String? imageUrl = json['image']?.toString();
    if (json['attchments'] != null && json['attchments'] is List && (json['attchments'] as List).isNotEmpty) {
      imageUrl = (json['attchments'] as List).first.toString();
    }

    String parsedPriceType = json['type']?.toString() ?? json['priceType']?.toString() ?? 'Fixed';
    if (parsedPriceType.toLowerCase() == 'hourly') parsedPriceType = 'Hourly';
    if (parsedPriceType.toLowerCase() == 'fixed') parsedPriceType = 'Fixed';

    String parsedVisitType = json['visit_type']?.toString() ?? json['visitType']?.toString() ?? 'Online';
    if (parsedVisitType.toLowerCase() == 'online') parsedVisitType = 'Online';
    if (parsedVisitType.toLowerCase() == 'offline') parsedVisitType = 'Offline';
    if (parsedVisitType.toLowerCase() == 'both') parsedVisitType = 'Both';

    String? parsedAddress = json['selectAddress']?.toString() ?? json['address']?.toString();
    
    if (parsedAddress == null && json['provider_address_mapping'] != null) {
      if (json['provider_address_mapping'] is Map) {
        parsedAddress = json['provider_address_mapping']['address']?.toString();
      } else if (json['provider_address_mapping'] is List && (json['provider_address_mapping'] as List).isNotEmpty) {
        parsedAddress = (json['provider_address_mapping'] as List).first['address']?.toString();
      }
    }

    if (parsedAddress == null && json['service_address_mapping'] != null && json['service_address_mapping'] is List) {
      final List mapping = json['service_address_mapping'] as List;
      if (mapping.isNotEmpty && mapping.first['provider_address_mapping'] != null) {
        parsedAddress = mapping.first['provider_address_mapping']['address']?.toString();
      }
    }

    return ServiceModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? json['serviceName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? json['categoryId']?.toString(),
      categoryName: json['category_name']?.toString() ?? '',
      subcategoryId: json['subcategory_id']?.toString() ?? json['subcategoryId']?.toString(),
      subcategoryName: json['subcategory_name']?.toString() ?? '',
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : 0.0,
      priceType: parsedPriceType,
      duration: json['duration']?.toString() ?? '',
      discount: json['discount'] != null ? double.tryParse(json['discount'].toString()) : (json['discountPrice'] != null ? double.tryParse(json['discountPrice'].toString()) : 0.0),
      status: parsedStatus,
      serviceStatus: parsedServiceStatus,
      image: imageUrl,
      visitType: parsedVisitType,
      selectAddress: parsedAddress,
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == '1' || json['isFeatured'] == true || json['isFeatured'] == 'true',
      timeslot: json['is_slot'] == 1 || json['is_slot'] == '1' || json['timeslot'] == true || json['timeslot'] == 'true',
      advancedPayment: json['is_enable_advance_payment'] == 1 || json['is_enable_advance_payment'] == '1' || json['advancedPayment'] == true || json['advancedPayment'] == 'true',
      advancedPaymentAmount: json['advance_payment_amount'] != null ? double.tryParse(json['advance_payment_amount'].toString()) : (json['advancedPaymentAmount'] != null ? double.tryParse(json['advancedPaymentAmount'].toString()) : null),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
      providerName: json['provider_name']?.toString() ?? '',
      providerEmail: json['providerEmail']?.toString(),
    );
  }
}
