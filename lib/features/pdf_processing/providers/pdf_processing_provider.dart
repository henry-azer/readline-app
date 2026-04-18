import 'package:flutter/material.dart';
import '../../../data/models/pdf_document_model.dart';
import '../../../domain/repositories/pdf_repository.dart';

enum PdfProcessingState {
  initial,
  loading,
  success,
  error,
}

class PdfProcessingProvider extends ChangeNotifier {
  final PdfRepository _pdfRepository;

  PdfProcessingProvider(this._pdfRepository);

  PdfProcessingState _state = PdfProcessingState.initial;
  PdfDocumentModel? _currentDocument;
  List<PdfDocumentModel> _cachedDocuments = [];
  String? _errorMessage;
  double _processingProgress = 0.0;

  // Getters
  PdfProcessingState get state => _state;
  PdfDocumentModel? get currentDocument => _currentDocument;
  List<PdfDocumentModel> get cachedDocuments => List.unmodifiable(_cachedDocuments);
  String? get errorMessage => _errorMessage;
  double get processingProgress => _processingProgress;
  bool get isProcessing => _state == PdfProcessingState.loading;
  bool get hasDocument => _currentDocument != null;
  bool get hasError => _errorMessage != null;

  Future<void> processPdfFile(String filePath) async {
    try {
      _setState(PdfProcessingState.loading);
      _errorMessage = null;
      _processingProgress = 0.0;
      notifyListeners();

      // Simulate processing progress
      _simulateProgress();

      final document = await _pdfRepository.processPdf(filePath);
      _currentDocument = document;
      
      // Refresh cached documents
      await loadCachedDocuments();
      
      _setState(PdfProcessingState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(PdfProcessingState.error);
    }
  }

  Future<void> loadCachedDocuments() async {
    try {
      final documents = await _pdfRepository.getCachedDocuments();
      _cachedDocuments = documents;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load cached documents: $e';
      notifyListeners();
    }
  }

  Future<void> selectDocument(PdfDocumentModel document) async {
    try {
      _setState(PdfProcessingState.loading);
      _currentDocument = document;
      
      // Update last read time
      await _pdfRepository.updateDocumentLastRead(document.id);
      
      _setState(PdfProcessingState.success);
    } catch (e) {
      _errorMessage = 'Failed to select document: $e';
      _setState(PdfProcessingState.error);
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await _pdfRepository.deleteDocument(documentId);
      
      // Remove from cached list
      _cachedDocuments.removeWhere((doc) => doc.id == documentId);
      
      // Clear current document if it was deleted
      if (_currentDocument?.id == documentId) {
        _currentDocument = null;
        _setState(PdfProcessingState.initial);
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete document: $e';
      notifyListeners();
    }
  }

  Future<void> searchDocuments(String query) async {
    try {
      if (query.isEmpty) {
        await loadCachedDocuments();
        return;
      }

      final documents = await _pdfRepository.searchDocuments(query);
      _cachedDocuments = documents;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to search documents: $e';
      notifyListeners();
    }
  }

  Future<void> refreshDocuments() async {
    await loadCachedDocuments();
  }

  void clearCurrentDocument() {
    _currentDocument = null;
    _setState(PdfProcessingState.initial);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setState(PdfProcessingState newState) {
    _state = newState;
    notifyListeners();
  }

  void _simulateProgress() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_state == PdfProcessingState.loading) {
        _processingProgress = (_processingProgress + 0.1).clamp(0.0, 0.9);
        notifyListeners();
        
        if (_processingProgress < 0.9) {
          _simulateProgress();
        }
      }
    });
  }

  Future<String> getDocumentText(String filePath) async {
    try {
      return await _pdfRepository.extractFullText(filePath);
    } catch (e) {
      _errorMessage = 'Failed to extract text: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<List<String>> getDocumentPages(String filePath) async {
    try {
      return await _pdfRepository.extractPages(filePath);
    } catch (e) {
      _errorMessage = 'Failed to extract pages: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Document statistics
  int get totalDocuments => _cachedDocuments.length;
  int get totalWords => _cachedDocuments.fold(0, (sum, doc) => sum + doc.wordCount);
  int get totalPages => _cachedDocuments.fold(0, (sum, doc) => sum + doc.pageCount);

  // Recently read documents
  List<PdfDocumentModel> get recentlyReadDocuments {
    final sorted = List<PdfDocumentModel>.from(_cachedDocuments);
    sorted.sort((a, b) {
      if (a.lastRead == null && b.lastRead == null) return 0;
      if (a.lastRead == null) return 1;
      if (b.lastRead == null) return -1;
      return b.lastRead!.compareTo(a.lastRead!);
    });
    return sorted.take(5).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
