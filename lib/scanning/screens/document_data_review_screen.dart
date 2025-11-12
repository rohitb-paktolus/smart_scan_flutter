import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_scan_flutter/scanning/document_review_bloc/document_review_bloc.dart';
import 'package:smart_scan_flutter/scanning/models/processed_document.dart';
import 'package:smart_scan_flutter/scanning/screens/pdf_viewer_screen.dart';
import 'package:smart_scan_flutter/widgets/receipt_form_fields.dart';
import 'package:smart_scan_flutter/widgets/tag_editor.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:smart_scan_flutter/db/database_helper.dart';

import '../../utils/app_functions.dart';

class DocumentDataReviewScreen extends StatefulWidget {
  final ProcessedDocument document;

  const DocumentDataReviewScreen({super.key, required this.document});

  @override
  State<DocumentDataReviewScreen> createState() =>
      _DocumentDataReviewScreenState();
}

class _DocumentDataReviewScreenState extends State<DocumentDataReviewScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DocumentReviewBloc>().add(
      DocumentReviewInitialized(widget.document),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DocumentDataReviewView(document: widget.document);
  }
}

class DocumentDataReviewView extends StatefulWidget {
  final ProcessedDocument document;

  const DocumentDataReviewView({super.key, required this.document});

  @override
  State<DocumentDataReviewView> createState() => _DocumentDataReviewViewState();
}

class _DocumentDataReviewViewState extends State<DocumentDataReviewView> {
  late final Map<String, TextEditingController> _controllers;
  late final TextEditingController _tagsController;
  late ReceiptCategory _selectedCategory;
  late DateTime _selectedDate;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    _tagsController = TextEditingController();
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    _tagsController.dispose();
    super.dispose();
  }

  void _initializeControllers(DocumentReviewState state) {
    if (_isInitialized) return;

    state.initialFields.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value);
    });

    _selectedCategory = state.initialCategory;
    _selectedDate = state.initialDate;
    // _tagsController is initialized empty by default

    _isInitialized = true;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controllers["Date"]!.text = formatDateForDisplay(_selectedDate);
      });
    }
  }

  void _finalSave() {
    final Map<String, dynamic> finalData = {};
    _controllers.forEach((key, controller) {
      finalData[key] = controller.text;
    });

    final String tags = _tagsController.text.trim();

    if (kDebugMode) {
      print('--- DEBUG START: _finalSave ---');
      print('1. Collected form data: $finalData');
      print('1b. Collected category (Dropdown): ${_selectedCategory.name}');
      print('1b. Collected tags: $tags');
    }

    context.read<DocumentReviewBloc>().add(
      DocumentReviewSavePressed(
        finalFields: Map<String, String>.from(finalData),
        finalCategory: _selectedCategory,
        finalTags: tags,
        finalDate: _selectedDate,
      ),
    );
  }

  void _openPdfFullScreen(String filePath) {
    if (kDebugMode) {
      print("CALL: _openPdfFullScreen");
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(filePath: filePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentReviewBloc, DocumentReviewState>(
      listener: (context, state) {
        if (state.status == DocumentReviewStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Document Saved Successfully! Record ID: ${state.savedReceiptId}",
              ),
            ),
          );
          // Navigate home
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state.status == DocumentReviewStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? "An unknown error occurred"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Review & Edit Data"),
          actions: [
            BlocBuilder<DocumentReviewBloc, DocumentReviewState>(
              builder: (context, state) {
                if (state.status == DocumentReviewStatus.saving) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
                return IconButton(
                  onPressed: _finalSave,
                  icon: Icon(Icons.check_rounded),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<DocumentReviewBloc, DocumentReviewState>(
          builder: (context, state) {
            print(state);
            if (state.status == DocumentReviewStatus.loading ||
                state.status == DocumentReviewStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == DocumentReviewStatus.loaded &&
                !_isInitialized) {
              _initializeControllers(state);
            }

            if (!_isInitialized) {
              return const Center(child: Text("Error: Could not load data!"));
            }

            return ListView(
              children: [
                // Top Half: PDF Preview
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child:
                      widget.document.pdfFile.existsSync()
                          ? SfPdfViewer.file(
                            widget.document.pdfFile,
                            canShowScrollHead: false,
                            interactionMode: PdfInteractionMode.pan,
                            enableDoubleTapZooming: false,
                            onTap:
                                (details) => _openPdfFullScreen(
                                  widget.document.pdfFile.path,
                                ),
                          )
                          : const Center(
                            child: Text("Document file not found."),
                          ),
                ),
                // Bottom Half: Editable Fields
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReceiptFormFields(controllers: _controllers),

                      Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: DropdownButtonFormField<ReceiptCategory>(
                          decoration: InputDecoration(
                            labelText: "Category",
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _selectedCategory,
                          items:
                              ReceiptCategory.values.map((category) {
                                return DropdownMenuItem<ReceiptCategory>(
                                  value: category,
                                  child: Text(capitalize(category.name)),
                                );
                              }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      TagEditor(
                        controller: _tagsController,
                        availableTags: const [
                          'Monthly',
                          'Online',
                          'Family',
                          'Friends',
                          'School',
                          'Office',
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
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
