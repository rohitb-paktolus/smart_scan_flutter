import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class PdfViewerScreen extends StatelessWidget {
  final String filePath;

  const PdfViewerScreen({super.key, required this.filePath});

  void _exportPdf(BuildContext context) async {
    try {
      final file = XFile(filePath);
      await SharePlus.instance.share(
        ShareParams(
          subject: "Shared Document",
          text: "Here is the receipt document.",
          files: [file],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        print("$e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to share PDF: $e")));
      }
    }
  }

  void _exportJpeg(BuildContext context, String filePath) async {
    try {
      final document = await PdfDocument.openFile(filePath);
      final List<XFile> jpegFiles = [];
      for (int i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);
        final scale = 2.0;
        final width = page.width * scale;
        final height = page.height * scale;
        final pageImage = await page.render(width: width, height: height);
        final tempDir = await getTemporaryDirectory();
        final jpegFile = File("${tempDir.path}/page_$i.jpg");
        await jpegFile.writeAsBytes(pageImage!.bytes);
        jpegFiles.add(XFile(jpegFile.path));
        await page.close();

        await SharePlus.instance.share(ShareParams(files: jpegFiles));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error exporting JPEG: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool fileExists = File(filePath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Document Preview"),
        actions: [
          if (fileExists)
            PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == "PDF") {
                  _exportPdf(context);
                } else if (result == "JPEG") {
                  _exportJpeg(context, filePath);
                }
              },
              itemBuilder:
                  (context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: "PDF",
                      child: Text("Export as PDF (Share)"),
                    ),
                    const PopupMenuItem<String>(
                      value: "JPEG",
                      child: Text("Export as JPEG"),
                    ),
                  ],
            ),
        ],
      ),
      body:
          fileExists
              ? SfPdfViewer.file(File(filePath))
              : const Center(child: Text("Document file not found.")),
    );
  }
}
