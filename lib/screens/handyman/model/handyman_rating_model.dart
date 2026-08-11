class HandymanRatingModel {
  final int id;
  final String handymanName;
  final String? handymanImage;
  final String customerName;
  final double rating;
  final String review;
  final String createdAt;

  HandymanRatingModel({
    required this.id,
    required this.handymanName,
    this.handymanImage,
    required this.customerName,
    required this.rating,
    required this.review,
    required this.createdAt,
  });

  HandymanRatingModel copyWith({
    int? id,
    String? handymanName,
    String? handymanImage,
    String? customerName,
    double? rating,
    String? review,
    String? createdAt,
  }) {
    return HandymanRatingModel(
      id: id ?? this.id,
      handymanName: handymanName ?? this.handymanName,
      handymanImage: handymanImage ?? this.handymanImage,
      customerName: customerName ?? this.customerName,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory HandymanRatingModel.fromJson(Map<String, dynamic> json) {
    return HandymanRatingModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      handymanName: json['handyman_name']?.toString() ?? 'N/A',
      handymanImage: json['handyman_profile_image']?.toString(),
      customerName: json['customer_name']?.toString() ?? 'Customer',
      rating: double.tryParse(json['rating']?.toString() ?? '5') ?? 5.0,
      review: json['review']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
