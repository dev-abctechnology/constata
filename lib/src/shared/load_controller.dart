import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'load_component.dart';

showLoading(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: Load(),
      );
    },
  );
}
