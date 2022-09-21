import 'dart:convert';

import 'dart:developer' as developer;
import 'package:constata_0_0_2/src/models/token.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class EpiReportTask extends StatefulWidget {
  Map dataLogged;
  String date;
  Map userSelected;

  EpiReportTask({Key key, this.dataLogged, this.date, this.userSelected})
      : super(key: key);

  @override
  _EpiReportTaskState createState() => _EpiReportTaskState();
}

class _EpiReportTaskState extends State<EpiReportTask> {
  List result;
  var body;
  List epiReport = [];

  void initializer() {
    print('iniciou a busca de EPIs');
    fetchEquipments().then(
      (value) async {
        if (value == true) {
          print('value true');
          setState(() {
            _isOffline = false;
          });
        } else {
          print('value false');
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          if (sharedPreferences.containsKey("epi")) {
            result = jsonDecode(sharedPreferences.getString("epi"));
            setState(() {
              _isOffline = true;
            });
            print(result);
          }
        }
      },
    );
  }

  Future fetchEquipments() async {
    setState(() {
      result = [];
    });
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-pem-ppemd-00/filter'));
    request.body = jsonEncode({"filters": []});
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        result = jsonDecode(await response.stream.bytesToString());
        setState(() {});
        print(result);
        return true;
      } else {
        print(response.reasonPhrase);
        setState(() {
          result = [];
        });
        return false;
      }
    } on Exception catch (e) {
      return false;
    }
  }

  construct(epi, quantity, reason) {
    var genUuid = const Uuid();
    try {
      epiReport.add({
        "tp_cp012": widget.date,
        "tp_cp013": "${epi['data']['tb01_cp001']}",
        "tp_cp014": "${epi['data']['tb01_cp003']}",
        "tp_cp015": "${epi['data']['tb01_cp004']}",
        "tp_cp016": "${epi['data']['tb01_cp002']}",
        "tp_cp017": "$quantity",
        "tp_cp018": "UN",
        "tp_cp019": "$reason",
        "_id": genUuid.v4()
      });
      // body.add(tempJson);
      // epiReport = body;
      developer.log(
        'quantidade de itens:  $epiReport',
        name: "CONTROLE DE EPI",
      );
      setState(() {});
    } catch (e, s) {
      developer.log(
        'Error',
        error: e,
        stackTrace: s,
        name: "CONTROLE DE EPI",
      );
    }
  }

  Future<bool> buildRequest(equipList) async {
    try {
      returnValue = json.encode({
        "data": {
          "h0_cp002": "EPI",
          "h0_cp003": null,
          "h0_cp004": "Controle de EPI",
          "h0_cp014": "${widget.userSelected['data']['tb01_cp004']}",
          "h0_cp054": widget.date,
          "h0_cp013": "${widget.userSelected['data']['tb01_cp002']}",
          "h0_cp005": {
            "name": "${widget.dataLogged['empresa']['name']}",
            "_id": "${widget.dataLogged['empresa']['id']}"
          },
          "h0_cp011": "${widget.dataLogged['local_negocio']['name']}",
          "h0_cp010": {
            "name": "${widget.dataLogged['obra']['data']['tb01_cp002']}",
            "_id": "${widget.dataLogged['obra']['id']}"
          },
          "h0_cp055":
              "${widget.dataLogged['obra']['data']['tb01_cp026']['name']}",
          "tb03_cp011": equipList
        },
        "ckc": "CONPROD001",
        "cko": "000000000000000000"
      });

      developer.log(returnValue, name: 'POST req');

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    initializer();
    print(widget.userSelected);
  }

  Map returnData = {};

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _textEditingController = TextEditingController();

  var returnValue;

  Future sendEpiReport() async {
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-ehm-ppeas-00'));
    request.body = returnValue;
    request.headers.addAll(headers);
    print(request.body);
    print('');
    developer.log(request.body, name: "Corpo da req");
    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 201) {
        print(await response.stream.bytesToString());
        return true;
      } else {
        // SharedPreferences.getInstance().then((value) =>
        //     value.setStringList("filaApontamentoEPI", [request.body]));
        // developer.log('queue added');
        buildListaEPI(request.body);
        return false;
      }
    } catch (e) {
      // SharedPreferences.getInstance().then(
      //     (value) => value.setStringList("filaApontamentoEPI", [request.body]));
      // developer.log('queue added');
      buildListaEPI(request.body);

      return false;
    }
  }

  Future buildListaEPI(request) async {
    SharedPreferences preferenciasCompartilhadas =
        await SharedPreferences.getInstance();
    if (preferenciasCompartilhadas.containsKey('filaApontamentoEPI')) {
      List fila =
          preferenciasCompartilhadas.getStringList("filaApontamentoEPI");
      fila.add(jsonEncode(jsonDecode(request)));
      SharedPreferences.getInstance()
          .then((value) => value.setStringList("filaApontamentoEPI", fila));
      print("ASDFDSFFDDS " + fila.toString());
    } else {
      SharedPreferences.getInstance().then(
          (value) => value.setStringList("filaApontamentoEPI", [request]));
      developer.log('PARABÉNS ZÉÉ HAHAHAHAHAHAHAHAHAHAHAHAHAHAH');
    }
  }

  bool _isOffline = false;

  bool status = false;

  final dropOpcoes = [
    'Primeira aquisição',
    'Troca por desgaste normal',
    'Troca por acidente',
    'Extravio'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isOffline
          ? AppBar(
              backgroundColor: Colors.red,
              title: Text('EPIs - ${widget.date}\nVocê está offline'),
              centerTitle: true,
            )
          : AppBar(
              title: Text('EPIs - ${widget.date}'),
              centerTitle: true,
            ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                colaboratorTile(),
                Divider(),
                epiReportListing(),
                sendButton(context),
                Text("Escolha o EPI"),
                result.isEmpty
                    ? const CircularProgressIndicator()
                    : epiSelectListing(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ListTile colaboratorTile() => ListTile(
        title: Center(
          child: Text('Nome: ' +
              widget.userSelected['data']['tb01_cp002'].toString() +
              '\nCódigo: ' +
              widget.userSelected['data']['tb01_cp004'].toString()),
        ),
      );

  GridView epiSelectListing() {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 1.5),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: result.isEmpty ? 0 : result.length,
        itemBuilder: (BuildContext context, int index) {
          final TextEditingController quantidadeEPI = TextEditingController();
          return Card(
              child: InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final _formKey = GlobalKey<FormState>();
                    final dropValue = ValueNotifier('');
                    return AlertDialog(
                      title: Text('${result[index]['data']['tb01_cp002']}'),
                      content: SingleChildScrollView(
                        child: SafeArea(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Informe a quantidade de EPIs entregues';
                                      }
                                      return null;
                                    },
                                    controller: quantidadeEPI,
                                    decoration: InputDecoration(
                                        icon: Icon(Icons.animation_outlined),
                                        labelText: 'Quantidade de EPIs'),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ValueListenableBuilder(
                                        valueListenable: dropValue,
                                        builder: (BuildContext context,
                                            String value, _) {
                                          return DropdownButton(
                                            isExpanded: true,
                                            hint:
                                                const Text('Motivo da entrega'),
                                            items: dropOpcoes
                                                .map(
                                                    (opcao) => DropdownMenuItem(
                                                          child: Text(opcao),
                                                          value: opcao,
                                                        ))
                                                .toList(),
                                            onChanged: (value) => dropValue
                                                .value = value.toString(),
                                            value:
                                                (value.isEmpty) ? null : value,
                                          );
                                        })),
                              ],
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: Colors.red),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancelar')),
                        ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                if (dropValue.value == null ||
                                    dropValue.value == '') {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Text(''),
                                        );
                                      });
                                } else {
                                  print('entrou no caso');
                                  construct(result[index], quantidadeEPI.text,
                                      dropValue.value);
                                  Navigator.pop(context);
                                  setState(() {
                                    dropValue.value == '';
                                  });
                                }
                              }
                            },
                            child: Text('Confirmar')),
                      ],
                      actionsAlignment: MainAxisAlignment.spaceBetween,
                    );
                  });
            },
            child: ListTile(
              title: Center(
                child: Text(result[index]['data']['tb01_cp002'].toString(),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    softWrap: false,
                    textScaleFactor: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
          ));
        });
  }

  ListView epiReportListing() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: epiReport.isEmpty ? 0 : epiReport.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: EdgeInsets.all(8),
              child: Card(
                  child: ListTile(
                title: Text('EPI: ${epiReport[index]['tp_cp016']}\n'
                    'Quantidade: ${epiReport[index]['tp_cp017']}\n'
                    'Motivo: ${epiReport[index]['tp_cp019']}\n'),
                trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                    onPressed: () {
                      print('Before: ${epiReport.length}');
                      epiReport.removeAt(index);
                      print('After: ${epiReport.length}');
                      setState(() {});
                    },
                    child: Icon(Icons.delete)),
              )));
        });
  }

  Container sendButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: epiReport.isNotEmpty
              ? () {
                  buildRequest(epiReport).then((value) {
                    if (value == true) {
                      sendEpiReport().then((value) {
                        if (value == true) {
                          var pop = Navigator.of(context);
                          pop.pop();
                          pop.pop();
                          pop.pop();

                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Text('Enviado com sucesso!'),
                                );
                              });
                        } else {
                          var nav = Navigator.of(context);
                          nav.pop();
                          nav.pop();
                          nav.pop();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Erro no envio!'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: const <Widget>[
                                        Text(
                                            'Parece que você está sem internet.'),
                                        Text(
                                            'O apontamento ficará pendente para envio.\n\nCertifique-se de estar conectado à internet para tentar novamente.'),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        }
                      });
                    } else {
                      var nav = Navigator.of(context);
                      nav.pop();
                      nav.pop();
                      nav.pop();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Erro ao enviar o apontamento!"),
                            );
                          });
                    }
                  });
                }
              : null,
          child: Text('Enviar')),
    );
  }
}
