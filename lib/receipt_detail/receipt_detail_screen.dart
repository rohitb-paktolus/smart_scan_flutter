import 'package:flutter/material.dart';
import 'package:smart_scan_flutter/scanning/screens/pdf_viewer_screen.dart';
import 'package:smart_scan_flutter/widgets/receipt_form_fields.dart';
import 'package:smart_scan_flutter/widgets/tag_editor.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:smart_scan_flutter/db/database_helper.dart';
import 'dart:io';
import '../utils/app_functions.dart';

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

  ReceiptCategory? _selectedCategory;

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
        text: receipt.totalAmount.toString(),
      );
      _controllers['Date'] = TextEditingController(text: receipt.date);

      _selectedCategory = receipt.category;

      _tagsController.text = receipt.tags;
    }
    return receipt;
  }

  void _updateSave(Receipt originalReceipt) async {
    try {
      final String updatedTags = _tagsController.text.trim();

      final ReceiptCategory finalCategory =
          _selectedCategory ?? originalReceipt.category;

      final updatedReceipt = Receipt(
        id: originalReceipt.id,
        vendorName:
            _controllers['Vendor Name']?.text ?? originalReceipt.vendorName,
        totalAmount:
            double.tryParse(_controllers['Total Amount']?.text ?? "0.0") ??
            originalReceipt.totalAmount,
        date: _controllers['Date']?.text ?? originalReceipt.date,
        category: finalCategory,
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

  void _openPdfFullScreen(String filePath) {
    print("CALL: _openPdfFullScreen");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(filePath: filePath),
      ),
    );
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
                        ? SfPdfViewer.file(
                          File(receipt.filePath),
                          canShowScrollHead: false,
                          interactionMode: PdfInteractionMode.pan,
                          enableDoubleTapZooming: false,
                          onTap:
                              (details) => _openPdfFullScreen(receipt.filePath),
                        )
                        : const Center(child: Text("Document file not found.")),
              ),

              // Editable fields
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReceiptFormFields(controllers: _controllers),

                    DropdownButtonFormField<ReceiptCategory>(
                      decoration: InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _selectedCategory,
                      items:
                          ReceiptCategory.values.map((
                            ReceiptCategory category,
                          ) {
                            return DropdownMenuItem<ReceiptCategory>(
                              value: category,
                              child: Text(capitalize(category.name)),
                            );
                          }).toList(),
                      onChanged: (ReceiptCategory? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                    ),

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
