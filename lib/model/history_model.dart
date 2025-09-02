class HistoryItem {
  final String id;
  final String code;
  final String? editCode, type;
  final String createdAt;

  HistoryItem({
    required this.id,
    required this.code,
    this.editCode, this.type,
    required this.createdAt,
  });

  // Convert a HistoryItem object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'createdAt': createdAt,
      'editCode': editCode,
      'type': type,
    };
  }

  // Convert a Map into a HistoryItem object
  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['_id'] ?? "",
      code: map['code'] ?? "",
      editCode: map['editCode'] ?? "",
      type: map['type'] ?? "",
      createdAt: map['createdAt'] ?? "",
    );
  }
}
