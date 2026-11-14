import 'bookmark.dart';
import 'reading_position.dart';

/// The user of the app. Owns (composition) their personal reading data:
/// favorites, bookmarks, and the latest progress per novel.
class Reader {
  final String name;
  final Set<String> favoriteNovelIds = {};
  final List<Bookmark> bookmarks = [];
  final Map<String, ReadingPosition> progress = {};

  Reader(this.name);

  bool isFavorite(String novelId) => favoriteNovelIds.contains(novelId);

  List<Bookmark> bookmarksFor(String novelId) =>
      bookmarks.where((b) => b.position.novelId == novelId).toList();
}
