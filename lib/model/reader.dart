import 'storySession.dart';

/// The user of the app. Owns (composition) their personal interactive story data:
/// favorites and active story playthrough sessions.
class Reader {
  final String name;
  final Set<String> favoriteStoryIds = {};
  final Map<String, StorySession> sessions = {};

  Reader(this.name);

  bool isFavorite(String storyId) => favoriteStoryIds.contains(storyId);

  StorySession? sessionFor(String storyId) => sessions[storyId];

  void saveSession(StorySession session) {
    sessions[session.story.id] = session;
  }

  void removeSession(String storyId) {
    sessions.remove(storyId);
  }
}
