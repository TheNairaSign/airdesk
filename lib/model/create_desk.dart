class CreateDesk {
  final String publicCode; 
  final String adminCode;
  const CreateDesk({
    required this.publicCode,
    required this.adminCode,
  });

  factory CreateDesk.fromJson(Map<String, dynamic> json) {
    return CreateDesk(
      publicCode: json['publicCode'],
      adminCode: json['adminCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publicCode': publicCode,
    }; 
  }

  @override
  String toString() => '''CreateDesk(publicCode: $publicCode, adminCode: $adminCode)''';

}
