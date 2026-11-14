/// A choice offered to the reader, leading to another section.
class Choice {
  final String text;
  final String targetSectionId;

  const Choice(this.text, this.targetSectionId);
}

/// One section of an interactive story. An ending has no choices.
class StorySection {
  final String id;
  final String text;
  final List<Choice> choices;

  StorySection({
    required this.id,
    required this.text,
    List<Choice> choices = const [],
  }) : choices = List.unmodifiable(choices);

  bool get isEnding => choices.isEmpty;
}

/// An interactive story: a graph of [StorySection]s (composition).
class InteractiveStory {
  final String id;
  final String title;
  final String startSectionId;
  final Map<String, StorySection> sections;

  InteractiveStory({
    required this.id,
    required this.title,
    required this.startSectionId,
    required Iterable<StorySection> sections,
  }) : sections = {for (final s in sections) s.id: s} {
    if (!this.sections.containsKey(startSectionId)) {
      throw ArgumentError('Start section "$startSectionId" does not exist');
    }
  }
}

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
