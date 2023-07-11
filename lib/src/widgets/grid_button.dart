import 'package:flutter/material.dart';


class GridButton extends StatelessWidget {
  final void Function() onPressed;

  final Icon icon;

  final String label;

  const GridButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          // backgroundColor: color.withOpacity(.85),
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
              overflow: TextOverflow.ellipsis,
            )
          ],
        ));
  }
}
