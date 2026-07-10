import 'package:cloud_firestore/cloud_firestore.dart';

class Snippet {
  final String? id;
  final String title;
  final String code;
  final String language;
  final String userId;
  final DateTime timestamp;

  Snippet({
    this.id,
    required this.title,
    required this.code,
    required this.language,
    required this.userId,
    required this.timestamp,
  });

  // Converte un documento Firebase (JSON) in un oggetto Dart
  factory Snippet.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Snippet(
      id: doc.id,
      title: data['title'] ?? '',
      code: data['code'] ?? '',
      language: data['language'] ?? '',
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Converte l'oggetto Dart in una mappa JSON per inviarlo a Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'code': code,
      'language': language,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
