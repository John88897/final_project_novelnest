import '../model/interactiveStory.dart';
import '../model/storySection.dart';
import '../model/storySession.dart';
import 'exceptions.dart';

/// US-4: play an interactive story and reach different endings.
class StoryService {
  StorySession start(InteractiveStory story) => StorySession(story);

  /// Follows the choice at [choiceIndex] in the current section.
  /// Rules: story not finished, choice exists, target section exists.
  StorySection choose(StorySession session, int choiceIndex) {
    if (session.isComplete) {
      throw ServiceException('Story is already complete');
    }
    final choices = session.currentSection.choices;
    if (choiceIndex < 0 || choiceIndex >= choices.length) {
      throw ServiceException('Invalid choice $choiceIndex');
    }
    final targetId = choices[choiceIndex].targetSectionId;
    if (!session.story.sections.containsKey(targetId)) {
      throw ServiceException('Story section "$targetId" is missing');
    }
    session.currentSectionId = targetId;
    session.path.add(targetId);
    return session.currentSection;
  }

  /// Restart from the beginning.
  void restart(StorySession session) {
    session.currentSectionId = session.story.startSectionId;
    session.path
      ..clear()
      ..add(session.story.startSectionId);
  }
}
