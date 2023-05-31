import 'dart:convert';

import 'dart:developer' as developer;
import 'package:constata/src/models/token.dart';
import 'package:constata/src/shared/load_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'epi_appointment_details_page.dart';
import 'epi_process.dart';

class EpiHome extends StatefulWidget {
  var dataLogged;

  EpiHome({Key? key, required this.dataLogged}) : super(key: key);

  @override
  _EpiHomeState createState() => _EpiHomeState();
}

class _EpiHomeState extends State<EpiHome> {
  var res = [];
  String _selectedDate = "Escolha a data";
  String _date = "";
  int opened = 0;
  bool pending = false;
  bool sending = false;
  bool dateStatus = false;

  Future<void> _openDatePicker(BuildContext context) async {
    setState(() {
      res = [];
    });
    bool k = false;

    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(
        Duration(days: 120),
      ),
      lastDate: DateTime.now().add(
        Duration(days: 0),
      ),
    );
    if (d != null) {
      setState(() {
        k = DateTime.now().isAfter(d.add(Duration(days: 3)));
        if (k == true) {
          print('k true');
          dateStatus = false;
        }
        if (k == false) {
          print('k false');
          dateStatus = true;
        }

        _selectedDate = DateFormat(" d 'de' MMMM 'de' y", "pt_BR").format(d);
        _date = DateFormat('dd/MM/yyyy', "pt_BR").format(d);
        // _date = DateFormat('yyyy-MM-ddTHH:mm:ss', "pt_BR").format(d);
        var _date2 = DateFormat('yyyy-MM-ddTHH:mm:ss', "pt_BR").format(d);
        print('jarvis: 2021-11-12T00:00:00');
        print('timePicker: $d');
        print('converted: $_date2');
        if (pending == false && k == false) {
          status = true;
        }
        //2021-11-12T00:00:00
      });
    }
  }

  List resAppointment = [];
  bool status = true;

  Future sendEpiReport(epiIndex, intIndex) async {
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-ehm-ppeas-00'));
    request.body = jsonEncode(epiIndex);
    request.headers.addAll(headers);
    print(request.body);
    print('');
    developer.log(request.body, name: "Corpo da req");
    developer.log(intIndex.toString(), name: "Index list");
    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 201) {
        print('enviado');
        print(await response.stream.bytesToString());

        return true;
      } else {}
    } catch (e) {
      print('catch');
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
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-ehm-ppeas-00/filter'));
    request.body = json.encode({
      "filters": [
        {"fieldName": "data.h0_cp054", "value": "$date", "expression": "EQUAL"},
        {
          "fieldName": "data.h0_cp010.name",
          "value": "${widget.dataLogged['obra']['data']['tb01_cp002']}",
          "expression": "EQUAL"
        },
      ],
      "sort": {"fieldName": "data.h0_cp013", "type": "ASC"}
    });
    request.headers.addAll(headers);
    showLoading(context);
    try {
      http.StreamedResponse response = await request.send();
      Navigator.of(context).pop();
      print(response.statusCode);
      if (response.statusCode == 200) {
        resAppointment = jsonDecode(await response.stream.bytesToString());
        setState(() {});
        if (resAppointment.length > 0) {
          status = false;

          setState(() {});

          return {'log': 'true'};
        }
        print("Apontamentos nesse dia: ${resAppointment.length}");

        return {'log': 'false'};
      } else {
        print(response.statusCode.toString());
        return {'log': 'error'};
      }
    } catch (e) {
      Navigator.of(context).pop();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Não foi possível verificar se há apontamentos.'),
              content: Text(
                "Verifique sua conexão e tente novamente!\n\nAtenção!\nPode ocorrer inconsistências.",
                textAlign: TextAlign.center,
              ),
            );
          });
    }
  }

  apagarApontamentoPendente(indice) {
    developer.log(indice.toString(), name: "Indice apagar:");
    setState(() {
      SharedPreferences.getInstance().then((value) async {
        List<String> fila = value.getStringList('filaApontamentoEPI')!;
        print(fila.length);
        if (fila.length > 1) {
          fila.removeAt(indice);
        } else {
          print(filaDeApontamento);
          fila.clear();
        }
        List x = jsonDecode(fila.toString());
        filaDeApontamento = x.toSet().toList();
        value.setStringList('filaApontamentoEPI', fila);
        if (filaDeApontamento.length == 0) {
          pending = false;
          value.remove('filaApontamentoEPI');
        }
      });
    });
  }

  List filaDeApontamento = [];

  List result = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    buildFila();
  }

  void buildFila() async {
    late SharedPreferences sharedPreferences;
    await SharedPreferences.getInstance()
        .then((value) => sharedPreferences = value);
    if (sharedPreferences.containsKey("filaApontamentoEPI")) {
      // pending = true;
      // status = false;
      setState(() {});
      filaDeApontamento = jsonDecode(
          sharedPreferences.getStringList("filaApontamentoEPI").toString());
      print("ADFDSAFDSF" +
          sharedPreferences.getStringList('filaApontamentoEPI').toString());
      developer.log(filaDeApontamento.length.toString());
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('3 - Controle de EPI'),
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
                              hasAppointment(_date).then((value) => null);
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
                                      hasAppointment(_date)
                                          .then((value) => null);
                                    }
                                  });
                                },
                                icon: Icon(Icons.calendar_today)),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.95,
                          height: MediaQuery.of(context).size.height * 0.065,
                          child: ElevatedButton(
                            onPressed: dateStatus
                                ? () {
                                    setState(() {
                                      var route = MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            EpiProcess(
                                          dataLogged: widget.dataLogged,
                                          selectedDate: _date,
                                        ),
                                      );
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
              filaDeApontamento.isEmpty
                  ? Text('')
                  : Center(
                      child: Column(children: [
                      Divider(),
                      Text('Apontamento de EPI pendente')
                    ])),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount:
                      filaDeApontamento.isEmpty ? 0 : filaDeApontamento.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        leading: ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: Colors.red),
                            onPressed: () {
                              apagarApontamentoPendente(index);
                            },
                            child: Icon(Icons.delete)),
                        title: Text(
                            'Data: ${filaDeApontamento[index]['data']['h0_cp054']}\n'
                            'Nome: ${filaDeApontamento[index]['data']['h0_cp013']}'),
                        trailing: ElevatedButton(
                          onPressed: sending
                              ? null
                              : () {
                                  setState(() {
                                    sending = true;
                                  });
                                  sendEpiReport(filaDeApontamento[index], index)
                                      .then((value) {
                                    if (value == true) {
                                      apagarApontamentoPendente(index);
                                    }
                                    setState(() {
                                      sending = false;
                                    });
                                  });
                                  // hasAppointmentQueue(filaDeApontamento[index]['data']['h0_cp008']).then((value) => switchAppointment(value), );
                                },
                          child: Icon(Icons.arrow_circle_up),
                        ),
                      ),
                    );
                  }),
              ListTile(
                title: resAppointment.isEmpty
                    ? null
                    : Center(
                        child: Column(
                        children: [
                          Divider(),
                          Text('$_selectedDate'),
                        ],
                      )),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: resAppointment.isEmpty ? 0 : resAppointment.length,
                itemBuilder: (BuildContext context, int index) {
                  List epiList = resAppointment[index]['data']['tb03_cp011'];
                  var validated =
                      resAppointment[index]['data']['h0_cp056'] == null
                          ? 'Não'
                          : resAppointment[index]['data']['h0_cp056'];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        var route = MaterialPageRoute(
                          builder: (BuildContext context) =>
                              EpiAppointmentDetails(
                            epiAppointment: resAppointment[index],
                          ),
                        );
                        Navigator.of(context).push(route);
                      });
                    },
                    child: Card(
                      child: ListTile(
                        title: Text('Nome: ' +
                            resAppointment[index]['data']['h0_cp013']
                                .toString()),
                        subtitle: Text('EPIs: ' + epiList.length.toString()),
                        trailing: Text('Validado: ' + validated),
                      ),
                    ),
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
