class DocumentTypeModel {
  final int id;
  final String name;
  final int status;
  final int isRequired;

  DocumentTypeModel({
    required this.id,
    required this.name,
    required this.status,
    required this.isRequired,
  });

  DocumentTypeModel copyWith({
    int? id,
    String? name,
    int? status,
    int? isRequired,
  }) {
    return DocumentTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      isRequired: isRequired ?? this.isRequired,
    );
  }

  factory DocumentTypeModel.fromJson(Map<String, dynamic> json) {
    return DocumentTypeModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      isRequired: json['is_required'] is int ? json['is_required'] : int.tryParse(json['is_required']?.toString() ?? '0') ?? 0,
    );
  }
}

class DocumentModel {
  final int id;
  final int? providerId;
  final int? documentId;
  final String documentName;
  final String providerDocument;
  final int isVerified;
  final String? deletedAt;

  DocumentModel({
    required this.id,
    this.providerId,
    this.documentId,
    required this.documentName,
    required this.providerDocument,
    required this.isVerified,
    this.deletedAt,
  });

  DocumentModel copyWith({
    int? id,
    int? providerId,
    int? documentId,
    String? documentName,
    String? providerDocument,
    int? isVerified,
    String? deletedAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      documentId: documentId ?? this.documentId,
      documentName: documentName ?? this.documentName,
      providerDocument: providerDocument ?? this.providerDocument,
      isVerified: isVerified ?? this.isVerified,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      providerId: json['provider_id'] is int ? json['provider_id'] : int.tryParse(json['provider_id']?.toString() ?? ''),
      documentId: json['document_id'] is int ? json['document_id'] : int.tryParse(json['document_id']?.toString() ?? ''),
      documentName: json['document_name']?.toString() ?? json['document']?['name']?.toString() ?? '',
      providerDocument: json['provider_document']?.toString() ?? '',
      isVerified: json['is_verified'] is int ? json['is_verified'] : int.tryParse(json['is_verified']?.toString() ?? '0') ?? 0,
      deletedAt: json['deleted_at']?.toString(),
    );
  }
}
