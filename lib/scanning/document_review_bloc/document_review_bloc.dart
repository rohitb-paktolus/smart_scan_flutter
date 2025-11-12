import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_scan_flutter/db/database_helper.dart';
import 'package:smart_scan_flutter/scanning/models/processed_document.dart';
import 'package:smart_scan_flutter/utils/app_functions.dart';

part 'document_review_event.dart';

part 'document_review_state.dart';

class DocumentReviewBloc
    extends Bloc<DocumentReviewEvent, DocumentReviewState> {
  final DatabaseHelper _databaseHelper;

  DocumentReviewBloc({required DatabaseHelper databaseHelper})
    : _databaseHelper = databaseHelper,
      super(DocumentReviewState(initialDate: DateTime.now())) {
    on<DocumentReviewInitialized>(_onInitialized);
    on<DocumentReviewSavePressed>(_onSavePressed);
  }

  DateTime _parseOcrDate(String dateString) {
    try {
      if (dateString.length >= 10 &&
          RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(dateString)) {
        return DateTime.parse(dateString);
      } else if (dateString.contains("/")) {
        final parts = dateString.split("/");
        if (parts.length == 3) {
          final month = int.tryParse(parts[0]);
          final day = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (month != null && day != null && year != null) {
            return DateTime(year, month, day);
          }
        }
      }
    } catch (_) {
      // Ignore parsing errors
    }
    return DateTime.now();
  }

  /// Handles the initialization logic (parsing OCR data)
  void _onInitialized(
    DocumentReviewInitialized event,
    Emitter<DocumentReviewState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DocumentReviewStatus.loading));

      final Map<String, String> ocrFields = {};
      ReceiptCategory selectedCategory = ReceiptCategory.general;
      DateTime selectedDate = DateTime.now();

      event.document.ocrFields.forEach((key, value) {
        String cleanValue = value;

        if (key == 'Date') {
          selectedDate = _parseOcrDate(value);
          ocrFields[key] = formatDateForDisplay(selectedDate);
        } else if (key.toLowerCase() == "category") {
          try {
            selectedCategory = ReceiptCategory.values.byName(value);
          } catch (_) {
            selectedCategory = ReceiptCategory.general;
          }
        } else {
          if (key.toLowerCase().contains("amount") && value.isNotEmpty) {
            cleanValue = value.replaceAll(RegExp(r'[^\d.]'), "");
          }
          ocrFields[key] = cleanValue;
        }
      });

      // Apply defaults
      ocrFields.putIfAbsent("Vendor Name", () => "");
      ocrFields.putIfAbsent("Total Amount", () => "0.00");
      ocrFields.putIfAbsent("Date", () => formatDateForDisplay(selectedDate));

      emit(
        state.copyWith(
          status: DocumentReviewStatus.loaded,
          document: event.document,
          initialFields: ocrFields,
          initialCategory: selectedCategory,
          initialDate: selectedDate,
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('!!! CRITICAL ERROR in _onInitialized !!!');
        print('Error: $error');
        print('StackTrace: $stackTrace');
      }
      // Emit a failure state so the UI can stop loading
      emit(
        state.copyWith(
          status: DocumentReviewStatus.failure,
          errorMessage: "Failed to parse document: ${error.toString()}",
        ),
      );
    }
  }

  /// Handles the save logic
  Future<void> _onSavePressed(
    DocumentReviewSavePressed event,
    Emitter<DocumentReviewState> emit,
  ) async {
    emit(state.copyWith(status: DocumentReviewStatus.saving));

    try {
      if (state.document == null) {
        throw Exception("Document data is missing.");
      }

      final String documentPath = state.document!.pdfFile.path;
      final user = await _databaseHelper.getCurrentUser();
      if (user == null) {
        throw Exception("User not found. Please log in again.");
      }

      final DateTime finalDate = event.finalDate;

      final newReceipt = Receipt(
        vendorName: event.finalFields["Vendor Name"] ?? "Unknown Vendor",
        totalAmount:
            double.tryParse(event.finalFields["Total Amount"]!) ?? 0.00,
        date: finalDate,
        category: event.finalCategory,
        filePath: documentPath,
        userId: user.id,
        tags: event.finalTags,
      );

      if (kDebugMode) {
        print("3. Receipt object created successfully.");
        print("Receipt Map: ${newReceipt.toMap()}");
      }

      final id = await _databaseHelper.saveReceipt(newReceipt);
      if (kDebugMode) {
        print("4. Receipt Saved Successfully. Database ID: $id");
      }

      emit(
        state.copyWith(
          status: DocumentReviewStatus.success,
          savedReceiptId: id,
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print("!!! CRITICAL ERROR in _onSavePressed !!!");
        print("Error: $error");
        print("StackTrace: $stackTrace");
      }
      emit(
        state.copyWith(
          status: DocumentReviewStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
