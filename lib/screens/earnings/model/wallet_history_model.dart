class WalletHistoryResponse {
  Pagination? pagination;
  List<WalletHistoryData>? data;
  double? availableBalance;

  WalletHistoryResponse({
    this.pagination,
    this.data,
    this.availableBalance,
  });

  factory WalletHistoryResponse.fromJson(Map<String, dynamic> json) {
    return WalletHistoryResponse(
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((i) => WalletHistoryData.fromJson(i))
              .toList()
          : null,
      availableBalance: json['available_balance']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pagination': pagination?.toJson(),
      'data': data?.map((e) => e.toJson()).toList(),
      'available_balance': availableBalance,
    };
  }
}

class Pagination {
  int? totalItems;
  int? perPage;
  int? currentPage;
  int? totalPages;
  int? from;
  int? to;
  int? nextPage;
  int? previousPage;

  Pagination({
    this.totalItems,
    this.perPage,
    this.currentPage,
    this.totalPages,
    this.from,
    this.to,
    this.nextPage,
    this.previousPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalItems: json['total_items'],
      perPage: json['per_page'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      from: json['from'],
      to: json['to'],
      nextPage: json['next_page'],
      previousPage: json['previous_page'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_items': totalItems,
      'per_page': perPage,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'from': from,
      'to': to,
      'next_page': nextPage,
      'previous_page': previousPage,
    };
  }
}

class WalletHistoryData {
  int? id;
  String? datetime;
  String? activityType;
  String? activityMessage;
  ActivityData? activityData;
  String? userImage;

  WalletHistoryData({
    this.id,
    this.datetime,
    this.activityType,
    this.activityMessage,
    this.activityData,
    this.userImage,
  });

  factory WalletHistoryData.fromJson(Map<String, dynamic> json) {
    return WalletHistoryData(
      id: json['id'],
      datetime: json['datetime'],
      activityType: json['activity_type'],
      activityMessage: json['activity_message'],
      activityData: json['activity_data'] != null
          ? ActivityData.fromJson(json['activity_data'])
          : null,
      userImage: json['user_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'datetime': datetime,
      'activity_type': activityType,
      'activity_message': activityMessage,
      'activity_data': activityData?.toJson(),
      'user_image': userImage,
    };
  }
}

class ActivityData {
  String? title;
  int? userId;
  String? providerName;
  double? amount;
  String? transactionId;
  String? transactionType;
  double? creditDebitAmount;

  ActivityData({
    this.title,
    this.userId,
    this.providerName,
    this.amount,
    this.transactionId,
    this.transactionType,
    this.creditDebitAmount,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      title: json['title'],
      userId: json['user_id'],
      providerName: json['provider_name'],
      amount: json['amount']?.toDouble(),
      transactionId: json['transaction_id'],
      transactionType: json['transaction_type'],
      creditDebitAmount: json['credit_debit_amount']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'user_id': userId,
      'provider_name': providerName,
      'amount': amount,
      'transaction_id': transactionId,
      'transaction_type': transactionType,
      'credit_debit_amount': creditDebitAmount,
    };
  }
}
