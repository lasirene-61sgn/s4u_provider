import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/api/api_client.dart';
import '../model/document_model.dart';

class DocumentState {
  final bool isLoading;
  final List<DocumentModel> documents;
  final List<DocumentTypeModel> documentTypes;
  final String? error;

  DocumentState({
    this.isLoading = false,
    this.documents = const [],
    this.documentTypes = const [],
    this.error,
  });

  DocumentState copyWith({
    bool? isLoading,
    List<DocumentModel>? documents,
    List<DocumentTypeModel>? documentTypes,
    String? error,
  }) {
    return DocumentState(
      isLoading: isLoading ?? this.isLoading,
      documents: documents ?? this.documents,
      documentTypes: documentTypes ?? this.documentTypes,
      error: error ?? this.error,
    );
  }
}

class DocumentNotifier extends Notifier<DocumentState> {
  final ApiClient _apiClient = ApiClient();

  @override
  DocumentState build() => DocumentState();

  Future<void> fetchDocumentTypes() async {
    try {
      final response = await _apiClient.get(endpoint: '/document-list');
      print('fetchDocumentTypes document: $response');
      List<DocumentTypeModel> types = [];
      if (response is Map) {
        dynamic data = response['data'] ?? response;
        if (data is Map && data.containsKey('data')) {
          data = data['data'];
        }
        if (data is List) {
          types = data.map((item) => DocumentTypeModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      } else if (response is List) {
        types = response.map((item) => DocumentTypeModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      state = state.copyWith(documentTypes: types);
    } catch (e, stack) {
      print('Error fetching document types: $e');
      print(stack);
    }
  }

  Future<void> fetchDocuments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get(endpoint: '/provider-document-list');
      print('fetchDocuments response: $response');
      List<DocumentModel> docList = [];
      if (response is Map) {
        dynamic data = response['data'] ?? response;
        if (data is Map && data.containsKey('data')) {
          data = data['data'];
        }
        if (data is List) {
          docList = data.map((item) => DocumentModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      } else if (response is List) {
        docList = response.map((item) => DocumentModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      state = state.copyWith(isLoading: false, documents: docList);
    } catch (e, stack) {
      print('Error fetching documents: $e');
      print(stack);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addDocument({required Map<String, dynamic> fields, required Map<String, dynamic> files}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiClient.requestWithFiles(
        endpoint: '/provider-document-save',
        fields: fields,
        files: files,
        method: 'POST',
      );
      await fetchDocuments();
      Fluttertoast.showToast(msg: 'Document added successfully', backgroundColor: Colors.green, textColor: Colors.white);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
      rethrow;
    }
  }

  Future<void> deleteDocument(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      print('Deleting document with ID: $id via POST');
      await _apiClient.post(endpoint: '/provider-document-delete/$id');
      await fetchDocuments();
      Fluttertoast.showToast(msg: 'Document deleted successfully', backgroundColor: Colors.green, textColor: Colors.white);
    } catch (e) {
      print('Error deleting document: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
      rethrow;
    }
  }
}

final documentProvider = NotifierProvider<DocumentNotifier, DocumentState>(() {
  return DocumentNotifier();
});
