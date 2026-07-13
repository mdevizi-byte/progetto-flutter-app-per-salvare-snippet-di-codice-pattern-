import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/snippet.dart';

class SnippetProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Snippet> _snippets = [];
  StreamSubscription<QuerySnapshot>? _sub;

  List<Snippet> get snippets => _snippets;

  // Ascolta gli snippet in tempo reale filtrati per l'utente loggato
  void listenToSnippets(String userId) {
    // Cancella eventuale sottoscrizione precedente
    _sub?.cancel();

    if (userId.isEmpty) {
      debugPrint(
          'listenToSnippets: userId vuoto, nessuna sottoscrizione creata');
      _snippets = [];
      notifyListeners();
      return;
    }

    try {
      final query = _db
          .collection('snippets')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true);

      _sub = query.snapshots().listen((snapshot) {
        _snippets =
            snapshot.docs.map((doc) => Snippet.fromFirestore(doc)).toList();
        debugPrint(
            'listenToSnippets: ricevuti ${_snippets.length} snippet per user $userId');
        notifyListeners();
      }, onError: (err) {
        debugPrint('listenToSnippets error: $err');
      });
    } catch (e) {
      debugPrint('listenToSnippets exception: $e');
    }
  }

  // Aggiunge un nuovo snippet su Firestore
  Future<void> addSnippet(Snippet snippet) async {
    try {
      await _db.collection('snippets').add(snippet.toFirestore());
      // Non serve aggiornare _snippets manualmente: lo stream di
      // listenToSnippets riceverà già il nuovo documento.
    } catch (e) {
      debugPrint("Errore durante l'aggiunta dello snippet: $e");
    }
  }

  // Cancella uno snippet da Firestore usando l'ID del documento
  Future<void> deleteSnippet(String id) async {
    try {
      await _db.collection('snippets').doc(id).delete();
      _snippets.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Errore durante la cancellazione dello snippet: $e");
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
