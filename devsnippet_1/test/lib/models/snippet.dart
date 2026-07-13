import 'package:cloud_firestore/cloud_firestore.dart';

class Snippet {
  final String? id;
  final String title;
  final String code;
  final String language;
  final String userId;
  final DateTime timestamp;

  const Snippet({
    this.id,
    required this.title,
    required this.code,
    required this.language,
    required this.userId,
    required this.timestamp,
  });

  // Converte un documento Firestore in un oggetto Snippet
  factory Snippet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Snippet(
      id: doc.id,
      title: data['title'] ?? '',
      code: data['code'] ?? '',
      language: data['language'] ?? '',
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Converte uno Snippet in una mappa per Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'code': code,
      'language': language,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
