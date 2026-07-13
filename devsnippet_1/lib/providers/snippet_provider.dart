import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 1. DEFINIZIONE DEL MODELLO DATI SNIPPET
class Snippet {
  final String? id;
  final String title;
  final String language;
  final String code;
  final String userId;

  Snippet({
    this.id,
    required this.title,
    required this.language,
    required this.code,
    required this.userId,
  });

  // Converte un documento Firestore in un oggetto Snippet
  factory Snippet.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Snippet(
      id: doc.id,
      title: data['title'] ?? '',
      language: data['language'] ?? '',
      code: data['code'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  // Converte uno Snippet in una mappa per Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'language': language,
      'code': code,
      'userId': userId,
    };
  }
}

// 2. IL PROVIDER CON LE LOGICHE BACK-END
class SnippetProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Snippet> _snippets = [];

  List<Snippet> get snippets => _snippets;

  // Ascolta gli snippet in tempo reale filtrati per l'utente loggato
  void listenToSnippets(String userId) {
    if (userId.isEmpty) return;
    
    _db
        .collection('snippets')
        .where('userId', ==: userId)
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
    } catch (e) {
      debugPrint("Errore durante l'aggiunta dello snippet: $e");
    }
  }

  // Cancella uno snippet da Firestore
  Future<void> deleteSnippet(String id) async {
    try {
      await _db.collection('snippets').doc(id).delete();
    } catch (e) {
      debugPrint("Errore durante la cancellazione dello snippet: $e");
    }
  }
}

