// ignore_for_file: avoid_print
import 'package:air_desk/model/image_model.dart';

class AirdeskData {
  final String code, text, imageUrl, imageName, createdDate;
  final List<ImageData> images;
  final List<String>? imageUrls;
  AirdeskData({
    required this.code,
    required this.images,
    required this.imageUrl,
    required this.imageName,
    required this.text,
    required this.createdDate,
    required this.imageUrls,
  });

  // Factory constructor to create an instance from JSON
  factory AirdeskData.fromJson(Map<String, dynamic> json) {
    print("Entering AirdeskData.fromJson");

    // Access the 'images' list safely
    final images = json["images"] as List? ?? [];
    List<ImageData> imageList = images.map((image) => ImageData.fromJson(image)).toList();
    List<String> imageUrls = images.map((image) => image["url"] as String? ?? 'No data').toList();

    return AirdeskData(
      code: json['code'] ?? '',
      text: json['text'] == '' ? 'No content' : json['text'],
      imageUrl: images.isNotEmpty ? images[0]["url"] : 'No data',
      imageName: images.isNotEmpty ? images[0]["originalName"] : 'No data',
      images: imageList,
      createdDate: json['createdAt'],
      imageUrls: imageUrls
    );
  }
}