import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/snippet.dart';

class SnippetProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Snippet> _snippets = [];

  List<Snippet> get snippets => _snippets;

  // CREATE: Aggiunge uno snippet su Firebase
  Future<void> addSnippet(Snippet snippet) async {
    try {
      await _db.collection('snippets').add(snippet.toMap());
      // Non c'è bisogno di fare altro, il listener in tempo reale aggiornerà la lista
    } catch (e) {
      print("Errore salvataggio snippet: $e");
    }
  }

  // READ: Ascolta gli snippet in tempo reale (solo quelli dell'utente loggato)
  void listenToSnippets(String userId) {
    _db
        .collection('snippets')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          _snippets = snapshot.docs
              .map((doc) => Snippet.fromFirestore(doc))
              .toList();
          notifyListeners(); // Questo comando aggiorna la grafica dello Sviluppatore B!
        });
  }

  // DELETE: Cancella uno snippet da Firebase usando il suo ID
  Future<void> deleteSnippet(String snippetId) async {
    try {
      await _db.collection('snippets').doc(snippetId).delete();
    } catch (e) {
      print("Errore cancellazione snippet: $e");
    }
  }
}
