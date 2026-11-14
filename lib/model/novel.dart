import 'chapter.dart';

/// A novel stored locally. A Novel is composed of [Chapter]s.
class Novel {
  final String id;
  final String title;
  final String author;
  final List<Chapter> chapters;

  Novel({
    required this.id,
    required this.title,
    required this.author,
    required List<Chapter> chapters,
  }) : chapters = List.unmodifiable(chapters) {
    if (id.trim().isEmpty) throw ArgumentError('Novel id is required');
    if (title.trim().isEmpty) throw ArgumentError('Novel title is required');
    if (this.chapters.isEmpty) {
      throw ArgumentError('A novel needs at least one chapter');
    }
  }

  int get chapterCount => chapters.length;

  bool hasChapter(int index) => index >= 0 && index < chapters.length;

  Chapter chapterAt(int index) => chapters[index];

  /// True if the title or author contains [query] (case-insensitive).
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    return title.toLowerCase().contains(q) || author.toLowerCase().contains(q);
  }
}
