class SlotModel {
  final String day;
  final List<String> times;

  SlotModel({
    required this.day,
    required this.times,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      day: json['day']?.toString() ?? '',
      times: (json['slot'] as List<dynamic>?)?.map((e) {
        final t = e.toString();
        return t.length >= 5 ? t.substring(0, 5) : t;
      }).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'slot': times,
    };
  }

  SlotModel copyWith({
    String? day,
    List<String>? times,
  }) {
    return SlotModel(
      day: day ?? this.day,
      times: times ?? this.times,
    );
  }
}
