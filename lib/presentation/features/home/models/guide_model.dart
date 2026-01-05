class GuideModel {
  final String id;
  final String title;
  final String category; // e.g., "Bão", "Lũ", "Sơ cứu", "Động đất"
  final String content; // Markdown content
  final String icon; // Icon asset path or name
  final bool isOffline;

  GuideModel({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.icon,
    this.isOffline = true,
  });
}
