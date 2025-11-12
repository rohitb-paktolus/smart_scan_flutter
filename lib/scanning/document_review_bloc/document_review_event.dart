part of 'document_review_bloc.dart';

sealed class DocumentReviewEvent extends Equatable {
  const DocumentReviewEvent();

  @override
  List<Object?> get props => [];
}

// Event sent when the screen is first loaded
class DocumentReviewInitialized extends DocumentReviewEvent {
  final ProcessedDocument document;

  const DocumentReviewInitialized(this.document);

  @override
  List<Object?> get props => [document];
}

// Event sent when the "Save" button is pressed
class DocumentReviewSavePressed extends DocumentReviewEvent {
  final Map<String, String> finalFields;
  final ReceiptCategory finalCategory;
  final String finalTags;
  final DateTime finalDate;

  const DocumentReviewSavePressed({
    required this.finalFields,
    required this.finalCategory,
    required this.finalTags,
    required this.finalDate,
  });

  @override
  List<Object?> get props => [finalFields, finalCategory, finalTags, finalDate];
}
