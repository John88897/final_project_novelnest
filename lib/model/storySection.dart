import 'choice.dart';
import 'choice.dart';

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
