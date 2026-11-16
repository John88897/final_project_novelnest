import 'interactiveStory.dart';
import 'storySection.dart';

/// A reader's current run through an [InteractiveStory].
class StorySession {
  final InteractiveStory story;
  String currentSectionId;
  final List<String> path;

  StorySession(this.story)
      : currentSectionId = story.startSectionId,
        path = [story.startSectionId];

  StorySection get currentSection => story.sections[currentSectionId]!;

  bool get isComplete => currentSection.isEnding;
}
