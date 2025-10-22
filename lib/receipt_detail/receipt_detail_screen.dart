import 'package:flutter/material.dart';
import 'package:smart_scan_flutter/widgets/receipt_form_fields.dart';
import 'package:smart_scan_flutter/widgets/tag_editor.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:smart_scan_flutter/db/database_helper.dart';
import 'dart:io';

class ReceiptDetailScreen extends StatefulWidget {
  final int receiptId;

  const ReceiptDetailScreen({super.key, required this.receiptId});

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  late Future<Receipt?> _receiptFuture;
  final Map<String, TextEditingController> _controllers = {};
  late final TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _tagsController = TextEditingController(text: "");
    _receiptFuture = _loadReceipt();
  }

  Future<Receipt?> _loadReceipt() async {
    final receipt = await DatabaseHelper.instance.getReceiptById(
      widget.receiptId,
    );
    if (receipt != null) {
      // Initialize controllers after the receipt data is loaded
      _controllers['Vendor Name'] = TextEditingController(
        text: receipt.vendorName,
      );
      _controllers['Total Amount'] = TextEditingController(
        text: receipt.totalAmount,
      );
      _controllers['Date'] = TextEditingController(text: receipt.date);
      _controllers['Category'] = TextEditingController(text: receipt.category);

      _tagsController.text = receipt.tags;
    }
    return receipt;
  }

  void _updateSave(Receipt originalReceipt) async {
    try {
      final String updatedTags = _tagsController.text.trim();

      final updatedReceipt = Receipt(
        id: originalReceipt.id,
        vendorName:
            _controllers['Vendor Name']?.text ?? originalReceipt.vendorName,
        totalAmount:
            _controllers['Total Amount']?.text ?? originalReceipt.totalAmount,
        date: _controllers['Date']?.text ?? originalReceipt.date,
        category: _controllers['Category']?.text ?? originalReceipt.category,
        filePath: originalReceipt.filePath,
        userId: originalReceipt.userId,
        tags: updatedTags,
      );

      // Call the database update method
      await DatabaseHelper.instance.updateReceipt(updatedReceipt);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Receipt updated successfully!")),
        );
        // Pop back to the HomeScreen, triggering a reload
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating receipt: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Receipt?>(
      future: _receiptFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Edit Receipt")),
            body: Center(
              child: Text(
                "Could not load receipt: ${snapshot.error ?? "Not found"}",
              ),
            ),
          );
        }

        final receipt = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Edit Receipt"),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => _updateSave(receipt),
              ),
            ],
          ),
          body: ListView(
            children: [
              // PDF Preview
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child:
                    File(receipt.filePath).existsSync()
                        ? SfPdfViewer.file(File(receipt.filePath))
                        : const Center(child: Text("Document file not found.")),
              ),

              // Editable fields
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReceiptFormFields(controllers: _controllers),

                    const SizedBox(height: 16),

                    TagEditor(
                      controller: _tagsController,
                      availableTags: const [
                        "Monthly",
                        "Online",
                        "Family",
                        "Friends",
                        "School",
                        "Office",
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
