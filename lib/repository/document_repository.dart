import 'dart:convert';

import 'package:docs_clone_flutter/common/constants.dart';
import 'package:docs_clone_flutter/models/document_model.dart';
import 'package:docs_clone_flutter/models/response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final documentRepositoryProvider =
    Provider((ref) => DocumentRepository(client: Client()));

class DocumentRepository {
  final Client _client;

  DocumentRepository({required Client client}) : _client = client;

  Future<ResponseModel> createDocument(String token) async {
    try {
      var response = await _client.post(Uri.parse(Constants.createDocumentApi),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token
          },
          body:
              jsonEncode({'createdAt': DateTime.now().millisecondsSinceEpoch}));
      switch (response.statusCode) {
        case 200:
          return ResponseModel(
              data: DocumentModel.fromJson(response.body), error: null);
        case 500:
          return ResponseModel(data: null, error: "Server error!");
      }
    } catch (e) {
      return ResponseModel(data: null, error: e.toString());
    }

    return ResponseModel(data: null, error: "Something went wrong!");
  }

  Future<ResponseModel> getDocuments(String token) async {
    try {
      var response = await _client.get(
        Uri.parse(Constants.getDocuments),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token
        },
      );
      switch (response.statusCode) {
        case 200:
          List<DocumentModel> documents = [];
          for (int i = 0; i < jsonDecode(response.body).length; i++) {
            documents.add(DocumentModel.fromJson(
                jsonEncode(jsonDecode(response.body)[i])));
          }
          return ResponseModel(data: documents, error: null);
        case 500:
          return ResponseModel(data: null, error: "Server error!");
      }
    } catch (e) {
      return ResponseModel(data: null, error: e.toString());
    }

    return ResponseModel(data: null, error: "Something went wrong!");
  }

  Future<ResponseModel> updateTItle({
    required String token,
    required String title,
    required String id,
  }) async {
    try {
      var response = await _client.post(Uri.parse(Constants.updateTitle),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token
          },
          body: jsonEncode({'title': title, 'id': id}));
      switch (response.statusCode) {
        case 200:
          return ResponseModel(data: true, error: null);
        case 500:
          return ResponseModel(data: null, error: "Server error!");
      }
    } catch (e) {
      return ResponseModel(data: null, error: e.toString());
    }

    return ResponseModel(data: null, error: "Something went wrong!");
  }

  Future<ResponseModel> getDocumentById(String token, String id) async {
    try {
      var response = await _client.get(
        Uri.parse(Constants.getDocumentById(id)),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token
        },
      );

      switch (response.statusCode) {
        case 200:
          return ResponseModel(
              data: DocumentModel.fromJson(response.body), error: null);
        case 500:
          return ResponseModel(data: null, error: "Server error!");
      }
    } catch (e) {
      return ResponseModel(data: null, error: e.toString());
    }
    return ResponseModel(data: null, error: "Something went wrong!");
  }
}
