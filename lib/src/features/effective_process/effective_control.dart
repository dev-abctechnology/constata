import 'dart:convert';

import 'package:constata/src/features/effective_process/apointment_effective_reworked.dart';
import 'package:constata/src/features/effective_process/data/appointment_data.dart';
import 'package:constata/src/models/token.dart';
import 'package:constata/src/shared/load_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import 'report_details.dart';

class EffectiveControl extends StatefulWidget {
  Map dataLogged;

  EffectiveControl({Key? key, required this.dataLogged}) : super(key: key);

  @override
  _EffectiveControlState createState() => _EffectiveControlState();
}

class _EffectiveControlState extends State<EffectiveControl> {
  String _selectedDate = "Data do apontamento";
  String _date = "";
  int opened = 0;
  List res = [];
  List resAppointment = [];
  bool status = true;
  bool dateStatus = false;
  List filaDeApontamento = [];
  bool pending = false;
  bool sending = false;
  //{timestamp: 2021-11-12T13:33:31.491+0000, status: 500, error: Internal Server Error, message: No value present, path: /jarvis/api/stuffdata/sdt_a-inm-prjre-00}

  void buildFila() async {
    late SharedPreferences sharedPreferences;
    await SharedPreferences.getInstance()
        .then((value) => sharedPreferences = value);
    if (sharedPreferences.containsKey("filaApontamento")) {
      pending = true;
      status = false;
      setState(() {});
      filaDeApontamento.add(
        await json.decode(
          sharedPreferences.getString("filaApontamento")!,
        ),
      );
      setState(() {});
      print(filaDeApontamento);
    }
    rascunho();
  }

