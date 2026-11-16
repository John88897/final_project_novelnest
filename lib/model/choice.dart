/// A choice offered to the reader, leading to another section.

class Choice {
  final String text;
  final String targetSectionId;

  const Choice(this.text, this.targetSectionId);
}