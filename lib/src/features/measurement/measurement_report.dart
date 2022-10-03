import 'dart:convert';

import 'package:constata_0_0_2/src/models/token.dart';
import 'package:constata_0_0_2/src/shared/verifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

import 'measurement_card.dart';
import 'measurement_services_dialog.dart';

class MeasurementReport extends StatefulWidget {
  Map dataLogged;

  var date;

  MeasurementReport({Key key, this.dataLogged, this.date}) : super(key: key);

  @override
  _MeasurementReportState createState() => _MeasurementReportState();
}

class _MeasurementReportState extends State<MeasurementReport> {
  List colaboradores = [];
  List aptosPresentes = [];
  Future fetchColaboradores() async {
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-pem-permd-00/filter'));
    request.body = json.encode({
      "filters": [
        {
          "fieldName": "data.tb01_cp123.tp_cp124.name",
          "value": "${widget.dataLogged['obra']['data']['tb01_cp002']}",
          "expression": "EQUAL"
        },
        {
          "fieldName": "data.tb01_cp123.tp_cp132",
          "value": "Sim",
          "expression": "EQUAL"
        },
      ]
    });
    request.headers.addAll(headers);

    print(request.body);

    try {
      print(DateTime.now());
      http.StreamedResponse response = await request.send();

      print(DateTime.now());
      developer.log('response.statusCode: ${response.statusCode}');
      if (response.statusCode == 200) {
        List temp = await verifications.checkPresenca(
            transformDate(widget.date.toString()),
            widget.dataLogged['obra']['data']['tb01_cp002'].toString(),
            context);
        var resposta = jsonDecode(await response.stream.bytesToString());
        print(resposta);
        colaboradores = resposta;
        if (temp.isEmpty) {
          colaboradores = [];
          return true;
        } else {
          List efetivo = temp[0]['data']['tb01_cp011'];

          List presentes;

          presentes = efetivo
              .where((element) => element['tp_cp015'] == 'Presente')
              .toList();

          print(jsonEncode(presentes));
          int loop = 0;
          for (var presente in presentes) {
            loop++;
            for (var colaborador in colaboradores) {
              loop++;
              if (colaborador['data']['tb01_cp002'] == presente['tp_cp013']) {
                aptosPresentes.add(colaborador);
              }
            }
          }
          print(aptosPresentes.length);
          colaboradores = aptosPresentes;
          print(loop);
          setState(() {});
          // print(colaboradores.length);
          return true;
        }
      }
    } catch (e, s) {
      print(DateTime.now());
      print(e);
      print(s);
      return false;
    }
  }

  Verifications verifications = Verifications();

  @override
  void initState() {
    super.initState();
    fetchColaboradores().then((value) {
      if (value != true) {
        SharedPreferences.getInstance().then((value) {
          if (value.containsKey('colaboradores')) {
            colaboradores = jsonDecode(value.getString('colaboradores'));
            // print(colaboradores);
            colaboradores = colaboradores
                .where((element) =>
                    element['data']['tb01_cp123'][0]['tp_cp132'] == "Sim")
                .toList();
            setState(() {});
          }
        });
      }
    });
    // print(widget.dataLogged['obra']['data']['tb02_cp080']);
    tasksAndCosts = widget.dataLogged['obra']['data']['tb02_cp080'];
    jsonBody['data']["h0_cp005"] =
        widget.dataLogged['empresa']['name'].toString();
    jsonBody['data']["h0_cp006"] = widget.dataLogged["local_negocio"]["name"];
    jsonBody['data']["h0_cp007"] = {
      "name": widget.dataLogged['obra']['data']["tb01_cp002"],
      "_id": widget.dataLogged['obra']['id']
    };
    jsonBody['data']["h0_cp008"] = transformDate(widget.date.toString());
    jsonBody['data']["h0_cp009"] = widget.dataLogged['user']['name'];
    jsonBody['data']['h0_cp013'] =
        widget.dataLogged['obra']['data']['tb01_cp026']['name'];
  }

  List measurementInner = [];

  List tasksAndCosts = [];
  String _selectedTask;

