import '../models/snippet.dart';
import 'package:flutter/material.dart'; // Assicurati che ci sia questo import

class SnippetProvider with ChangeNotifier {
  // ... il resto del codice del tuo compagno o tuo rimane invariato
}
  static final SnippetProvider instance = SnippetProvider._internal();

  factory SnippetProvider() => instance;

  SnippetProvider._internal();

  final List<Snippet> _snippets = [];

  List<Snippet> get snippets => List.unmodifiable(_snippets);

  Future<void> listenToSnippets(String userId) async {
    _snippets.removeWhere((snippet) => snippet.userId != userId);
  }

  Future<void> addSnippet(Snippet snippet) async {
    _snippets.add(
      Snippet(
        id: snippet.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: snippet.title,
        code: snippet.code,
        language: snippet.language,
        userId: snippet.userId,
        timestamp: snippet.timestamp,
      ),
    );
  }

  Future<void> deleteSnippet(String id) async {
    _snippets.removeWhere((snippet) => snippet.id == id);
  }
}
