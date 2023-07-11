import 'dart:developer' as developer;
import 'package:constata/src/features/tools/tools_form_alert.dart';
import 'package:flutter/material.dart';

class ToolListAlert extends StatefulWidget {
  var dataLogged;

  ToolListAlert({Key? key, this.dataLogged}) : super(key: key);

  @override
  _ToolListAlertState createState() => _ToolListAlertState();
}

class _ToolListAlertState extends State<ToolListAlert> {
  @override
  Widget build(BuildContext context) {
    List tools = widget.dataLogged['obra']['data']['tb07_cp038'] ?? [];
    return AlertDialog(
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('voltar'))
      ],
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.8,
        // height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            tools.isEmpty
                ? const Text('Não há ferramentas cadastradas na obra!')
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
                        leading: const Icon(Icons.handyman_outlined),
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
