class Chapter {
  final int index;
  final String title;
  final String content;

  Chapter({required this.index, required this.title, required this.content}) {
    if (index < 0) throw ArgumentError('Chapter index cannot be nagative');
    if (title.trim().isEmpty) throw ArgumentError('Chapter title is required');
  }
  int get length => content.length;
}
