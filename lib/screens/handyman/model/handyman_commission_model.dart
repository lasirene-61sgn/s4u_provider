class HandymanCommissionModel {
  final int id;
  final String name;
  final double commission;
  final String type; // percent, fixed
  final int status;
  final String? createdAt;

  HandymanCommissionModel({
    required this.id,
    required this.name,
    required this.commission,
    this.type = 'percent',
    this.status = 1,
    this.createdAt,
  });

  HandymanCommissionModel copyWith({
    int? id,
    String? name,
    double? commission,
    String? type,
    int? status,
    String? createdAt,
  }) {
    return HandymanCommissionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      commission: commission ?? this.commission,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory HandymanCommissionModel.fromJson(Map<String, dynamic> json) {
    return HandymanCommissionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      commission: double.tryParse(json['commission']?.toString() ?? '0') ?? 0.0,
      type: json['type']?.toString() ?? 'percent',
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '1') ?? 1,
      createdAt: json['created_at']?.toString(),
    );
  }
}
