import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smart_scan_flutter/scanning/document_state.dart';
import 'package:smart_scan_flutter/scanning/models/processed_document.dart';
import 'package:smart_scan_flutter/scanning/screens/document_data_review_screen.dart';
import 'package:smart_scan_flutter/scanning/services/ocr_processor.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../utils/route.dart';

class ScannedDocumentScreen extends StatefulWidget {
  // final Uint8List scannedImageBytes;
  final DocumentState document;

  const ScannedDocumentScreen({super.key, required this.document});

  @override
  State<ScannedDocumentScreen> createState() => _ScannedDocumentScreenState();
}

class _ScannedDocumentScreenState extends State<ScannedDocumentScreen> {
  final TextEditingController _titleController = TextEditingController();
  final OcrProcessor _ocrProcessor = OcrProcessor();
  String result = "";
  bool _isProcessing = false;

  @override
  void initState() {
    _titleController.text = widget.document.title;
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveAndProcessDocument() async {
    if (widget.document.pageCount == 0 || _isProcessing) return;

    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text("Processing document: Saving and performing OCR..."),
    //   ),
    // );
    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. OCR (Using the first page for receipt data)
      final Uint8List firstPageImage = widget.document.scannedPages[0];
      final Map<String, String> extractedData = await _ocrProcessor
          .performOcrAndExtractFields(firstPageImage);

      // 2. PDF Generation
      final pdf = pw.Document();
      for (var imageBytes in widget.document.scannedPages) {
        final image = pw.MemoryImage(imageBytes);
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(image));
            },
          ),
        );
      }

      // Save the pdf file to a temporary directory
      final output = await getApplicationDocumentsDirectory();
      final fileName =
          "${widget.document.title.replaceAll(" ", "_")}_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File("${output.path}/$fileName");
      await file.writeAsBytes(await pdf.save());

      // 3. Navigate to Review Screen
      final processedDoc = ProcessedDocument(
        pdfFile: file,
        ocrFields: extractedData,
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => DocumentDataReviewScreen(document: processedDoc),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error processing document: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.document,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Consumer<DocumentState>(
            builder: (context, value, child) {
              return GestureDetector(
                child: Text(value.title, style: TextStyle(color: Colors.white)),
                onTap: () {
                  if (_isProcessing) return;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Document Title"),
                        content: TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: "Enter document title",
                          ),
                          autofocus: true,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.document.setTitle(_titleController.text);
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Consumer<DocumentState>(
          builder: (context, value, child) {
            return Stack(
              children: [
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child:
                              widget.document.currentPage != null
                                  ? Image.memory(
                                    widget.document.currentPage!,
                                    fit: BoxFit.contain,
                                  )
                                  : SizedBox(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed:
                                value.currentPageIndex == 0 || _isProcessing
                                    ? null
                                    : value.goToPreviousPage,
                            icon: Icon(
                              Icons.chevron_left_rounded,
                              color:
                                  value.currentPageIndex == 0 || _isProcessing
                                      ? Colors.grey
                                      : Colors.white,
                            ),
                          ),
                          Text(
                            value.pageNumberText,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed:
                                value.currentPageIndex == value.pageCount - 1 ||
                                        _isProcessing
                                    ? null
                                    : value.goToNextPage,
                            icon: Icon(
                              Icons.chevron_right_rounded,
                              color:
                                  value.currentPageIndex ==
                                              value.pageCount - 1 ||
                                          _isProcessing
                                      ? Colors.grey
                                      : Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed:
                                _isProcessing
                                    ? null
                                    : () {
                                      Navigator.pushNamed(
                                        context,
                                        ROUTE_SCAN,
                                        arguments: {"isFirstPage": false},
                                      ).then((result) {
                                        if (result is Uint8List) {
                                          value.addPage(result);
                                        }
                                      });
                                    },
                            child: Text("Keep Scanning"),
                          ),
                          ElevatedButton(
                            onPressed:
                                widget.document.pageCount > 0 && !_isProcessing
                                    ? () async {
                                      await _saveAndProcessDocument();
                                    }
                                    : null,
                            child: Text("Done"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (_isProcessing)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withAlpha(120),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Processing Document and performing OCR...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
