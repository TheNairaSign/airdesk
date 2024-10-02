import 'package:air_desk/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/download_provider.dart';

class DownloadFile extends StatefulWidget {
  const DownloadFile({
    super.key,
    required this.index,
    required this.url,
    required this.fileName,
    // required this.file,
    this.imageLength,
  });

  final int index;
  final int? imageLength;
  final String url, fileName;

  @override
  State<DownloadFile> createState() => _DownloadFileState();
}

class _DownloadFileState extends State<DownloadFile> {
  List<bool> isDownloadingList = [];

  @override
  void initState() {
    super.initState();
    // Initialize the _isDownloadingList based on the number of items in the list
    isDownloadingList = List<bool>.filled(widget.imageLength ?? 0, false);
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.index;

    return Consumer<DownloadProvider>(
        builder: (context, downloadProvider, child) {
      return GestureDetector(
        onTap: () async {
          downloadProvider.downloadFile(context, index, isDownloadingList, widget.url, widget.fileName);
        },
        child: isDownloadingList[index]
            ? const SizedBox(
                height: 15,
                width: 15,
                child: Center(
                  child: CircularProgressIndicator(color: primaryBlue),
                ),
              )
            : const Icon(
                Icons.file_download_outlined,
                color: primaryBlue,
              ),
      );
    });
  }
}
