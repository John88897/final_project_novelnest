import '../model/novel.dart';
import '../model/reader.dart';
import '../model/reading_position.dart';
import 'exceptions.dart';
import 'library_service.dart';

/// US-2: read a novel and continue from saved progress.
class ReadingService {
  final LibraryService libraryService;

  ReadingService(this.libraryService);

  /// Validates that [chapterIndex]/[offset] is a real place in the novel.
  /// Offset may equal the chapter length (end of chapter) but not exceed it.
  void validatePosition(Novel novel, int chapterIndex, int offset) {
    if (!novel.hasChapter(chapterIndex)) {
      throw ServiceException(
          'Chapter $chapterIndex does not exist in "${novel.title}"');
    }
    final length = novel.chapterAt(chapterIndex).length;
    if (offset < 0 || offset > length) {
      throw ServiceException('Offset $offset is outside chapter $chapterIndex '
          '(0..$length)');
    }
  }

  /// Saves the reader's latest position (replaces any previous one).
  ReadingPosition saveProgress(
      Reader reader, String novelId, int chapterIndex, int offset) {
    final novel = libraryService.getNovel(novelId);
    validatePosition(novel, chapterIndex, offset);
    final pos = ReadingPosition(
        novelId: novelId, chapterIndex: chapterIndex, offset: offset);
    reader.progress[novelId] = pos;
    return pos;
  }

  /// Saved position, or the beginning of the novel if none exists.
  ReadingPosition continueReading(Reader reader, String novelId) {
    libraryService.getNovel(novelId);
    return reader.progress[novelId] ??
        ReadingPosition(novelId: novelId, chapterIndex: 0, offset: 0);
  }

  /// Progress through the novel as a fraction in 0.0..1.0 (multi-entity:
  /// uses Reader progress and Novel chapters).
  double progressFraction(Reader reader, String novelId) {
    final novel = libraryService.getNovel(novelId);
    final pos = continueReading(reader, novelId);
    final total = novel.chapters.fold<int>(0, (s, c) => s + c.length);
    if (total == 0) return 0.0;
    var read = pos.offset;
    for (var i = 0; i < pos.chapterIndex; i++) {
      read += novel.chapterAt(i).length;
    }
    return read / total;
  }
}
