import '../model/interactiveStory.dart';
import '../model/reader.dart';
import '../model/storySession.dart';
import 'exceptions.dart';
import 'library_service.dart';

/// US-2 / US-3: save and resume story progress, manage favorite stories.
class ReaderService {
  final LibraryService libraryService;

  ReaderService(this.libraryService);

  /// Saves the reader's session. Rule: the story must exist in the library.
  void saveProgress(Reader reader, StorySession session) {
    libraryService.getStory(session.story.id);
    reader.saveSession(session);
  }

  /// Returns the saved session, or starts a new one at the beginning
  /// if the reader has no saved progress for this story.
  StorySession resumeStory(Reader reader, String storyId) {
    final story = libraryService.getStory(storyId);
    final saved = reader.sessionFor(storyId);
    if (saved != null) return saved;
    final fresh = StorySession(story);
    reader.saveSession(fresh);
    return fresh;
  }

  /// Rules: the story must exist and must not already be a favorite.
  void addFavorite(Reader reader, String storyId) {
    libraryService.getStory(storyId);
    if (!reader.favoriteStoryIds.add(storyId)) {
      throw ServiceException('Story "$storyId" is already a favorite');
    }
  }

  /// Rule: the story must currently be a favorite.
  void removeFavorite(Reader reader, String storyId) {
    if (!reader.favoriteStoryIds.remove(storyId)) {
      throw ServiceException('Story "$storyId" is not a favorite');
    }
  }

  /// The reader's favorite stories (combines Reader and Library data).
  List<InteractiveStory> favorites(Reader reader) {
    return reader.favoriteStoryIds
        .map((id) => libraryService.library.findById(id))
        .whereType<InteractiveStory>()
        .toList();
  }
}