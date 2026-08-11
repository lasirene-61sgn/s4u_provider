class BankModel {
  final int id;
  final int providerId;
  final String bankName;
  final String branchName;
  final String accountNo;
  final String? ifscNo;
  final String? mobileNo;
  final String? aadharNo;
  final String? panNo;
  final int isDefault;
  final int status;

  BankModel({
    required this.id,
    required this.providerId,
    required this.bankName,
    required this.branchName,
    required this.accountNo,
    this.ifscNo,
    this.mobileNo,
    this.aadharNo,
    this.panNo,
    this.isDefault = 0,
    this.status = 1,
  });

  BankModel copyWith({
    int? id,
    int? providerId,
    String? bankName,
    String? branchName,
    String? accountNo,
    String? ifscNo,
    String? mobileNo,
    String? aadharNo,
    String? panNo,
    int? isDefault,
    int? status,
  }) {
    return BankModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      accountNo: accountNo ?? this.accountNo,
      ifscNo: ifscNo ?? this.ifscNo,
      mobileNo: mobileNo ?? this.mobileNo,
      aadharNo: aadharNo ?? this.aadharNo,
      panNo: panNo ?? this.panNo,
      isDefault: isDefault ?? this.isDefault,
      status: status ?? this.status,
    );
  }

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'] ?? 0,
      providerId: json['provider_id'] ?? 0,
      bankName: json['bank_name']?.toString() ?? '',
      branchName: json['branch_name']?.toString() ?? '',
      accountNo: json['account_no']?.toString() ?? '',
      ifscNo: json['ifsc_no']?.toString(),
      mobileNo: json['mobile_no']?.toString(),
      aadharNo: json['aadhar_no']?.toString(),
      panNo: json['pan_no']?.toString(),
      isDefault: json['is_default'] ?? 0,
      status: json['status'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'bank_name': bankName,
      'branch_name': branchName,
      'account_no': accountNo,
      'ifsc_no': ifscNo,
      'mobile_no': mobileNo,
      'aadhar_no': aadharNo,
      'pan_no': panNo,
      'is_default': isDefault,
      'status': status,
    };
  }
}
