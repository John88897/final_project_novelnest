import 'storySection.dart';

import 'storySection.dart';

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
