import 'dart:convert';
import 'dart:developer' as developer;
import 'package:constata/src/features/tools/tools_list_alert.dart';
import 'package:constata/src/models/token.dart';
import 'package:constata/src/shared/load_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToolsProcessPage extends StatefulWidget {
  var dataLogged;
  String date;
  ToolsProcessPage({Key? key, this.dataLogged, required this.date})
      : super(key: key);

  @override
  ToolsProcessPageState createState() => ToolsProcessPageState();
}

class ToolsProcessPageState extends State<ToolsProcessPage> {
  List toolsAppointment = [];

  Future sendApointment() async {
    setState(() {
      // _flag = true;
    });
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-lim-movld-00'));
    request.body = jsonEncode({
      "data": {
        "h0_cp002": "EMPRT",
        "h0_cp003": null,
        "h0_cp004": "Movim. de Empréstimo de Ferramenta",
        "h0_cp016": widget.date,
        "h0_cp005": {"name": "Constata", "_id": "60e5a9782212ef44c4d3b27e"},
        "h0_cp010": {
          "name": "${widget.dataLogged['obra']['data']['tb01_cp002']}",
          "_id": "${widget.dataLogged['obra']['id']}"
        },
        "h0_cp011": "${widget.dataLogged['local_negocio']['name']}",
        "h0_cp015":
            "${widget.dataLogged['obra']['data']['tb01_cp026']['name']}",
        "h0_cp017": "${widget.dataLogged['user']['name']}",
        "tb01_cp106": toolsAppointment
      },
      "ckc": "CONPROD001",
      "cko": "000000000000000000"
    });

    jsonEncode(toolsAppointment);
    request.headers.addAll(headers);
    developer.log(request.body);
    try {
      showLoading(context);
      http.StreamedResponse response = await request.send();
      print('body: ${request.body}\n\n');

      print(response.statusCode);

      if (response.statusCode == 201) {
        setState(() {
          // _flag = true;
        });
        print('enviou');
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: const Text("Apontamento enviado com sucesso!"),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      var nav = Navigator.of(context);
                      nav.pop();
                    },
                  ),
                ],
              );
            });
      } else {
        SharedPreferences.getInstance()
            .then((value) => value.setString("filaFerramentas", request.body));

        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erro no envio!'),
              content: const SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Parece que você está sem internet.'),
                    Text(
                        'O apontamento ficará pendente para envio.\n\nCertifique-se de estar conectado à internet para tentar novamente.'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    var nav = Navigator.of(context);
                    nav.pop();
                    nav.pop();
                    nav.pop();
                    nav.pop();
                  },
                ),
              ],
            );
          },
        );

        return false;
      }
    } catch (e) {
      SharedPreferences.getInstance()
          .then((value) => value.setString("filaFerramentas", request.body));

      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erro no envio!'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Parece que você está sem internet.'),
                  Text(
                      'O apontamento ficará pendente para envio.\n\nCertifique-se de estar conectado à internet para tentar novamente.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  var nav = Navigator.of(context);
                  nav.pop();
                  nav.pop();
                  nav.pop();
                  nav.pop();
                },
              ),
            ],
          );
        },
      );

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Ferramentas'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              var toolsApp;
              await showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return ToolListAlert(
                      dataLogged: widget.dataLogged,
                    );
                  }).then((value) => {toolsApp = value});
              print(toolsApp);
              if (toolsApp != null) {
                toolsAppointment.add(toolsApp);
              }
              setState(() {});
            },
            child: const Icon(Icons.handyman)),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              toolsAppointment.isEmpty
                  ? Container(
                      padding: EdgeInsets.fromLTRB(
                          16, MediaQuery.sizeOf(context).height / 2, 16, 0),
                      child: const Text(
                        'Clique no botão abaixo para adicionar um apontamento de ferramentas.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    toolsAppointment.isEmpty ? 0 : toolsAppointment.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext ctx, int i) {
                  return Card(
                    elevation: 5,
                    child: InkWell(
                      onTap: () {},
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(4),
                        title: Text(
                            'Ferramenta: ${toolsAppointment[i]['tp_cp108']['name']}\n'
                            'fornecedor: ${toolsAppointment[i]['tp_cp109']['name']}'),
                        leading:
                            Text('Entrada: ${toolsAppointment[i]['tp_cp110']}\n'
                                'Saida: ${toolsAppointment[i]['tp_cp111']}'),
                        trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () {
                              setState(() {
                                toolsAppointment.remove(toolsAppointment[i]);
                                print(toolsAppointment.length);
                              });
                            },
                            child: const SizedBox(
                              height: double.maxFinite,
                              child: Icon(
                                Icons.delete,
                              ),
                            )),
                      ),
                    ),
                  );
                },
              ),
              toolsAppointment.isNotEmpty
                  ? ElevatedButton(
                      onPressed: () {
                        sendApointment();
                        // showDialog(
                        //     context: context,
                        //     builder: (BuildContext context) {
                        //       return AlertDialog(
                        //         content: Text('$toolsAppointment'),
                        //       );
                        //     });
                      },
                      child: const Text('Enviar'))
                  : Container()
            ],
          ),
        ));
  }
}
