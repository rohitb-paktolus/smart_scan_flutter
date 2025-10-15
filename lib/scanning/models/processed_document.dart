import 'dart:io';

class ProcessedDocument {
  final File pdfFile;
  final Map<String, String> ocrFields;

  ProcessedDocument({required this.pdfFile, required this.ocrFields});
}
