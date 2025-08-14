import 'package:air_desk/model/image_data.dart';

class Submission {
  final String? id;
  final String? code;
  final String? text;
  final List<ImageData>? images;
  final int? viewCount;
  final String? createdAt; // You can make this DateTime? if you want

  Submission({
    this.id,
    this.code,
    this.text,
    this.images,
    this.viewCount,
    this.createdAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['_id'] as String?,
      code: json['code'] as String?,
      text: json['text'] as String?,
      images: json['images'] != null
          ? (json['images'] as List)
              .map((img) => ImageData.fromJson(img))
              .toList()
          : null,
      viewCount: json['viewCount'] as int?,
      createdAt: json['createdAt'] as String?,
    );
  }

}
