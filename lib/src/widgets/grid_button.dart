import 'package:flutter/material.dart';

import '../shared/pallete.dart';

class GridButton extends StatelessWidget {
  final void Function() onPressed;

  final Icon icon;

  final String label;

  const GridButton({Key key, this.onPressed, this.icon, this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          textStyle: const TextStyle(color: Colors.white),
          // backgroundColor: Palette.customSwatch.withOpacity(.9)
        ),
        onPressed: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            Text(
              label,
              textAlign: TextAlign.center,
            )
          ],
        ));
  }
}
