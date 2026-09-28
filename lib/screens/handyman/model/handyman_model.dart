class Handyman {
  final int id;
  final String name;
  final String country;
  final String state;
  final String city;
  final String address;
  final String email;
  final String mobile;
  final String? selectAddress;
  final String? handymanCommission;
  final String? status;
  final String? profileImage;
  final String? createdAt;
  final String? approvedDate;
  final String? providerName;
  final String? providerEmail;

  Handyman({
    required this.id, 
    required this.name, 
    this.country = '',
    this.state = '',
    this.city = '',
    this.address = '',
    this.email = '',
    this.mobile = '',
    this.selectAddress,
    this.handymanCommission,
    this.status,
    this.profileImage,
    this.createdAt,
    this.approvedDate,
    this.providerName,
    this.providerEmail,
  });

  Handyman copyWith({
    int? id, String? name, String? country, String? state, String? city, String? address, String? email, String? mobile, String? selectAddress, String? handymanCommission, String? status, String? profileImage, String? createdAt, String? approvedDate, String? providerName, String? providerEmail
  }) {
    return Handyman(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      address: address ?? this.address,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      selectAddress: selectAddress ?? this.selectAddress,
      handymanCommission: handymanCommission ?? this.handymanCommission,
      status: status ?? this.status,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      approvedDate: approvedDate ?? this.approvedDate,
      providerName: providerName ?? this.providerName,
      providerEmail: providerEmail ?? this.providerEmail,
    );
  }

  factory Handyman.fromJson(Map<String, dynamic> json) {
    String parsedName = '';
    String parsedEmail = '';
    String parsedMobile = '';
    if (json['user'] is Map) {
      final fName = json['user']['firstName']?.toString() ?? '';
      final lName = json['user']['lastName']?.toString() ?? '';
      parsedName = '$fName $lName'.trim();
      parsedEmail = json['user']['email']?.toString() ?? '';
      parsedMobile = json['user']['mobile']?.toString() ?? '';
    } else {
      final fName = json['first_name']?.toString() ?? '';
      final lName = json['last_name']?.toString() ?? '';
      parsedName = (fName.isNotEmpty || lName.isNotEmpty) ? '$fName $lName'.trim() : json['name']?.toString() ?? '';
      parsedEmail = json['email']?.toString() ?? '';
      parsedMobile = json['contact_number']?.toString() ?? json['mobile']?.toString() ?? '';
    }

    return Handyman(
      id: json['id'] ?? 0,
      name: parsedName.isEmpty ? 'Member #${json['id']}' : parsedName,
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      city: json['city_name']?.toString() ?? json['city']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      handymanCommission: json['handymantype_id']?.toString() ?? json['handyman_commission']?.toString() ?? json['handymanCommission']?.toString() ?? json['userCommission']?.toString(),
      email: parsedEmail,
      mobile: parsedMobile,
      selectAddress: json['selectAddress']?.toString(),
      status: () {
        final s = json['status'];
        if (s == 1 || s == '1') return 'ACTIVE';
        if (s == 0 || s == '0') return 'INACTIVE';
        return s?.toString();
      }(),
      profileImage: json['profile_image']?.toString() ?? json['profileImage']?.toString() ?? (json['user'] is Map ? json['user']['profileImage']?.toString() : null),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
      approvedDate: json['approvedDate']?.toString() ?? json['created_at']?.toString() ?? json['createdAt']?.toString(),
      providerName: () {
        if (json['provider'] is Map && json['provider']['user'] is Map) {
          final fn = json['provider']['user']['firstName']?.toString() ?? '';
          final ln = json['provider']['user']['lastName']?.toString() ?? '';
          return '$fn $ln'.trim();
        }
        return null;
      }(),
      providerEmail: json['provider'] is Map && json['provider']['user'] is Map
          ? json['provider']['user']['email']?.toString()
          : null,
    );
  }
}
