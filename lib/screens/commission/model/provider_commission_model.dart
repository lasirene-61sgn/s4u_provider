class ProviderCommissionModel {
  final int id;
  final String name;
  final double commission;
  final String type;
  final int status;
  final String? createdAt;

  ProviderCommissionModel({
    required this.id,
    required this.name,
    required this.commission,
    required this.type,
    required this.status,
    this.createdAt,
  });

  factory ProviderCommissionModel.fromJson(Map<String, dynamic> json) {
    return ProviderCommissionModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      commission: (json['commission'] ?? 0).toDouble(),
      type: json['type'] ?? 'percent',
      status: json['status'] ?? 1,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'commission': commission,
      'type': type,
      'status': status,
    };
  }
}
