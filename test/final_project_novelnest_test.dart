import 'dart:math';

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
      StorySection(
        id: 'start',
        text: 'A door.',
        choices: const [Choice('Open it', 'good'), Choice('Walk away', 'bad')],
      ),
      StorySection(id: 'good', text: 'Treasure! The end.'),
      StorySection(id: 'bad', text: 'Boring. The end.'),
    ],
  );

  InteractiveStory brokenStory() => InteractiveStory(
    id: 's1',
    title: 'Broken Path',
    startSectionId: 'start',
    sections: [
      StorySection(
        id: 'start',
        text: 'Opps.',
        choices: const [Choice('Go', 'ghost')],
      ),
    ],
  );
  setUp(() {
    libraryService = LibraryService(
      Library([
        doorStory(),
        InteractiveStory(
          id: 's2',
          title: 'Haunted House',
          startSectionId: 'a',
          sections: [StorySection(id: 'a', text: 'Boo. The end')],
        ),
      ]),
    );
    readerService = ReaderService(libraryService);
    storyService = StoryService();
    reader = Reader('Sreyka');
  });

  group('LibraryService', () {
    test('search finds a story by title, ', () {
      expect(libraryService.search('DOOR').map((s) => s.id), ['s1']);
    });

    test('empty query return the whole library', () {
      expect(libraryService.search('  '), hasLength(2));
    });

    test('getStory rejects a non-existing story', () {
      expect(
        () => libraryService.getStory('nope'),
        throwsA(isA<ServiceException>()),
      );
    });
  });

  group('StoryService', () {
    test('different choices lead to different endings', () {
      final a = storyService.start(doorStory());
      storyService.choose(a, 0);
      expect(a.currentSectionId, 'good');
      expect(a.isComplete, isTrue);

      final b = storyService.start(doorStory());
      storyService.choose(b, 1);
      expect(b.currentSectionId, 'bad');
      expect(b.path, ['start', 'bad']);
    });

    test('boundary: index -1 and index == length are rejected', () {
      final s = storyService.start(doorStory());
      expect(
        () => storyService.choose(s, -1),
        throwsA(isA<ServiceException>()),
      );
      expect(() => storyService.choose(s, 2), throwsA(isA<ServiceException>()));
    });

    test('never navigates to a missing section', () {
      final s = storyService.start(brokenStory());
      expect(() => storyService.choose(s, 0), throwsA(isA<ServiceException>()));
      expect(s.currentSectionId, 'start');
    });

    test('cannot choose after the story is complete', () {
      final s = storyService.start(doorStory());
      storyService.choose(s, 0);
      expect(() => storyService.choose(s, 0), throwsA(isA<ServiceException>()));
    });
  });

  group('ReaderService', () {
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

    test('saveProgress rejects a session for a story not in the library', () {
      final outsider = StorySession(
        InteractiveStory(
          id: 'other',
          title: 'Other',
          startSectionId: 'a',
          sections: [StorySection(id: 'a', text: 'x')],
        ),
      );
      expect(
        () => readerService.saveProgress(reader, outsider),
        throwsA(isA<ServiceException>()),
      );
      expect(reader.sessions, isEmpty);
    });

    test('adds a favorite and lists it', () {
      readerService.addFavorite(reader, 's1');
      expect(reader.isFavorite('s1'), isTrue);
      expect(readerService.favorites(reader).map((s) => s.id), ['s1']);
    });

    test('rejects a duplicate favorite', () {
      readerService.addFavorite(reader, 's1');
      expect(
        () => readerService.addFavorite(reader, 's1'),
        throwsA(isA<ServiceException>()),
      );
    });
  });
}
