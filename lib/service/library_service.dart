import '../model/library.dart';
import '../model/novel.dart';
import 'exceptions.dart';

/// US-1: browse and search novels.
class LibraryService {
  final Library library;

  LibraryService(this.library);

  /// Returns all novels (empty query) or those whose title/author match.
  /// An empty result is a valid outcome ("no matching novel found").
  List<Novel> search(String query) {
    if (query.trim().isEmpty) return library.novels;
    return library.novels.where((n) => n.matches(query)).toList();
  }

  /// Precondition: the novel must exist in the library.
  Novel getNovel(String novelId) {
    final novel = library.findById(novelId);
    if (novel == null) throw ServiceException('Novel "$novelId" not found');
    return novel;
  }
}
