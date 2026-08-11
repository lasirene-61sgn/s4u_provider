class BookingStatusModel {
  final int id;
  final String? value;
  final String? label;
  final int? status;
  final int? sequence;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;

  BookingStatusModel({
    required this.id,
    this.value,
    this.label,
    this.status,
    this.sequence,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingStatusModel.fromJson(Map<String, dynamic> json) {
    return BookingStatusModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      value: json['value']?.toString(),
      label: json['label']?.toString(),
      status: (json['status'] as num?)?.toInt(),
      sequence: (json['sequence'] as num?)?.toInt(),
      deletedAt: json['deleted_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'label': label,
      'status': status,
      'sequence': sequence,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
