class ImageModel {
  final String url;
  final String originalName;

  ImageModel({
    required this.url,
    required this.originalName,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      url: json['url'] ?? '',
      originalName: json['originalName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'originalName': originalName,
    };
  }
}
