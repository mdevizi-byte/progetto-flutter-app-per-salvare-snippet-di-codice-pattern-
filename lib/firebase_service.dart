import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; 
import '../models/snippet.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Configurazione specifica per Chrome (Web) sul tuo computer
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "AIzaSyBVxFw8lYU7twtbxwqscnl6Gqq-ryPZ7lo", 
        appId: "1:936523733133:web:c418813272a2d2c0c3eac4", 
        messagingSenderId: "936523733133", 
        projectId: "devsnippet-app",                      
        storageBucket: "devsnippet-app.appspot.com",
      );
    }
    
    // Configurazione di sicurezza per Android e iOS se serviranno in futuro
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: "AIzaSyB-cXk9cU8sWvXfaWYFOfMR4Wh8tQ9KcCc", 
          appId: "1:936523733133:android:6e719b4cf0a86d22384a6b",
          messagingSenderId: "936523733133",
          projectId: "devsnippet-app",
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: "AIzaSyBegi1-i6nel3Ht2bcWAsL7kGNT1HdvFsk", 
          appId: "1:936523733133:ios:6e719b4cf0a86d22384a6b",
          messagingSenderId: "936523733133",
          projectId: "devsnippet-app",
          iosClientId: "936523733133-95m98c6f9fj1h1ta04soar4kba8n3g77.apps.googleusercontent.com", 
        );
      default:
        throw UnsupportedError('Piattaforma non supportata.');
    }
  }
}

class FirebaseService {
  static final CollectionReference _snippetsCollection = 
      FirebaseFirestore.instance.collection('snippets');

  static Stream<List<Snippet>> getSnippetsStream() {
    return _snippetsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Snippet(
              id: doc.id,
              title: data['title'] ?? '',
              code: data['code'] ?? '',
              language: data['language'] ?? 'Testo',
              userId: data['userId'] ?? '',
              timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList();
        });
  }

  static Future<void> addSnippet(Snippet snippet) async {
    await _snippetsCollection.add({
      'title': snippet.title,
      'code': snippet.code,
      'language': snippet.language,
      'userId': snippet.userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteSnippet(String id) async {
    await _snippetsCollection.doc(id).delete();
  }
}