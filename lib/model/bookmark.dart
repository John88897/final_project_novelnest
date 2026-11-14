import 'reading_position.dart';

class Bookmark {
  final ReadingPosition position;
  final String? note;
  final DateTime createdAt;
  Bookmark({required this.position, this.note, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();
}
