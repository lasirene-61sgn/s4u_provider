class Profile {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String role;
  final String? profileImage;
  
  // Provider/Handyman fields
  final String? companyName;
  final String? gstNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? selectAddress;
  final String? handymanCommission;
  final String? providerStatus;
  final String? whyChooseMeTitle;
  final String? whyChooseMeDescription;
  final List<String>? whyChooseMeReasons;

  Profile({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.role,
    this.profileImage,
    this.companyName,
    this.gstNumber,
    this.address,
    this.city,
    this.state,
    this.country,
    this.selectAddress,
    this.handymanCommission,
    this.providerStatus,
    this.whyChooseMeTitle,
    this.whyChooseMeDescription,
    this.whyChooseMeReasons,
  });

  Profile copyWith({
    int? id, String? username, String? firstName, String? lastName, String? email, String? mobile, String? role, String? profileImage,
    String? companyName, String? gstNumber, String? address, String? city, String? state,
    String? country, String? selectAddress, String? handymanCommission, String? providerStatus,
    String? whyChooseMeTitle, String? whyChooseMeDescription, List<String>? whyChooseMeReasons,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      companyName: companyName ?? this.companyName,
      gstNumber: gstNumber ?? this.gstNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      selectAddress: selectAddress ?? this.selectAddress,
      handymanCommission: handymanCommission ?? this.handymanCommission,
      providerStatus: providerStatus ?? this.providerStatus,
      whyChooseMeTitle: whyChooseMeTitle ?? this.whyChooseMeTitle,
      whyChooseMeDescription: whyChooseMeDescription ?? this.whyChooseMeDescription,
      whyChooseMeReasons: whyChooseMeReasons ?? this.whyChooseMeReasons,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    String roleStr = '';
    if (json['role'] is Map) {
      roleStr = json['role']['roleName'] ?? '';
    } else if (json['role'] is String) {
      roleStr = json['role'];
    }

    return Profile(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile']?.toString() ?? json['contact_number']?.toString() ?? '',
      role: roleStr.isNotEmpty ? roleStr : (json['user_type'] ?? ''),
      profileImage: json['profileImage'] ?? json['profile_image'],
      companyName: json['companyName'] ?? json['providertype'],
      gstNumber: json['gstNumber'],
      address: json['address'],
      city: json['city'] ?? json['city_name'],
      state: json['state'],
      country: json['country'],
      selectAddress: json['selectAddress'],
      handymanCommission: json['handymanCommission']?.toString() ?? json['handyman_commission']?.toString(),
      providerStatus: json['providerStatus'],
      whyChooseMeTitle: json['whyChooseMeTitle'],
      whyChooseMeDescription: json['whyChooseMeDescription'],
      whyChooseMeReasons: json['whyChooseMeReasons'] != null 
          ? List<String>.from(json['whyChooseMeReasons']) 
          : null,
    );
  }
}
