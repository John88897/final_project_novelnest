import 'package:test/test.dart';

import 'package:final_project_novelnest/model/choice.dart';
import 'package:final_project_novelnest/model/interactiveStory.dart';
import 'package:final_project_novelnest/model/library.dart';
import 'package:final_project_novelnest/model/reader.dart';
import 'package:final_project_novelnest/model/storySection.dart';
import 'package:final_project_novelnest/model/storySession.dart';
import 'package:final_project_novelnest/service/exceptions.dart';
import 'package:final_project_novelnest/service/library_service.dart';
import 'package:final_project_novelnest/service/reader_service.dart';
import 'package:final_project_novelnest/service/story_service.dart';

void main() {
  late LibraryService libraryService;
  late ReaderService readerService;
  late StoryService storyService;
  late Reader reader;

  InteractiveStory doorStory() => InteractiveStory(
        id: 's1',
        title: 'The Door',
        startSectionId: 'start',
        sections: [
          StorySection(id: 'start', text: 'A door.', choices: const [
            Choice('Open it', 'good'),
            Choice('Walk away', 'bad'),
          ]),
          StorySection(id: 'good', text: 'Treasure! The end.'),
          StorySection(id: 'bad', text: 'Boring. The end.'),
        ],
      );

  setUp(() {
    libraryService = LibraryService(Library([doorStory()]));
    readerService = ReaderService(libraryService);
    storyService = StoryService();
    reader = Reader('Sreyka');
  });

  group('saveProgress / resumeStory', () {
    test('saves progress and resumes from the same place', () {
      final session = storyService.start(libraryService.getStory('s1'));
      storyService.choose(session, 1);
      readerService.saveProgress(reader, session);

      final resumed = readerService.resumeStory(reader, 's1');
      expect(resumed.currentSectionId, 'bad');
      expect(resumed.path, ['start', 'bad']);
    });

    test('resume with no saved progress starts at the beginning', () {
      final session = readerService.resumeStory(reader, 's1');
      expect(session.currentSectionId, 'start');
      expect(reader.sessionFor('s1'), same(session));
    });

    test('resume rejects a story that does not exist', () {
      expect(() => readerService.resumeStory(reader, 'nope'),
          throwsA(isA<ServiceException>()));
    });

    test('saveProgress rejects a session for a story not in the library', () {
      final outsider = StorySession(InteractiveStory(
        id: 'other',
        title: 'Other',
        startSectionId: 'a',
        sections: [StorySection(id: 'a', text: 'x')],
      ));
      expect(() => readerService.saveProgress(reader, outsider),
          throwsA(isA<ServiceException>()));
      expect(reader.sessions, isEmpty);
    });
  });

  group('favorites', () {
    test('adds a favorite and lists it', () {
      readerService.addFavorite(reader, 's1');
      expect(reader.isFavorite('s1'), isTrue);
      expect(readerService.favorites(reader).map((s) => s.id), ['s1']);
    });

    test('rejects a duplicate favorite', () {
      readerService.addFavorite(reader, 's1');
      expect(() => readerService.addFavorite(reader, 's1'),
          throwsA(isA<ServiceException>()));
    });

    test('rejects a favorite for a non-existing story', () {
      expect(() => readerService.addFavorite(reader, 'ghost'),
          throwsA(isA<ServiceException>()));
      expect(reader.favoriteStoryIds, isEmpty);
    });

    test('removes a favorite; removing it again is rejected', () {
      readerService.addFavorite(reader, 's1');
      readerService.removeFavorite(reader, 's1');
      expect(reader.isFavorite('s1'), isFalse);
      expect(() => readerService.removeFavorite(reader, 's1'),
          throwsA(isA<ServiceException>()));
    });

    test('no favorites gives an empty list (special case)', () {
      expect(readerService.favorites(reader), isEmpty);
    });
  });
}