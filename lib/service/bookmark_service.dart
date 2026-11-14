import '../model/bookmark.dart';
import '../model/reader.dart';
import '../model/reading_position.dart';
import 'exceptions.dart';
import 'library_service.dart';
import 'reading_service.dart';

/// US-3: manage bookmarks and favorite novels.
class BookmarkService {
  final LibraryService libraryService;
  final ReadingService readingService;

  BookmarkService(this.libraryService, this.readingService);

  /// Multi-entity operation (Reader + Novel + Chapter).
  /// Rules: novel exists, position is valid, no duplicate at the same position.
  Bookmark addBookmark(Reader reader, String novelId, int chapterIndex,
      int offset, {String? note}) {
    final novel = libraryService.getNovel(novelId);
    readingService.validatePosition(novel, chapterIndex, offset);
    final pos = ReadingPosition(
        novelId: novelId, chapterIndex: chapterIndex, offset: offset);
    if (reader.bookmarks.any((b) => b.position == pos)) {
      throw ServiceException('A bookmark already exists at $pos');
    }
    final bookmark = Bookmark(position: pos, note: note);
    reader.bookmarks.add(bookmark);
    return bookmark;
  }

  /// Returns true if a bookmark was removed.
  bool removeBookmark(Reader reader, ReadingPosition position) {
    final before = reader.bookmarks.length;
    reader.bookmarks.removeWhere((b) => b.position == position);
    return reader.bookmarks.length < before;
  }

  /// Opening a bookmark returns its position (reader jumps there).
  ReadingPosition openBookmark(Reader reader, Bookmark bookmark) {
    if (!reader.bookmarks.contains(bookmark)) {
      throw ServiceException('Bookmark does not belong to this reader');
    }
    return bookmark.position;
  }

  void addFavorite(Reader reader, String novelId) {
    libraryService.getNovel(novelId);
    if (!reader.favoriteNovelIds.add(novelId)) {
      throw ServiceException('Novel "$novelId" is already a favorite');
    }
  }

  void removeFavorite(Reader reader, String novelId) {
    if (!reader.favoriteNovelIds.remove(novelId)) {
      throw ServiceException('Novel "$novelId" is not a favorite');
    }
  }
}
