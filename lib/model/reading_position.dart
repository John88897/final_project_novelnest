/// A location inside a novel: chapter + character offset in that chapter.
/// Used for both reading progress and bookmarks.
class ReadingPosition {
  final String novelId;
  final int chapterIndex;
  final int offset;

  const ReadingPosition({
    required this.novelId,
    required this.chapterIndex,
    required this.offset,
  });

  @override
  bool operator ==(Object other) =>
      other is ReadingPosition &&
      other.novelId == novelId &&
      other.chapterIndex == chapterIndex &&
      other.offset == offset;

  @override
  int get hashCode => Object.hash(novelId, chapterIndex, offset);

  @override
  String toString() => 'ReadingPosition($novelId, ch $chapterIndex, @$offset)';
}
