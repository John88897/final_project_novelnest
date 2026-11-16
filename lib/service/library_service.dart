import '../model/interactiveStory.dart';
import '../model/library.dart';
import 'exceptions.dart';

/// US-1: browse and search interactive stories.
class LibraryService {
  final Library library;

  LibraryService(this.library);

  /// Returns all stories (empty query) or those whose title matches.
  List<InteractiveStory> search(String query) {
    if (query.trim().isEmpty) return library.stories;
    final q = query.trim().toLowerCase();
    return library.stories
        .where((s) => s.title.toLowerCase().contains(q))
        .toList();
  }

  /// Precondition: the story must exist in the library.
  InteractiveStory getStory(String storyId) {
    final story = library.findById(storyId);
    if (story == null) throw ServiceException('Story "$storyId" not found');
    return story;
  }
}
