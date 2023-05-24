import 'package:flutter/material.dart';

class Load extends StatelessWidget {
  const Load({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: SizedBox(
      width: 100,
      height: 100,
      child: CircularProgressIndicator(
        value: null,
        strokeWidth: 8,
      ),
    ));
  }
}
