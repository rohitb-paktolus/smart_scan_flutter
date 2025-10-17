import 'package:flutter/foundation.dart';

class DocumentState extends ChangeNotifier {
  String _title;
  final List<Uint8List> _scannedPages;
  int _currentPageIndex;

  DocumentState({String title = "New Document", List<Uint8List>? initialPages})
    : _title = title,
      _scannedPages = initialPages ?? [],
      _currentPageIndex =
          (initialPages?.isNotEmpty ?? false) ? initialPages!.length - 1 : 0;

  // Public getters
  String get title => _title;

  List<Uint8List> get scannedPages => _scannedPages;

  int get currentPageIndex => _currentPageIndex;

  int get pageCount => _scannedPages.length;

  Uint8List? get currentPage =>
      pageCount > 0 ? _scannedPages[_currentPageIndex] : null;

  String get pageNumberText => "${_currentPageIndex + 1} / $pageCount";

  // Setters/mutators
  void setTitle(String name) {
    _title = name;
    notifyListeners();
  }

  void addPage(Uint8List page) {
    _scannedPages.add(page);
    _currentPageIndex = _scannedPages.length - 1;
    notifyListeners();
  }

  void goToNextPage() {
    if (_currentPageIndex < pageCount - 1) {
      _currentPageIndex++;
      notifyListeners();
    }
  }

  void goToPreviousPage() {
    if (_currentPageIndex > 0) {
      _currentPageIndex--;
      notifyListeners();
    }
  }
}
