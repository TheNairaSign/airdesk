class ImageData {
  final String url;
  final String originalName;

  ImageData({
    required this.url,
    required this.originalName,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
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
