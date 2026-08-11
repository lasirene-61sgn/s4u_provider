import 'service_model.dart';

class ServiceDetailModel {
  final ServiceModel? serviceDetail;
  final ProviderDetail? provider;
  final List<RelatedService> relatedService;
  final List<ServiceAddon> serviceAddon;

  ServiceDetailModel({
    this.serviceDetail,
    this.provider,
    this.relatedService = const [],
    this.serviceAddon = const [],
  });

  ServiceDetailModel copyWith({
    ServiceModel? serviceDetail,
    ProviderDetail? provider,
    List<RelatedService>? relatedService,
    List<ServiceAddon>? serviceAddon,
  }) {
    return ServiceDetailModel(
      serviceDetail: serviceDetail ?? this.serviceDetail,
      provider: provider ?? this.provider,
      relatedService: relatedService ?? this.relatedService,
      serviceAddon: serviceAddon ?? this.serviceAddon,
    );
  }

  factory ServiceDetailModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailModel(
      serviceDetail: json['service_detail'] != null ? ServiceModel.fromJson(json['service_detail']) : null,
      provider: json['provider'] != null ? ProviderDetail.fromJson(json['provider']) : null,
      relatedService: json['related_service'] != null 
          ? (json['related_service'] as List).map((e) => RelatedService.fromJson(e)).toList() 
          : [],
      serviceAddon: json['serviceaddon'] != null 
          ? (json['serviceaddon'] as List).map((e) => ServiceAddon.fromJson(e)).toList() 
          : [],
    );
  }
}

class ProviderDetail {
  final int id;
  final String firstName;
  final String lastName;
  final String displayName;
  final String? email;
  final String? contactNumber;
  final String? profileImage;
  final String? designation;
  final String? cityName;
  final String? address;

  ProviderDetail({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    this.displayName = '',
    this.email,
    this.contactNumber,
    this.profileImage,
    this.designation,
    this.cityName,
    this.address,
  });

  ProviderDetail copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? displayName,
    String? email,
    String? contactNumber,
    String? profileImage,
    String? designation,
    String? cityName,
    String? address,
  }) {
    return ProviderDetail(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      profileImage: profileImage ?? this.profileImage,
      designation: designation ?? this.designation,
      cityName: cityName ?? this.cityName,
      address: address ?? this.address,
    );
  }

  factory ProviderDetail.fromJson(Map<String, dynamic> json) {
    return ProviderDetail(
      id: json['id'] ?? 0,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      email: json['email']?.toString(),
      contactNumber: json['contact_number']?.toString(),
      profileImage: json['profile_image']?.toString(),
      designation: json['designation']?.toString(),
      cityName: json['city_name']?.toString(),
      address: json['address']?.toString(),
    );
  }
}

class RelatedService {
  final int id;
  final String name;
  final double price;
  final String priceFormat;
  final String? image;

  RelatedService({
    required this.id,
    required this.name,
    required this.price,
    this.priceFormat = '',
    this.image,
  });

  RelatedService copyWith({
    int? id,
    String? name,
    double? price,
    String? priceFormat,
    String? image,
  }) {
    return RelatedService(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      priceFormat: priceFormat ?? this.priceFormat,
      image: image ?? this.image,
    );
  }

  factory RelatedService.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json['attchments'] != null && json['attchments'] is List && (json['attchments'] as List).isNotEmpty) {
      imageUrl = (json['attchments'] as List).first.toString();
    }
    
    return RelatedService(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      priceFormat: json['price_format']?.toString() ?? '',
      image: imageUrl,
    );
  }
}

class ServiceAddon {
  final int id;
  final String name;
  final double price;
  final String? image;

  ServiceAddon({
    required this.id,
    required this.name,
    required this.price,
    this.image,
  });

  ServiceAddon copyWith({
    int? id,
    String? name,
    double? price,
    String? image,
  }) {
    return ServiceAddon(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
    );
  }

  factory ServiceAddon.fromJson(Map<String, dynamic> json) {
    return ServiceAddon(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      image: json['serviceaddon_image']?.toString(),
    );
  }
}
