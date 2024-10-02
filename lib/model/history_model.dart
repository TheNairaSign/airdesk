class HistoryItem {
  final String id;
  final String code;
  final String createdAt;

  HistoryItem({
    required this.id,
    required this.code,
    required this.createdAt,
  });

  // Convert a HistoryItem object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'createdAt': createdAt,
    };
  }

  // Convert a Map into a HistoryItem object
  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['_id'] ?? "Id is null",
      code: map['code'] ?? "code is null",
      createdAt: map['createdAt'] ?? "created date not available",
    );
  }
}
