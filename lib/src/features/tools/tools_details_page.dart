import 'package:flutter/material.dart';

class ToolsDetails extends StatefulWidget {
  var tool;

  ToolsDetails({Key key, this.tool}) : super(key: key);

  @override
  _ToolsDetailsState createState() => _ToolsDetailsState();
}

class _ToolsDetailsState extends State<ToolsDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [Text(widget.tool.toString())],
        ),
      ),
    );
  }
}
