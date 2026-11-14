

import '../lib/model/chapter.dart';
import '../lib/model/library.dart';
import '../lib/model/novel.dart';
import '../lib/model/reader.dart';
import '../lib/model/story.dart';
import '../lib/service/bookmark_service.dart';
import '../lib/service/library_service.dart';
import '../lib/service/reading_service.dart';
import '../lib/service/story_service.dart';

void main() {
  late Library library;
  late LibraryService libraryService;
  late ReadingService readingService;
  late BookmarkService bookmarkService;
  late StoryService storyService;
  late Reader reader;

  setUp(() {
    library = Library([
      Novel(id: 'n1', title: 'The Lost Island', author: 'Sok Dara', chapters: [
        Chapter(index: 0, title: 'Arrival', content: 'A' * 100),
        Chapter(index: 1, title: 'Storm', content: 'B' * 100),
      ]),
      Novel(id: 'n2', title: 'Moon Garden', author: 'Lina Chea', chapters: [
        Chapter(index: 0, title: 'Seed', content: 'C' * 50),
      ]),
    ]);
    libraryService = LibraryService(library);
    readingService = ReadingService(libraryService);
    bookmarkService = BookmarkService(libraryService, readingService);
    storyService = StoryService();
    reader = Reader('Sreyka');
  });

  InteractiveStory buildStory() => InteractiveStory(
        id: 's1',
        title: 'The Door',
        startSectionId: 'start',
        sections: [
          StorySection(id: 'start', text: 'A door.', choices: const [
            Choice('Open it', 'good'),
            Choice('Walk away', 'bad'),
            Choice('Broken link', 'ghost'),
          ]),
          StorySection(id: 'good', text: 'Treasure! The end.'),
          StorySection(id: 'bad', text: 'Boring. The end.'),
        ],
      );

  group('LibraryService.search', () {
    test('finds novels by title (case-insensitive) and by author', () {
      expect(libraryService.search('lost').map((n) => n.id), ['n1']);
      expect(libraryService.search('LINA CHEA').map((n) => n.id), ['n2']);
    });

    test('empty query returns the whole library', () {
      expect(libraryService.search('   '), hasLength(2));
    });

    test('no match returns an empty list (special case)', () {
      expect(libraryService.search('zzz'), isEmpty);
    });
  });

  group('ReadingService', () {
    test('saves progress and continues from it', () {
      readingService.saveProgress(reader, 'n1', 1, 40);
      final pos = readingService.continueReading(reader, 'n1');
      expect(pos, const ReadingPosition(novelId: 'n1', chapterIndex: 1, offset: 40));
    });

    test('novel with no progress opens at the beginning', () {
      final pos = readingService.continueReading(reader, 'n2');
      expect(pos.chapterIndex, 0);
      expect(pos.offset, 0);
    });

    test('rejects non-existing novel and invalid positions', () {
      expect(() => readingService.saveProgress(reader, 'nope', 0, 0),
          throwsA(isA<ServiceException>()));
      expect(() => readingService.saveProgress(reader, 'n1', 5, 0),
          throwsA(isA<ServiceException>()));
      expect(() => readingService.saveProgress(reader, 'n1', 0, -1),
          throwsA(isA<ServiceException>()));
    });

    test('boundary: offset equal to chapter length is OK, +1 is not', () {
      expect(() => readingService.saveProgress(reader, 'n1', 0, 100),
          returnsNormally);
      expect(() => readingService.saveProgress(reader, 'n1', 0, 101),
          throwsA(isA<ServiceException>()));
    });

    test('progressFraction spans chapters (multi-entity)', () {
      readingService.saveProgress(reader, 'n1', 1, 50); // 150 of 200
      expect(readingService.progressFraction(reader, 'n1'), closeTo(0.75, 1e-9));
      expect(readingService.progressFraction(reader, 'n2'), 0.0);
    });
  });

  group('BookmarkService', () {
    test('adds a bookmark and opens it', () {
      final b = bookmarkService.addBookmark(reader, 'n1', 0, 10, note: 'nice');
      expect(reader.bookmarksFor('n1'), hasLength(1));
      expect(bookmarkService.openBookmark(reader, b).offset, 10);
    });

    test('prevents duplicate bookmarks at the same position', () {
      bookmarkService.addBookmark(reader, 'n1', 0, 10);
      expect(() => bookmarkService.addBookmark(reader, 'n1', 0, 10),
          throwsA(isA<ServiceException>()));
      // A different position is still allowed.
      expect(() => bookmarkService.addBookmark(reader, 'n1', 0, 11),
          returnsNormally);
    });

    test('rejects bookmark on invalid chapter or missing novel', () {
      expect(() => bookmarkService.addBookmark(reader, 'n1', 9, 0),
          throwsA(isA<ServiceException>()));
      expect(() => bookmarkService.addBookmark(reader, 'x', 0, 0),
          throwsA(isA<ServiceException>()));
    });

    test('removes a bookmark; removing a missing one returns false', () {
      bookmarkService.addBookmark(reader, 'n1', 0, 10);
      const pos = ReadingPosition(novelId: 'n1', chapterIndex: 0, offset: 10);
      expect(bookmarkService.removeBookmark(reader, pos), isTrue);
      expect(bookmarkService.removeBookmark(reader, pos), isFalse);
      expect(reader.bookmarks, isEmpty);
    });

    test('favorites: add, duplicate rejected, remove, remove again rejected', () {
      bookmarkService.addFavorite(reader, 'n2');
      expect(reader.isFavorite('n2'), isTrue);
      expect(() => bookmarkService.addFavorite(reader, 'n2'),
          throwsA(isA<ServiceException>()));
      bookmarkService.removeFavorite(reader, 'n2');
      expect(reader.isFavorite('n2'), isFalse);
      expect(() => bookmarkService.removeFavorite(reader, 'n2'),
          throwsA(isA<ServiceException>()));
      expect(() => bookmarkService.addFavorite(reader, 'ghost'),
          throwsA(isA<ServiceException>()));
    });
  });

  group('StoryService', () {
    test('choices lead to different endings', () {
      final a = storyService.start(buildStory());
      storyService.choose(a, 0);
      expect(a.currentSectionId, 'good');
      expect(a.isComplete, isTrue);

      final b = storyService.start(buildStory());
      storyService.choose(b, 1);
      expect(b.currentSectionId, 'bad');
      expect(b.isComplete, isTrue);
      expect(b.path, ['start', 'bad']);
    });

    test('rejects out-of-range choices (boundary)', () {
      final s = storyService.start(buildStory());
      expect(() => storyService.choose(s, -1), throwsA(isA<ServiceException>()));
      expect(() => storyService.choose(s, 3), throwsA(isA<ServiceException>()));
    });

    test('never navigates to a missing section', () {
      final s = storyService.start(buildStory());
      expect(() => storyService.choose(s, 2), throwsA(isA<ServiceException>()));
      expect(s.currentSectionId, 'start');
    });

    test('cannot choose after the story is complete; restart works', () {
      final s = storyService.start(buildStory());
      storyService.choose(s, 0);
      expect(() => storyService.choose(s, 0), throwsA(isA<ServiceException>()));
      storyService.restart(s);
      expect(s.currentSectionId, 'start');
      expect(s.isComplete, isFalse);
    });
  });
}
