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
}
