class PostJobService {
  final int id;
  final String name;
  final String? description;
  final String? categoryName;
  final String? subcategoryName;
  final List<String> attachments;
  final double? price;
  final String? priceFormat;
  final String? visitType;
  final String? type;
  final String? duration;

  PostJobService({
    required this.id,
    required this.name,
    this.description,
    this.categoryName,
    this.subcategoryName,
    this.attachments = const [],
    this.price,
    this.priceFormat,
    this.visitType,
    this.type,
    this.duration,
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
      description: json['description']?.toString(),
      categoryName: json['category_name']?.toString(),
      subcategoryName: json['subcategory_name']?.toString(),
      attachments: atts,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      priceFormat: json['price_format']?.toString(),
      visitType: json['visit_type']?.toString(),
      type: json['type']?.toString(),
      duration: json['duration']?.toString(),
    );
  }
}

class PostJob {
  final int id;
  final String title;
  final String? description;
  final String? reason;
  final double price;
  final String status;
  final bool canBid;
  final int? providerId;
  final int? customerId;
  final String? customerName;
  final String? customerProfile;
  final List<PostJobService> services;
  final String? createdAt;
  final double? jobPrice;

  PostJob({
    required this.id,
    required this.title,
    this.description,
    this.reason,
    required this.price,
    required this.status,
    required this.canBid,
    this.providerId,
    this.customerId,
    this.customerName,
    this.customerProfile,
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
      reason: json['reason']?.toString(),
      price: (json['price'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'requested',
      canBid: json['can_bid'] == true,
      providerId: json['provider_id'] != null ? int.tryParse(json['provider_id'].toString()) : null,
      customerId: json['customer_id'] != null ? int.tryParse(json['customer_id'].toString()) : null,
      customerName: json['customer_name']?.toString(),
      customerProfile: json['customer_profile']?.toString(),
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
  final String? duration;
  final String? providerName;
  final String? providerImage;

  BidItem({
    required this.id,
    required this.postJobId,
    required this.providerId,
    required this.amount,
    this.note,
    required this.status,
    this.duration,
    this.providerName,
    this.providerImage,
  });

  factory BidItem.fromJson(Map<String, dynamic> json) {
    String? pName;
    String? pImage;
    if (json['provider'] is Map) {
      final pMap = json['provider'];
      pName = pMap['display_name']?.toString() ?? 
              '${pMap['first_name'] ?? ''} ${pMap['last_name'] ?? ''}'.trim();
      if (pName.isEmpty) pName = null;
      pImage = pMap['profile_image']?.toString();
    }

    return BidItem(
      id: json['id'] ?? 0,
      postJobId: json['post_request_id'] ?? json['post_job_id'] ?? 0,
      providerId: json['provider_id'] ?? 0,
      amount: (json['price'] ?? json['amount'] ?? 0).toDouble(),
      note: json['note']?.toString(),
      status: json['status']?.toString() ?? 'requested',
      duration: json['duration']?.toString(),
      providerName: pName,
      providerImage: pImage,
    );
  }
}
