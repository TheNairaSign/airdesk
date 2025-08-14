class ImageData {
  final String? publicId;
  final String? url;
  final String? originalName;
  final String? fileType;
  final String? id;

  ImageData({
    this.publicId,
    this.url,
    this.originalName,
    this.fileType,
    this.id,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      publicId: json['public_id'],
      url: json['url'],
      originalName: json['originalName'],
      fileType: json['fileType'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'url': url,
      'originalName': originalName,
      'fileType': fileType,
      '_id': id,
    };
  }
}
