import 'package:air_desk/model/desk_location.dart';
import 'package:air_desk/model/image_data.dart';
import 'package:air_desk/model/image_model.dart';

class DeskData {
  final String? code;
  final String? editCode;
  final String? deskType;
  final bool? isDeskSubmission;
  final String? myDeskCode;
  final bool? isMyDesk;
  final String? text;
  final List<ImageData>? images;
  final int? viewCount;
  final DeskLocation? location;
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  const DeskData({
    this.code,
    this.editCode,
    this.deskType,
    this.isDeskSubmission,
    this.myDeskCode,
    this.isMyDesk,
    this.text,
    this.images,
    this.viewCount,
    this.location,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory DeskData.fromJson(Map<String, dynamic> json) {
    return DeskData(
      code: json['code'],
      editCode: json['editCode'],
      deskType: json['deskType'],
      isDeskSubmission: json['isDeskSubmission'],
      myDeskCode: json['myDeskCode'],
      isMyDesk: json['isMyDesk'],
      text: json['text'],
      images: json['images'] != null 
          ? (json['images'] as List).map((img) => ImageData.fromJson(img)).toList()
          : null,
      viewCount: json['viewCount'],
      location: json['location'] != null ? DeskLocation.fromJson(json['location']) : null,
      id: json['_id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'editCode': editCode,
        'deskType': deskType,
        'isDeskSubmission': isDeskSubmission,
        'myDeskCode': myDeskCode,
        'isMyDesk': isMyDesk,
        'text': text,
        'images': images?.map((img) => img.toJson()).toList(),
        'viewCount': viewCount,
        'location': location?.toJson(),
        '_id': id,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        '__v': v,
      };
}
