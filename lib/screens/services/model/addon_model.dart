class AddonModel {
  final int id;
  final String name;
  final int? serviceId;
  final String? serviceName;
  final double price;
  final String status;
  final String? imageUrl;
  final String? translations;

  AddonModel({
    required this.id,
    required this.name,
    this.serviceId,
    this.serviceName,
    required this.price,
    this.status = 'ACTIVE',
    this.imageUrl,
    this.translations,
  });

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    String parsedStatus = json['status']?.toString() == '1' ? 'ACTIVE' : (json['status']?.toString() == '0' ? 'INACTIVE' : json['status']?.toString() ?? 'ACTIVE');
    return AddonModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      serviceId: json['service_id'],
      serviceName: json['service_name']?.toString(),
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      status: parsedStatus,
      imageUrl: json['serviceaddon_image']?.toString(),
      translations: json['translations']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'service_id': serviceId,
      'service_name': serviceName,
      'price': price,
      'status': status == 'ACTIVE' ? 1 : 0,
      'serviceaddon_image': imageUrl,
      'translations': translations,
    };
  }

  AddonModel copyWith({
    int? id,
    String? name,
    int? serviceId,
    String? serviceName,
    double? price,
    String? status,
    String? imageUrl,
    String? translations,
  }) {
    return AddonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      translations: translations ?? this.translations,
    );
  }
}
