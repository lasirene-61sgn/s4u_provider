class HelpDeskTicket {
  final int id;
  final String subject;
  final String description;
  final String status;
  final String createdAt;
  final String? employeeName;
  final List<String> attachments;

  HelpDeskTicket({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    this.employeeName,
    this.attachments = const [],
  });

  factory HelpDeskTicket.fromJson(Map<String, dynamic> json) {
    return HelpDeskTicket(
      id: json['id'] as int? ?? 0,
      subject: json['subject']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
      employeeName: json['employee_name']?.toString(),
      attachments: (json['attachments'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
