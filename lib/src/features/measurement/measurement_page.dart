// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:constata/src/constants.dart';
import 'package:constata/src/features/measurement/data/measurement_data.dart';
import 'package:constata/src/features/measurement/measurement_details.dart';
import 'package:constata/src/features/measurement/measurement_report_r.dart';
import 'package:constata/src/models/token.dart';
import 'package:constata/src/shared/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/measurement_model.dart';
import 'model/measurement_object_r.dart';

class Measurement extends StatefulWidget {
  final Map dataLogged;

  const Measurement({Key? key, required this.dataLogged}) : super(key: key);

  @override
  _MeasurementState createState() => _MeasurementState();
}

class _MeasurementState extends State<Measurement> {
  String _selectedDate = "Data do apontamento";
  String _date = '';
  bool status = false;
  bool dateStatus = false;
  List medicaoPendente = [];
  bool sending = false;

  void rascunho() {
    if (Provider.of<MeasurementData>(context, listen: false).hasData == true) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Rascunho encontrado"),
              content: const Text("Deseja continuar o rascunho?"),
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: [
                TextButton(
                  child: const Text("Não"),
                  onPressed: () {
                    Provider.of<MeasurementData>(context, listen: false)
                        .clearMeasurementData();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Sim"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        CustomPageRoute(
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

    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 1000),
      ),
      lastDate: DateTime.now().add(
        const Duration(days: 0),
      ),
    );
    if (d != null) {
      setState(() {
        k = DateTime.now().isAfter(d.add(const Duration(days: 3)));
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
            fetchRelatorios(_date);
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
          Provider.of<MeasurementData>(context, listen: false)
              .clearMeasurementData();
        });
        medicaoPendente = [jsonDecode(value.getString('filaMedicao')!)];

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
    // if (date == null) {
    //   date = transformDate(_date);
    // }
    print('date: $date');
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

      res;
      if (res.isNotEmpty) {
        status = false;
        showSnackBar('Na data selecionada já existe um relatório', Colors.red);
        setState(() {});
        return true;
      } else {
        print(res.length);
        setState(() {});
        return false;
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Text(
                  'Não foi possivel verificar se houve uma medição no dia '),
            );
          });
      print(response.reasonPhrase);
      return false;
    }
  }

  Future<Map<String, dynamic>> effectiveValidator(
      {required Map<String, dynamic> offlineMeasurement}) async {
    String date = offlineMeasurement['data']['h0_cp008'];
    String obra = offlineMeasurement['data']['h0_cp007']['name'];

    print(date);
    print(obra);
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST', Uri.parse('$apiUrl/stuffdata/sdt_a-inm-prjre-00/filter'));
    request.body = jsonEncode({
      "filters": [
        {"fieldName": "data.h0_cp008", "value": date, "expression": "EQUAL"},
        {
          "fieldName": "data.h0_cp013.name",
          "value": obra,
          "expression": "EQUAL"
        }
      ]
    });
    request.headers.addAll(headers);

    print(request.body);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var res = jsonDecode(await response.stream.bytesToString());
      print(res);
      if (res.length > 0) {
        List data = res[0]['data']['tb01_cp011'];
        List presentes = [];
        for (var index = 0; index < data.length; index++) {
          if (data[index]['tp_cp015'] == "Presente") {
            presentes.add(data[index]);
          }
        }

        MeasurementAppointment measurementdata =
            MeasurementAppointment.fromJson(offlineMeasurement);

        print('${presentes.length} presentes');
        print('${measurementdata.data.measurements.length} medições');
        List<MeasurementModel> medicoes = measurementdata.data.measurements;
        List<MeasurementModel> medicoesPresentes = [];
        for (MeasurementModel medicao in medicoes) {
          for (var i = 0; i < presentes.length; i++) {
            if (medicao.codePerson == presentes[i]['tp_cp012']) {
              print(presentes[i]['tp_cp012'] +
                  ' == ' +
                  medicao.codePerson +
                  ' ✓');
              medicoesPresentes.add(medicao);
            } else {
              print(presentes[i]['tp_cp012'] +
                  ' == ' +
                  medicao.codePerson +
                  ' ✗');
            }
          }
        }

        print('${measurementdata.data.measurements.length} medições originais');
        print('${medicoesPresentes.length} medições presentes');
        measurementdata.data.measurements = medicoesPresentes;
        print('${measurementdata.data.measurements.length} medições finais');
        return measurementdata.toJson();
      } else {
        throw Exception(
            'Não foi possivel verificar se houve uma medição no dia');
      }
    } else {
      throw Exception('Não foi possivel verificar se houve uma medição no dia');
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
    var efetivo = await fetchRelatorios(body["data"]["h0_cp008"]);

    if (efetivo == true) {
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
        showSnackBar(
            'Apontamento de medição enviado com sucesso!', Colors.green);
      } else {
        print('error' + response.statusCode.toString());
        showSnackBar('Erro ao enviar apontamento de medição!', Colors.red);
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
        title: const Text('2 - Controle de medição'),
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
                                icon: const Icon(Icons.calendar_today)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.95,
                          height: MediaQuery.sizeOf(context).height * 0.065,
                          child: ElevatedButton(
                            onPressed: status == true && dateStatus == true
                                ? () {
                                    setState(() {
                                      var route = CustomPageRoute(
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
                            child: const Text("Apontar"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Text(medicaoPendente.isEmpty
                    ? ''
                    : 'Apontamentos aguardando envio'),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      medicaoPendente.isEmpty ? 0 : medicaoPendente.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        leading: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () {
                              eliminateQueue();
                            },
                            child: const Icon(Icons.delete)),
                        title: Text(
                            'Data: ${medicaoPendente[index]["data"]['h0_cp008']}'),
                        trailing: ElevatedButton(
                          onPressed: !sending
                              ? () async {
                                  setState(() {
                                    sending = true;
                                  });

                                  await effectiveValidator(
                                          offlineMeasurement:
                                              medicaoPendente[index])
                                      .then(
                                          (value) => makeRequestOffline(value))
                                      .onError((error, stackTrace) {
                                    setState(() {
                                      sending = false;
                                    });
                                    showSnackBar(
                                        'Erro inesperado, tente novamente, se o erro persistir contate o suporte',
                                        Colors.red);
                                    print(error);
                                    print(stackTrace);
                                  });
                                }
                              : null,
                          child: const Icon(Icons.arrow_circle_up),
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
                              var route = CustomPageRoute(
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
                      const Divider(),
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

  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Text(message),
    ));
  }
}
