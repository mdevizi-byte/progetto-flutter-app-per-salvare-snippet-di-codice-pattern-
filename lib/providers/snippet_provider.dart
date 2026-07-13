import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/snippet.dart';

class SnippetProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Snippet> _snippets = [];

  List<Snippet> get snippets => _snippets;

  // Ascolta gli snippet in tempo reale filtrati per l'utente loggato
  void listenToSnippets(String userId) {
    if (userId.isEmpty) return;

    _db
        .collection('snippets')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _snippets = snapshot.docs.map((doc) => Snippet.fromFirestore(doc)).toList();
      notifyListeners(); // Notifica la UI per aggiornare la grafica
    });
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
}
