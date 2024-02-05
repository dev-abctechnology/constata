import 'package:flutter/material.dart';

String convertToValidTopicName(String topicName) {
  final topicWithoutSpaces = topicName // 1
      .replaceAll(' ', ''); // 2
  final topicWithoutSpecialCharacters =
      topicWithoutSpaces.replaceAll(RegExp(r'[^\w\s]+'), '');

  return topicWithoutSpecialCharacters;
}

class SafeOnTap extends StatefulWidget {
  const SafeOnTap({
    Key? key,
    required this.child,
    required this.onSafeTap,
    this.intervalMs = 500,
  }) : super(key: key);
  final Widget child;
  final GestureTapCallback onSafeTap;
  final int intervalMs;

  @override
  _SafeOnTapState createState() => _SafeOnTapState();
}

class _SafeOnTapState extends State<SafeOnTap> {
  int lastTimeClicked = 0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - lastTimeClicked < widget.intervalMs) {
          return;
        }
        lastTimeClicked = now;
        widget.onSafeTap();
      },
      child: widget.child,
    );
  }
}
