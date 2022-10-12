import 'dart:convert';

import 'package:constata/src/features/measurement/data/measurement_data.dart';
import 'package:constata/src/features/measurement/measurement_details.dart';
import 'package:constata/src/models/token.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'measurement_report.dart';
import 'measurement_report_r.dart';

class Measurement extends StatefulWidget {
  var dataLogged;

  Measurement({Key key, this.dataLogged}) : super(key: key);

  @override
  _MeasurementState createState() => _MeasurementState();
}

class _MeasurementState extends State<Measurement> with NavigatorObserver {
  String _selectedDate = "Data do apontamento";
  String _date = null;
  bool status = false;
  bool dateStatus = false;
  List medicaoPendente = [];
  bool sending = false;

  void rascunho() {
    if (Provider.of<MeasurementData>(context, listen: false).measurementData !=
        null) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Rascunho encontrado"),
              content: Text("Deseja continuar o rascunho?"),
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: [
                TextButton(
                  child: Text("Não"),
                  onPressed: () {
                    Provider.of<MeasurementData>(context, listen: false)
                        .clearMeasurementData();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MeasurementReportReworked(
                                  dataLogged: widget.dataLogged,
                                  date: Provider.of<MeasurementData>(context,
                                          listen: false)
                                      .measurementData
                                      .data
                                      .date,
                                  edittingMode: true,
                                )));
                  },
                ),
              ],
            );
          });
    } else {
      print('não tem rascunho');
    }
  }

  Future<void> _openDatePicker(BuildContext context) async {
    setState(() {
      res = [];
    });

    final DateTime d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(
        Duration(days: 1000),
      ),
      lastDate: DateTime.now().add(
        Duration(days: 0),
      ),
    );
    if (d != null) {
      setState(() {
        k = DateTime.now().isAfter(d.add(Duration(days: 3)));
        if (k == true) {
          dateStatus = false;
        }
        if (k == false) {
          dateStatus = true;
        }

        _selectedDate = DateFormat(" d 'de' MMMM 'de' y", "pt_BR").format(d);
        _date = DateFormat('dd/MM/yyyy', "pt_BR").format(d);
        // _date = DateFormat('yyyy-MM-ddTHH:mm:ss', "pt_BR").format(d);
        var _date2 = DateFormat('yyyy-MM-ddTHH:mm:ss', "pt_BR").format(d);
        print('jarvis: 2021-11-12T00:00:00');
        print('timePicker: $d');
        print('converted: $_date2');
        //2021-11-12T00:00:00
        SharedPreferences.getInstance().then((value) {
          if (!value.containsKey('filaMedicao')) {
            status = true;
            fetchRelatorios(null);
          } else {
            status = false;
          }
        });
      });
    }
  }

  //{timestamp: 2021-11-12T13:33:31.491+0000, status: 500, error: Internal Server Error, message: No value present, path: /jarvis/api/stuffdata/sdt_a-inm-prjre-00}

  @override
  void initState() {
    super.initState();
    updateFila();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      rascunho();
    });
  }

  void updateFila() async {
    SharedPreferences.getInstance().then((value) {
      if (value.containsKey('filaMedicao')) {
        setState(() {
          status = false;
        });
        medicaoPendente = [jsonDecode(value.getString('filaMedicao'))];
        setState(() {});
      }
    });
  }

  void eliminateQueue() {
    SharedPreferences.getInstance().then((value) {
      value.remove('filaMedicao');
      setState(() {
        medicaoPendente.clear();
      });
    });
  }

  String transformDate(date) {
    List<String> datas = date.split('T')[0].split('-');
    return datas[2] + "/" + datas[1] + "/" + datas[0];
  }

  Future<bool> fetchRelatorios(date) async {
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    if (date == null) {
      date = transformDate(_date);
    }
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-inm-prjtm-00/filter'));
    request.body =
        '''{"filters":[{"fieldName":"data.h0_cp008","value":"$date","expression":"EQUAL"},{"fieldName": "data.h0_cp007.name","value": "${widget.dataLogged['obra']['data']['tb01_cp002']}","expression": "EQUAL"}],"sort":{"fieldName":"data.h0_cp008","type":"ASC"}}''';
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      res = jsonDecode(await response.stream.bytesToString());
      setState(() {
        res;
        if (res.length > 0) {
          status = false;
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Escolha outra data!"),
                  content: Text(
                      'Na data selecionada já existe um apontamento de medição.'),
                );
              });
          return true;
        }
      });

      print(res.length);
      return false;
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                  'Não foi possivel verificar se houve uma medição no dia '),
            );
          });
      print(response.reasonPhrase);
      return false;
    }
  }

  void makeRequestOffline(body) async {
    http.Request request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-inm-prjtm-00'));
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };

    request.body = jsonEncode(body);
    request.headers.addAll(headers);
    if (await fetchRelatorios(body["data"]["h0_cp008"])) {
      setState(() {
        _selectedDate = body["data"]["h0_cp008"];
        sending = false;
      });
      return;
    }
    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 201) {
        eliminateQueue();
        setState(() {
          sending = false;
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("Apontamento enviado com sucesso!"),
              );
            });
      } else {
        print('error' + response.statusCode.toString());
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("Erro inesperado tente novamente"),
              );
            });
        setState(() {
          sending = false;
        });
      }
    } catch (e) {
      setState(() {
        sending = false;
      });
      print('err');
    }
  }

  List res = [];
  bool k = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2 - Controle de medição'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _openDatePicker(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_selectedDate),
                            IconButton(
                                onPressed: () {
                                  _openDatePicker(context);
                                },
                                icon: Icon(Icons.calendar_today)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.95,
                          height: MediaQuery.of(context).size.height * 0.065,
                          child: ElevatedButton(
                            onPressed: status == true && dateStatus == true
                                ? () {
                                    setState(() {
                                      var route = MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            MeasurementReportReworked(
                                          dataLogged: widget.dataLogged,
                                          date: _date,
                                        ),
                                      );
                                      Navigator.of(context).pop();

                                      Navigator.of(context).push(route);
                                    });
                                  }
                                : null,
                            child: Text("Apontar"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Text(
                    "${medicaoPendente.isEmpty ? '' : 'Apontamentos aguardando envio'}"),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      medicaoPendente.isEmpty ? 0 : medicaoPendente.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        leading: ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: Colors.red),
                            onPressed: () {
                              eliminateQueue();
                            },
                            child: Icon(Icons.delete)),
                        title: Text(
                            'Data: ${medicaoPendente[index]["data"]['h0_cp008']}'),
                        trailing: ElevatedButton(
                          onPressed: !sending
                              ? () {
                                  setState(() {
                                    sending = true;
                                  });
                                  makeRequestOffline(medicaoPendente[index]);
                                }
                              : null,
                          child: Icon(Icons.arrow_circle_up),
                        ),
                      ),
                    );
                  }),
              ListTile(
                title: res.isEmpty
                    ? null
                    : Center(child: Text('Apontamentos do dia $_selectedDate')),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: res.isEmpty ? 0 : res.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Card(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              var route = MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    MeasurementDetails(
                                  measurement: res[index],
                                ),
                              );
                              Navigator.of(context).push(route);
                            });
                          },
                          child: ListTile(
                            title: Text('${res[index]['data']['h0_cp008']}'),
                          ),
                        ),
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
