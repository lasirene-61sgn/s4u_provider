class PostJobService {
  final int id;
  final String name;
  final String? categoryName;
  final String? subcategoryName;
  final List<String> attachments;
  final String? priceFormat;
  final String? visitType;

  PostJobService({
    required this.id,
    required this.name,
    this.categoryName,
    this.subcategoryName,
    this.attachments = const [],
    this.priceFormat,
    this.visitType,
  });

  factory PostJobService.fromJson(Map<String, dynamic> json) {
    final List<String> atts = [];
    if (json['attchments'] is List) {
      for (final a in json['attchments']) {
        if (a is String) atts.add(a);
      }
    }
    return PostJobService(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      categoryName: json['category_name']?.toString(),
      subcategoryName: json['subcategory_name']?.toString(),
      attachments: atts,
      priceFormat: json['price_format']?.toString(),
      visitType: json['visit_type']?.toString(),
    );
  }
}

class PostJob {
  final int id;
  final String title;
  final String? description;
  final double price;
  final String status;
  final bool canBid;
  final int? customerId;
  final List<PostJobService> services;
  final String? createdAt;
  final double? jobPrice;

  PostJob({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    required this.status,
    required this.canBid,
    this.customerId,
    this.services = const [],
    this.createdAt,
    this.jobPrice,
  });

  factory PostJob.fromJson(Map<String, dynamic> json) {
    final List<PostJobService> svcs = [];
    if (json['service'] is List) {
      for (final s in json['service']) {
        svcs.add(PostJobService.fromJson(s));
      }
    }
    return PostJob(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      price: (json['price'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'requested',
      canBid: json['can_bid'] == true,
      customerId: json['customer_id'],
      services: svcs,
      createdAt: json['created_at']?.toString(),
      jobPrice: json['job_price'] != null ? (json['job_price']).toDouble() : null,
    );
  }
}

class JobStatusOption {
  final int id;
  final String value;
  final String label;

  JobStatusOption({required this.id, required this.value, required this.label});

  factory JobStatusOption.fromJson(Map<String, dynamic> json) {
    return JobStatusOption(
      id: json['id'] ?? 0,
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

class BidItem {
  final int id;
  final int postJobId;
  final int providerId;
  final double amount;
  final String? note;
  final String status;

  BidItem({
    required this.id,
    required this.postJobId,
    required this.providerId,
    required this.amount,
    this.note,
    required this.status,
  });

  factory BidItem.fromJson(Map<String, dynamic> json) {
    return BidItem(
      id: json['id'] ?? 0,
      postJobId: json['post_job_id'] ?? 0,
      providerId: json['provider_id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      note: json['note']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }
}
