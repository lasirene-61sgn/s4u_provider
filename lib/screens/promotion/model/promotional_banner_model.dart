class PromotionalBannerModel {
  final int? id;
  final String title;
  final String? startDate;
  final String? endDate;
  final String? bannerType;
  final String? serviceId;
  final String? description;
  final String? bannerAttachment;
  final String status;

  PromotionalBannerModel({
    this.id,
    required this.title,
    this.startDate,
    this.endDate,
    this.bannerType,
    this.serviceId,
    this.description,
    this.bannerAttachment,
    this.status = 'ACTIVE',
  });

  factory PromotionalBannerModel.fromJson(Map<String, dynamic> json) {
    return PromotionalBannerModel(
      id: json['id'],
      title: json['title'] ?? '',
      startDate: json['start_date'],
      endDate: json['end_date'],
      bannerType: json['banner_type'],
      serviceId: json['service_id']?.toString(),
      description: json['description'],
      bannerAttachment: json['banner_attachment'] ?? json['banner_image'] ?? json['image'],
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (bannerType != null) 'banner_type': bannerType,
      if (serviceId != null) 'service_id': serviceId,
      if (description != null) 'description': description,
      // bannerAttachment is usually handled via requestWithFiles
      'status': status,
    };
  }

  PromotionalBannerModel copyWith({
    int? id,
    String? title,
    String? startDate,
    String? endDate,
    String? bannerType,
    String? serviceId,
    String? description,
    String? bannerAttachment,
    String? status,
  }) {
    return PromotionalBannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      bannerType: bannerType ?? this.bannerType,
      serviceId: serviceId ?? this.serviceId,
      description: description ?? this.description,
      bannerAttachment: bannerAttachment ?? this.bannerAttachment,
      status: status ?? this.status,
    );
  }
}
