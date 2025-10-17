import 'package:flutter/material.dart';
import 'package:smart_scan_flutter/scanning/models/processed_document.dart';
import 'package:smart_scan_flutter/widgets/receipt_form_fields.dart';
import 'package:smart_scan_flutter/widgets/tag_editor.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:smart_scan_flutter/db/database_helper.dart';

class DocumentDataReviewScreen extends StatefulWidget {
  final ProcessedDocument document;

  const DocumentDataReviewScreen({super.key, required this.document});

  @override
  State<DocumentDataReviewScreen> createState() =>
      _DocumentDataReviewScreenState();
}

class _DocumentDataReviewScreenState extends State<DocumentDataReviewScreen> {
  late final Map<String, TextEditingController> _controllers;
  late final TextEditingController _tagsController;

  // Helper to format date as MM/DD/YYYY
  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _controllers = {};
    _tagsController = TextEditingController(text: "");

    final String currentDate = _formatDate(DateTime.now());

    // Process and clean OCR data before loading into controllers
    widget.document.ocrFields.forEach((key, value) {
      String cleanValue = value;

      if (key == 'Date') {
        // 1. Date Consistency Fix: Use current date if OCR text is Empty
        if (value.isEmpty) {
          cleanValue = currentDate;
        }
      }

      // 2. Total Amount Cleaning: Extract only numeric part for the controller.
      if (key.toLowerCase().contains("amount") && value.isNotEmpty) {
        cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
      }

      _controllers[key] = TextEditingController(text: cleanValue);
    });
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    _tagsController.dispose();
    super.dispose();
  }

  void _finalSave() async {
    final Map<String, String> finalData = {};
    _controllers.forEach((key, controller) {
      finalData[key] = controller.text;
    });

    final String tags = _tagsController.text.trim();

    print('--- DEBUG START: _finalSave ---');
    print('1. Collected form data: $finalData');
    print('1b. Collected tags: $tags');

    try {
      final String documentPath = widget.document.pdfFile.path;
      print('2. Document File Path: $documentPath');

      final String? userId =
          await DatabaseHelper.instance.getLoggedInUserEmail();
      final String userIdentifier = userId ?? "guest_user";

      final newReceipt = Receipt(
        vendorName: finalData["Vendor Name"] ?? "Unknown Vendor",
        totalAmount: finalData["Total Amount"] ?? "0.00",
        // Save the date as it is, which is now guaranteed to be a formatted date string
        date: finalData["Date"] ?? '',
        category: finalData["Category"] ?? "General",
        filePath: documentPath,
        userId: userIdentifier,
        tags: tags,
      );
      print('3. Receipt object created successfully.');
      print('   Receipt Map: ${newReceipt.toMap()}');

      final id = await DatabaseHelper.instance.saveReceipt(newReceipt);
      print('4. Receipt saved successfully. Database ID: $id');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Document saved successfully! Record ID: $id"),
          ),
        );
      }

      if (mounted) {
        print('5. Navigating home.');
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (error, stackTrace) {
      print('!!! CRITICAL ERROR in _finalSave !!!');
      print('Error: $error');
      print('StackTrace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving document: ${error.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    print('--- DEBUG END: _finalSave ---');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Review & Edit Data"),
        actions: [
          IconButton(onPressed: _finalSave, icon: Icon(Icons.check_rounded)),
        ],
      ),
      body: Column(
        children: [
          // Top Half: PDF Preview
          Expanded(flex: 1, child: SfPdfViewer.file(widget.document.pdfFile)),

          // Bottom Half: Editable Fields
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: ListView(
                children: [
                  ReceiptFormFields(controllers: _controllers),

                  const SizedBox(height: 16),

                  TagEditor(
                    controller: _tagsController,
                    labelText: "Receipt Tags (e.g., travel, food, work)",
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
