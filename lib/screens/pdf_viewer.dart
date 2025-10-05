import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PdfViewPage extends StatefulWidget {
  final String path;

  const PdfViewPage({Key? key, required this.path}) : super(key: key);

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  String? localPath;
  bool isReady = false;
  int pages = 0;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    loadPdf(widget.path);
  }

  Future<void> loadPdf(String path) async {
    if (path.startsWith('http')) {
      // Network file → download it
      final file = await downloadFile(path, 'resume.pdf');
      setState(() => localPath = file.path);
    } else {
      // Local path
      setState(() => localPath = path);
    }
  }

  Future<File> downloadFile(String url, String filename) async {
    final response = await http.get(Uri.parse(url));
    final file = File('${(await getTemporaryDirectory()).path}/$filename');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resume Viewer")),
      body: localPath != null
          ? PDFView(
              filePath: localPath!,
              enableSwipe: true,
              swipeHorizontal: true,
              onRender: (pagesCount) {
                setState(() {
                  pages = pagesCount!;
                  isReady = true;
                });
              },
              onPageChanged: (page, total) {
                setState(() => currentPage = page!);
              },
              onError: (error) => print(error.toString()),
              onPageError: (page, error) =>
                  print('Page $page error: ${error.toString()}'),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
