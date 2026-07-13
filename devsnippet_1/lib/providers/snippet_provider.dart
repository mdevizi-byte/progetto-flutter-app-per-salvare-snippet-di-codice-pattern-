import '../models/snippet.dart';
import 'package:flutter/material.dart';
// Eventuali altri import sotto...

class SnippetProvider with ChangeNotifier {
  // <--- LA PARENTESI GRAFFA DEVE APRIRSI SUBITO QUI!

  // Da qui in poi lascia il codice originale del file così com'era:
  static final SnippetProvider _instance = SnippetProvider._internal();
  
  factory SnippetProvider() => _instance;
  
  SnippetProvider._internal();

  // ... tutto il resto del vostro codice dei modelli e delle funzioni
}

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

