import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SecondPage extends StatefulWidget {
  SecondPage({Key key}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Page"),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: [
              Text("Second Page"),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, '/homePage');
                  },
                  child: Text("ir para Home Page"))
            ],
          ),
        ),
      ),
    );
  }
}
