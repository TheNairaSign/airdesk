import 'package:air_desk/model/submission.dart';

class MyDeskData {
  final MyDesk? myDesk;
  final List<Submission>? submissions; // Keeping dynamic since submissions can be varied

  MyDeskData({this.myDesk, this.submissions});

  factory MyDeskData.fromJson(Map<String, dynamic> json) {
    return MyDeskData(
      myDesk: json['myDesk'] != null ? MyDesk.fromJson(json['myDesk']) : null,
      submissions: json['submissions'] != null
          ? List<Submission>.from(json['submissions'].map((x) => Submission.fromJson(x)))
          : null,
    );
  }
}

class MyDesk {
  final String? code;
  final String? adminCode;
  final String? createdAt;

  MyDesk({this.code, this.adminCode, this.createdAt});

  factory MyDesk.fromJson(Map<String, dynamic> json) {
    return MyDesk(
      code: json['code'] as String?,
      adminCode: json['adminCode'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
