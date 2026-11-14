import 'novel.dart';

/// The local collection of novels (aggregation: novels exist independently).
class Library {
  final List<Novel> _novels = [];

  Library([Iterable<Novel> novels = const []]) {
    novels.forEach(add);
  }

  List<Novel> get novels => List.unmodifiable(_novels);

  void add(Novel novel) {
    if (_novels.any((n) => n.id == novel.id)) {
      throw ArgumentError('Duplicate novel id: ${novel.id}');
    }
    _novels.add(novel);
  }

  Novel? findById(String id) {
    for (final n in _novels) {
      if (n.id == id) return n;
    }
    return null;
  }
}
