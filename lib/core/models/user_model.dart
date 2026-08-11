class UserModel {
  final int id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? userType;
  final String? contactNumber;
  final int? providerId;
  final int? status;
  final String? displayName;
  final String? apiToken;
  final String? profileImage;
  final int? isVerifyProvider;

  UserModel({
    required this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.userType,
    this.contactNumber,
    this.providerId,
    this.status,
    this.displayName,
    this.apiToken,
    this.profileImage,
    this.isVerifyProvider,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email']?.toString(),
      userType: json['user_type']?.toString(),
      contactNumber: json['contact_number']?.toString(),
      providerId: (json['provider_id'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      displayName: json['display_name']?.toString(),
      apiToken: json['api_token']?.toString(),
      profileImage: json['profile_image']?.toString(),
      isVerifyProvider: (json['is_verify_provider'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'user_type': userType,
      'contact_number': contactNumber,
      'provider_id': providerId,
      'status': status,
      'display_name': displayName,
      'api_token': apiToken,
      'profile_image': profileImage,
      'is_verify_provider': isVerifyProvider,
    };
  }
}