  bool status = false;
  Map totalByTypes = {};
  Map returndata;
  Map jsonBody = {
    "data": {
      "h0_cp002": "MEDI",
      "h0_cp003": '',
      "h0_cp004": "Apontamento de Medição",
      "tb01_cp050": [],
    },
    "ckc": "CONPROD001",
    "cko": "000000000000000000"
  };
  void showOverBudget() {
    mountTotalsByType();
    totalByTypes.forEach((key, value) {
      var task = tasksAndCosts
          .firstWhere((element) => element['tp_cp083']['name'] == key);
      if (task['tp_cp090'] == null) {
        task['tp_cp090'] = task['tp_cp087'];
      }
      if (task['tp_cp091'] == null) {
        task['tp_cp091'] = task['tp_cp084'];
      }
      // print(task['tp_cp090']);
      if (task['tp_cp090'] < value['value'] ||
          task['tp_cp091'] < value['quantidade']) {
        setState(() {
          status = false;
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("O orçamento foi ultrapassado"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("voltar"))
                ],
              );
            });
      } else {
        setState(() {
          status = true;
        });
      }
    });
  }

  void mountTotalsByType() {
    var result = jsonBody['data']['tb01_cp050']
        .map((e) => {
              'name': e["tp_cp055"]['name'],
              'value': e["tp_cp059"],
              'quantidade': e["tp_cp058"]
            })
        .toList();
    totalByTypes.clear();
    for (var item in result) {
      if (totalByTypes.containsKey(item['name'])) {
        totalByTypes.update(
            item['name'],
            (value) => {
                  'value': value['value'] + item['value'],
                  'quantidade': value['quantidade'] + item['quantidade']
                });
      } else {
        totalByTypes.putIfAbsent(item['name'],
            () => {'value': item['value'], 'quantidade': item['quantidade']});
      }
    }
  }

  Future alerta(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro no envio!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
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
              },
            ),
          ],
        );
      },
    );
  }

  void makeRequest() async {
    setState(() {
      status = false;
    });
    http.Request request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-inm-prjtm-00'));
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };

    request.body = jsonEncode(jsonBody);
    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 201) {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  content: Text('Medição enviada com sucesso'),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('voltar'))
                  ],
                )).then((value) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      } else {
        SharedPreferences.getInstance()
            .then((value) => value.setString("filaMedicao", request.body));
        alerta(context);
      }
    } catch (e) {
      print('err');
      SharedPreferences.getInstance()
          .then((value) => value.setString("filaMedicao", request.body));
      alerta(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medição - ${transformDate(widget.date.toString())}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Lista de efetivos da obra'),
            GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 1.85),
                shrinkWrap: true,
                itemCount: colaboradores.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: Card(
                      child: InkWell(
                        onTap: () async {
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: MeasureServiceDialog(
                                    dataLogged: widget.dataLogged,
                                    tasksAndCosts: tasksAndCosts,
                                    colaborator: {
                                      "name": colaboradores[index]['data']
                                          ['tb01_cp002'],
                                      "id": colaboradores[index]['id'],
                                      "rg": colaboradores[index]['data']
                                          ['tb01_cp004']
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('voltar'))
                                  ],
                                );
                              }).then((value) {
                            if (value != null) {
                              setState(() {
                                jsonBody['data']['tb01_cp050'].add({
                                  "tp_cp052": value.namePessoa,
                                  "tp_cp051": value.rg,
                                  "tp_cp053": {
                                    "name": value.localName,
                                    "_id": value.localId
                                  },
                                  "tp_cp054": {
                                    "name": value.typeServiceName,
                                    "_id": value.typeServiceId
                                  },
                                  "tp_cp055": {
                                    "name": value.serviceName,
                                    "_id": value.serviceId
                                  },
                                  "tp_cp056": {
                                    "name": value.unidadeName,
                                    "_id": value.unidadeId
                                  },
                                  "tp_cp057": value.valor_unitario,
                                  "tp_cp058": value.qte_consumida,
                                  "tp_cp059": value.total,
                                  "tp_cp060": value.observation,
                                  "_id": value.id
                                });
                                showOverBudget();
                              });
                            }
                          });
                        },
                        child: ListTile(
                          title: Center(
                            child: Text(
                                '${colaboradores[index]['data']['tb01_cp002']}'),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            Divider(),
            ListView.builder(
                shrinkWrap: true,
                itemCount: jsonBody["data"]["tb01_cp050"].length != 0
                    ? jsonBody["data"]["tb01_cp050"].length
                    : 0,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      child: MeasurementCard(
                    jsonBody: jsonBody["data"]["tb01_cp050"][index],
                    editing: true,
                    callback: () {
                      jsonBody["data"]["tb01_cp50"].removeAt(index);
                      setState(() {
                        jsonBody = jsonBody;
                        showOverBudget();
                      });
                    },
                  ));
                }),
            Divider(
              thickness: 2,
            ),
            Center(
              child: Column(children: [
                Text(" Totais por Serviço"),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: totalByTypes.length,
                    itemBuilder: (BuildContext context, int index) {
                      String key = totalByTypes.keys.elementAt(index);
                      return ListTile(
                        leading: Icon(Icons.account_balance),
                        title: Text(key),
                        trailing: Text('R\$ ' +
                            totalByTypes[key]['value']
                                .toString()
                                .replaceAll(".", ",")),
                      );
                    }),
              ]),
            ),
            Container(
              width: MediaQuery.of(context).size.width * .9,
              child: ElevatedButton(
                  onPressed: status
                      ? () {
                          makeRequest();
                        }
                      : null,
                  child: Text("Enviar")),
            )
          ],
        ),
      ),
    );
  }

  String transformDate(date) {
    List<String> datas = date.split('T')[0].split('-');
    return datas[2] + "/" + datas[1] + "/" + datas[0];
  }
}
