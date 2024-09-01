class CustomFileType {
    bool isImageFile(String url) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'pdf'];
    final extension = url.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  bool isPdf(String url) {
    final imageExtensions = ['pdf'];
    final extension = url.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }
}