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
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      address: json['address'],
      countryId: json['country_id'],
      stateId: json['state_id'],
      cityId: json['city_id'],
      cityName: json['city_name'],
      serviceAddressId: json['service_address_id'],
      handymanCommission: json['handyman_commission'],
      status: json['status'] ?? 0,
      profileImage: json['profile_image'],
      isHandymanAvailable: json['isHandymanAvailable'],
      whyChooseMeTitle: wTitle,
      whyChooseMeDescription: wDesc,
      whyChooseMeReasons: wReasons,
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
    );
  }
}