  void rascunho() {
    if (Provider.of<AppointmentData>(context, listen: false).hasData.value ==
        true) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Um rascunho foi encontrado!'),
              content: const Text('Deseja continuar o lançamento?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Não')),
                TextButton(
                    onPressed: () {
                      var route = MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ApointmentEffectiveReworked(
                          editingMode: true,
                          dataLogged: widget.dataLogged,
                          date: Provider.of<AppointmentData>(context,
                                  listen: false)
                              .appointmentData
                              .data
                              .datetime,
                        ),
                      );
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).push(route);
                    },
                    child: const Text('Sim')),
              ],
            );
          });
    }
  }

  bool k = false;
  Future<void> _openDatePicker(BuildContext context) async {
    setState(() {
      res = [];
    });

    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 10000),
      ),
      lastDate: DateTime.now().add(
        const Duration(days: 0),
      ),
    );
    if (d != null) {
      setState(() {
        k = DateTime.now().isAfter(d.add(const Duration(days: 3)));
        if (k == true) {
          status = false;
        }
        _selectedDate = DateFormat(" d 'de' MMMM 'de' y", "pt_BR").format(d);
        _date = DateFormat('dd/MM/yyyy', "pt_BR").format(d);
        // _date = DateFormat('yyyy-MM-ddTHH:mm:ss', "pt_BR").format(d);
        var _date2 = DateFormat('yyyy-MM-ddTHH:mm:ss', "pt_BR").format(d);
        print('jarvis: 2021-11-12T00:00:00');
        print('timePicker: $d');
        print('converted: $_date2');
        dateStatus = true;
        if (pending != true && k == false) {
          status = true;
        }
        //2021-11-12T00:00:00
      });
    }
  }

  Future fetchRelatorios(date) async {
    setState(() {});

    developer.log(Provider.of<Token>(context, listen: false).token,
        name: 'token');

    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-inm-prjre-00/filter'));
    request.body =
        '''{"filters":[{"fieldName":"data.h0_cp008","value":"$_date","expression":"EQUAL"},{"fieldName": "data.h0_cp013.name","value": "${widget.dataLogged['obra']['data']['tb01_cp002']}","expression": "EQUAL"}],"sort":{"fieldName":"data.h0_cp008","type":"ASC"}}''';
    request.headers.addAll(headers);
    showLoading(context);

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        res = jsonDecode(await response.stream.bytesToString());
        setState(() {});

        Navigator.of(context).pop();
        print(res.length);
      } else {
        print('efetivo error: ' +
            jsonDecode(await response.stream.bytesToString()));
        Navigator.of(context).pop();
      }
    } on Exception catch (e, s) {
      print(e);
      print(s);
      Navigator.of(context).pop();
    }
  }

  Future hasAppointment(date) async {
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-inm-prjre-00/filter'));
    request.body =
        '''{"filters":[{"fieldName":"data.h0_cp008","value":"$date","expression":"EQUAL"},{"fieldName":"data.h0_cp013.name","value":"${widget.dataLogged['obra']['data']['tb01_cp002']}","expression":"EQUAL"}],"sort":{"fieldName":"data.h0_cp008","type":"ASC"}}''';
    request.headers.addAll(headers);
    showLoading(context);
    try {
      http.StreamedResponse response = await request.send();
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        resAppointment = jsonDecode(await response.stream.bytesToString());
        if (resAppointment.isNotEmpty) {
          status = false;
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return const AlertDialog(
                  title: Text('Escolha outra data!'),
                  content: Text(
                      "Na data selecionada já existe um apontamento de efetivo."),
                );
              });
          setState(() {});

          return {'log': 'true'};
        }
        print("Apontamentos nesse dia: ${resAppointment.length}");

        return {'log': 'false'};
      } else {
        print("has appointment error: " +
            response.statusCode.toString() +
            " " +
            jsonDecode(await response.stream.bytesToString()));
        return {'log': 'error'};
      }
    } catch (e) {
      Navigator.of(context).pop();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Não foi possível verificar se há apontamentos.'),
              content: Text(
                "Verifique sua conexão e tente novamente!\n\nAtenção!\nPode ocorrer inconsistências.",
                textAlign: TextAlign.center,
              ),
            );
          });
    }
  }

  Future hasAppointmentQueue(date) async {
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-inm-prjre-00/filter'));
    request.body =
        '''{"filters":[{"fieldName":"data.h0_cp008","value":"$date","expression":"EQUAL"},{"fieldName":"data.h0_cp013.name","value":"${widget.dataLogged['obra']['data']['tb01_cp002']}","expression":"EQUAL"}],"sort":{"fieldName":"data.h0_cp008","type":"ASC"}}''';
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        resAppointment = jsonDecode(await response.stream.bytesToString());
        if (resAppointment.isNotEmpty) {
          status = false;
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Erro ao enviar.'),
                  content: Text(
                      "Na data ${filaDeApontamento[0]['data']['h0_cp008']} já existe um apontamento de efetivo para a obra \"${widget.dataLogged['obra']['data']['tb01_cp002']}\"."),
                );
              });
          setState(() {});
          return {'log': 'true'};
        }
        print("Apontamentos nesse dia: ${resAppointment.length}");

        return {'log': 'false'};
      } else {
        print('hasAppointmentQueue: ' + (response.statusCode.toString()));
        return {'log': 'error'};
      }
    } catch (e, s) {
      print(e);
      print(s);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Não foi possível enviar o apontamento'),
              content: Text(
                "Verifique sua conexão ou se já existe um apontamento para a obra \"${widget.dataLogged['obra']['data']['tb01_cp002']}\" na data: ${filaDeApontamento[0]['data']['h0_cp008']}",
                textAlign: TextAlign.center,
              ),
            );
          });
    }
  }

  Future sendApointment() async {
    setState(() {});
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-inm-prjre-00'));
    request.body = jsonEncode(filaDeApontamento[0]);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      // print('body: ${request.body}\n\n');

      // print(await response.stream.bytesToString());
      print(response.statusCode);

      if (response.statusCode == 201) {
        setState(() {
          SharedPreferences.getInstance().then((value) async {
            value.remove("filaApontamento");
            filaDeApontamento = [];
            status = true;
          });
        });
      } else {}
    } catch (e) {}
  }

  apagarApontamentoPendente(indice) {
    setState(() {
      SharedPreferences.getInstance().then((value) async {
        value.remove("filaApontamento");
        filaDeApontamento = [];
        pending = false;
      });
    });
  }

  Future switchAppointment(value) async {
    print('entrou na func');

    print(value);
    String command = value.toString();
    print(command);
    {
      switch (command) {
        case "{log: true}":
          print('ja tem');
          break;
        case '{log: false}':
          print('send');
          sendApointment().then((value) {
            setState(() {
              sending = false;
              print('a');
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      content: Text("Apontamento enviado com sucesso!"),
                    );
                  });
            });
          });
          break;
        case '{log: error}':
          print('error');
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return const AlertDialog(
                  content: Text(
                      "Ocorreu um erro inesperado. Tente novamente mais tarde"),
                );
              });
          break;
        default:
          print('caiu no default');
      }

      setState(() {
        sending = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    status = false;
    dateStatus = false;
    buildFila();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1 - Controle de efetivo'),
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
                          _openDatePicker(context).then((value) {
                            if (_date.isNotEmpty) {
                              hasAppointment(_date)
                                  .then((value) => fetchRelatorios(null));
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_selectedDate),
                            IconButton(
                                onPressed: () {
                                  _openDatePicker(context).then((value) {
                                    if (_date.isNotEmpty) {
                                      hasAppointment(_date).then(
                                          (value) => fetchRelatorios(null));
                                    }
                                  });
                                },
                                icon: const Icon(Icons.calendar_today)),
                          ],
                        ),
                      ),
                    ),
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.95,
                        height: MediaQuery.sizeOf(context).height * 0.065,
                        child: ElevatedButton(
                          onPressed: status
                              ? () {
                                  setState(() {
                                    var route = MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ApointmentEffectiveReworked(
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
                    )),
                  ],
                ),
              ),
              Center(
                child: Text(filaDeApontamento.isEmpty
                    ? ''
                    : 'Apontamentos aguardando envio'),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      filaDeApontamento.isEmpty ? 0 : filaDeApontamento.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        leading: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () {
                              apagarApontamentoPendente(index);
                            },
                            child: const Icon(Icons.delete)),
                        title: Text(
                            'Descrição: ${filaDeApontamento[index]['data']['h0_cp004']}\n'
                            'Data: ${filaDeApontamento[index]['data']['h0_cp008']}'),
                        trailing: ElevatedButton(
                          onPressed: sending
                              ? null
                              : () {
                                  setState(() {
                                    sending = true;
                                  });

                                  hasAppointmentQueue(filaDeApontamento[index]
                                          ['data']['h0_cp008'])
                                      .then(
                                    (value) => switchAppointment(value),
                                  );
                                },
                          child: const Icon(Icons.arrow_circle_up),
                        ),
                      ),
                    );
                  }),
              ListTile(
                title: res.isEmpty
                    ? null
                    : Center(child: Text('Apontamentos do dia$_selectedDate')),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: res.isEmpty ? 0 : res.length,
                itemBuilder: (BuildContext context, int index) {
                  List efetivo = res[index]['data']['tb01_cp011'];
                  return Column(
                    children: [
                      Card(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              var route = MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ReportDetails(
                                  reportDetail: res[index],
                                ),
                              );
                              Navigator.of(context).push(route);
                            });
                          },
                          child: ListTile(
                            title:
                                Text('data: ${res[index]['data']['h0_cp008']}'),
                            subtitle: Text(
                                'quantidade do efetivo: ${efetivo == null ? "0" : efetivo.length}'),
                          ),
                        ),
                      ),
                      const Divider()
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
