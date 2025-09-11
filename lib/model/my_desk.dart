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
  final bool? isPremium;
  final SubmissionLimit? submissionLimit;

  MyDesk({this.code, this.adminCode, this.createdAt, this.isPremium, this.submissionLimit});

  factory MyDesk.fromJson(Map<String, dynamic> json) {
    return MyDesk(
      code: json['code'] as String?,
      adminCode: json['adminCode'] as String?,
      createdAt: json['createdAt'] as String?,
      isPremium: json['isPremium'] as bool?,
      submissionLimit: json['submissionLimit'] != null ? SubmissionLimit.fromJson(json['submissionLimit']) : null,
    );
  }
}


class SubmissionLimit {
  final int? monthly;
  final int? used;
  final int? remaining;
  final int? hiddenCount;

  SubmissionLimit({this.monthly, this.used, this.remaining, this.hiddenCount});

  factory SubmissionLimit.fromJson(Map<String, dynamic> json) {
    return SubmissionLimit(
      monthly: json['monthly'] as int?,
      used: json['used'] as int?,
      remaining: json['remaining'] as int?,
    );
    }
}