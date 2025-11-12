part of 'document_review_bloc.dart';

// Enum to track the screen's current status
enum DocumentReviewStatus { initial, loading, loaded, saving, success, failure }

class DocumentReviewState extends Equatable {
  final DocumentReviewStatus status;
  final ProcessedDocument? document;
  final Map<String, String> initialFields;
  final ReceiptCategory initialCategory;
  final DateTime initialDate;
  final String? errorMessage;
  final int? savedReceiptId;

  const DocumentReviewState({
    this.status = DocumentReviewStatus.initial,
    this.document,
    this.initialFields = const {},
    this.initialCategory = ReceiptCategory.general,
    required this.initialDate,
    this.errorMessage,
    this.savedReceiptId,
  });

  DocumentReviewState copyWith({
    DocumentReviewStatus? status,
    ProcessedDocument? document,
    Map<String, String>? initialFields,
    ReceiptCategory? initialCategory,
    DateTime? initialDate,
    String? errorMessage,
    int? savedReceiptId,
  }) {
    return DocumentReviewState(
      status: status ?? this.status,
      document: document ?? this.document,
      initialFields: initialFields ?? this.initialFields,
      initialCategory: initialCategory ?? this.initialCategory,
      initialDate: initialDate ?? this.initialDate,
      errorMessage: errorMessage ?? this.errorMessage,
      savedReceiptId: savedReceiptId ?? this.savedReceiptId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    document,
    initialFields,
    initialCategory,
    initialDate,
    errorMessage,
    savedReceiptId,
  ];
}
