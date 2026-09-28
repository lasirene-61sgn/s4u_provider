import 'dart:convert';

class HandymanDetailResponse {
  final HandymanDetail data;

  HandymanDetailResponse({required this.data});

  factory HandymanDetailResponse.fromJson(Map<String, dynamic> json) {
    dynamic innerData = json['data'] ?? {};
    if (innerData is Map && innerData.containsKey('data')) {
      innerData = innerData['data'];
    }
    return HandymanDetailResponse(
      data: HandymanDetail.fromJson(innerData ?? {}),
    );
  }
}

class HandymanDetail {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String contactNumber;
  final String? address;
  final int? countryId;
  final int? stateId;
  final int? cityId;
  final String? cityName;
  final int? serviceAddressId;
  final String? handymanCommission;
  final int status;
  final String? profileImage;
  final int? isHandymanAvailable;
  final String? whyChooseMeTitle;
  final String? whyChooseMeDescription;
  final List<String>? whyChooseMeReasons;
  final String? designation;
  final dynamic knownLanguages;
  final dynamic skills;
  final num? handymanRating;
  final num? providersServiceRating;
  final int? totalServicesBooked;
  final int? isVerifyProvider;
  final int? isFavourite;
  final String? createdAt;

  HandymanDetail({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.contactNumber,
    this.address,
    this.countryId,
    this.stateId,
    this.cityId,
    this.cityName,
    this.serviceAddressId,
    this.handymanCommission,
    required this.status,
    this.profileImage,
    this.isHandymanAvailable,
    this.whyChooseMeTitle,
    this.whyChooseMeDescription,
    this.whyChooseMeReasons,
    this.designation,
    this.knownLanguages,
    this.skills,
    this.handymanRating,
    this.providersServiceRating,
    this.totalServicesBooked,
    this.isVerifyProvider,
    this.isFavourite,
    this.createdAt,
  });

  factory HandymanDetail.fromJson(Map<String, dynamic> json) {
    String? wTitle;
    String? wDesc;
    List<String>? wReasons;

    if (json['why_choose_me'] != null) {
      Map<String, dynamic>? whyChooseMeMap;
      
      if (json['why_choose_me'] is String) {
        try {
          whyChooseMeMap = jsonDecode(json['why_choose_me']);
        } catch (e) {
          whyChooseMeMap = null;
        }
      } else if (json['why_choose_me'] is Map) {
        whyChooseMeMap = json['why_choose_me'] as Map<String, dynamic>?;
      }

      if (whyChooseMeMap != null) {
        wTitle = whyChooseMeMap['title']?.toString();
        wDesc = whyChooseMeMap['about_description']?.toString();
        if (whyChooseMeMap['reason'] is List) {
          wReasons = (whyChooseMeMap['reason'] as List).map((e) => e.toString()).toList();
        }
      }
    }

    return HandymanDetail(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      address: json['address']?.toString(),
      countryId: json['country_id'] is int ? json['country_id'] : int.tryParse(json['country_id']?.toString() ?? ''),
      stateId: json['state_id'] is int ? json['state_id'] : int.tryParse(json['state_id']?.toString() ?? ''),
      cityId: json['city_id'] is int ? json['city_id'] : int.tryParse(json['city_id']?.toString() ?? ''),
      cityName: json['city_name']?.toString(),
      serviceAddressId: json['service_address_id'] is int ? json['service_address_id'] : int.tryParse(json['service_address_id']?.toString() ?? ''),
      handymanCommission: json['handymantype_id']?.toString() ?? json['handyman_commission']?.toString(),
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      profileImage: json['profile_image']?.toString(),
      isHandymanAvailable: json['isHandymanAvailable'] is int ? json['isHandymanAvailable'] : int.tryParse(json['isHandymanAvailable']?.toString() ?? ''),
      whyChooseMeTitle: wTitle,
      whyChooseMeDescription: wDesc,
      whyChooseMeReasons: wReasons,
      designation: json['designation'],
      knownLanguages: json['known_languages'],
      skills: json['skills'],
      handymanRating: json['handyman_rating'],
      providersServiceRating: json['providers_service_rating'],
      totalServicesBooked: json['total_services_booked'],
      isVerifyProvider: json['is_verify_provider'],
      isFavourite: json['is_favourite'],
      createdAt: json['created_at'],
    );
  }

  HandymanDetail copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? contactNumber,
    String? address,
    int? countryId,
    int? stateId,
    int? cityId,
    String? cityName,
    int? serviceAddressId,
    String? handymanCommission,
    int? status,
    String? profileImage,
    int? isHandymanAvailable,
    String? whyChooseMeTitle,
    String? whyChooseMeDescription,
    List<String>? whyChooseMeReasons,
    String? designation,
    dynamic knownLanguages,
    dynamic skills,
    num? handymanRating,
    num? providersServiceRating,
    int? totalServicesBooked,
    int? isVerifyProvider,
    int? isFavourite,
    String? createdAt,
  }) {
    return HandymanDetail(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      countryId: countryId ?? this.countryId,
      stateId: stateId ?? this.stateId,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      serviceAddressId: serviceAddressId ?? this.serviceAddressId,
      handymanCommission: handymanCommission ?? this.handymanCommission,
      status: status ?? this.status,
      profileImage: profileImage ?? this.profileImage,
      isHandymanAvailable: isHandymanAvailable ?? this.isHandymanAvailable,
      whyChooseMeTitle: whyChooseMeTitle ?? this.whyChooseMeTitle,
      whyChooseMeDescription: whyChooseMeDescription ?? this.whyChooseMeDescription,
      whyChooseMeReasons: whyChooseMeReasons ?? this.whyChooseMeReasons,
      designation: designation ?? this.designation,
      knownLanguages: knownLanguages ?? this.knownLanguages,
      skills: skills ?? this.skills,
      handymanRating: handymanRating ?? this.handymanRating,
      providersServiceRating: providersServiceRating ?? this.providersServiceRating,
      totalServicesBooked: totalServicesBooked ?? this.totalServicesBooked,
      isVerifyProvider: isVerifyProvider ?? this.isVerifyProvider,
      isFavourite: isFavourite ?? this.isFavourite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
