import 'interactiveStory.dart';

/// The local collection of interactive stories (aggregation: stories exist independently).
class Library {
  final List<InteractiveStory> _stories = [];

  Library([Iterable<InteractiveStory> stories = const []]) {
    stories.forEach(add);
  }

  List<InteractiveStory> get stories => List.unmodifiable(_stories);

  void add(InteractiveStory story) {
    if (_stories.any((s) => s.id == story.id)) {
      throw ArgumentError('Duplicate story id: ${story.id}');
    }
    _stories.add(story);
  }

  InteractiveStory? findById(String id) {
    for (final s in _stories) {
      if (s.id == id) return s;
    }
    return null;
  }
}
