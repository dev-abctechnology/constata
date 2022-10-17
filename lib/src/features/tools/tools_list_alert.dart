import 'dart:developer' as developer;
import 'package:constata/src/features/tools/tools_form_alert.dart';
import 'package:flutter/material.dart';

class ToolListAlert extends StatefulWidget {
  var dataLogged;

  ToolListAlert({Key key, this.dataLogged}) : super(key: key);

  @override
  _ToolListAlertState createState() => _ToolListAlertState();
}

class _ToolListAlertState extends State<ToolListAlert> {
  @override
  Widget build(BuildContext context) {
    List tools = widget.dataLogged['obra']['data']['tb07_cp038'] != null
        ? widget.dataLogged['obra']['data']['tb07_cp038']
        : [];
    return AlertDialog(
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('voltar'))
      ],
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        // height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            tools.isEmpty
                ? Text('Não há ferramentas cadastradas na obra!')
                : Container(),
            ListView.builder(
                shrinkWrap: true,
                itemCount: tools.length,
                itemBuilder: (BuildContext ctx, int i) {
                  return Card(
                    child: InkWell(
                      onTap: () async {
                        var kk;
                        developer.log(tools[i].toString());
                        await showDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              return ToolsFormAlert(
                                tool: tools[i],
                              );
                            }).then((value) => {kk = value});
                        Navigator.pop(context, kk);
                      },
                      child: ListTile(
                        leading: Icon(Icons.handyman_outlined),
                        title: Text(tools[i]['tp_cp039']['name']),
                        subtitle: Text(tools[i]['tp_cp040']['name']),
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
