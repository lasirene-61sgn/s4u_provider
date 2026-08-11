class AddressModel {
  final int id;
  final int providerId;
  final String address;
  final String latitude;
  final String longitude;
  final int status;

  AddressModel({
    required this.id,
    required this.providerId,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    int parsedStatus = 0;
    if (json['status'] is int) {
      parsedStatus = json['status'];
    } else if (json['status']?.toString() == 'Active') {
      parsedStatus = 1;
    } else if (json['status']?.toString() == '1') {
      parsedStatus = 1;
    }

    return AddressModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      providerId: json['provider_id'] is int ? json['provider_id'] : int.tryParse(json['provider_id']?.toString() ?? '0') ?? 0,
      address: json['address']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      status: parsedStatus,
    );
  }
}
