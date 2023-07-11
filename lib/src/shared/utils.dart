String convertToValidTopicName(String topicName) {
  final topicWithoutSpaces = topicName // 1
      .replaceAll(' ', ''); // 2
  final topicWithoutSpecialCharacters =
      topicWithoutSpaces.replaceAll(RegExp(r'[^\w\s]+'), '');

  return topicWithoutSpecialCharacters;
}
