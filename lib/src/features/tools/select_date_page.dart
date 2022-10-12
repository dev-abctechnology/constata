import 'dart:convert';

import 'package:constata/src/features/tools/tools_details_page.dart';
import 'package:constata/src/features/tools/tools_process_page.dart';
import 'package:constata/src/models/token.dart';
import 'package:constata/src/shared/load_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SelectDatePage extends StatefulWidget {
  var dataLogged;

  SelectDatePage({Key key, this.dataLogged}) : super(key: key);

  @override
  _SelectDatePagState createState() => _SelectDatePagState();
}

class _SelectDatePagState extends State<SelectDatePage> {
  String _selectedDate = "Data do apontamento";
  String _date = null;
  bool status = false;
  bool rstatus = false;
  List medicaoPendente = [];
  bool sending = false;
  bool k = false;
  bool dateStatus = false;
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
        var _dateFetch = DateFormat('dd/MM/yyyy', "pt_BR").format(d);
        _date = DateFormat('yyyy-MM-ddTHH:mm:ss', "pt_BR").format(d);
        var _date2 = DateFormat('yyyy-MM-ddTHH:mm:ss', "pt_BR").format(d);
        fetchRelatorios(_dateFetch);
        SharedPreferences.getInstance().then((value) {
          if (!value.containsKey('filaFerramentas')) {
            status = true;
          } else {
            status = false;
          }
        });
      });
    }
  }

  void updateFila() {
    SharedPreferences.getInstance().then((value) {
      if (value.containsKey('filaFerramentas')) {
        setState(() {
          status = false;
        });
        medicaoPendente = [jsonDecode(value.getString('filaFerramentas'))];
        setState(() {});
      }
    });
  }

  //{timestamp: 2021-11-12T13:33:31.491+0000, status: 500, error: Internal Server Error, message: No value present, path: /jarvis/api/stuffdata/sdt_a-inm-prjre-00}

  @override
  void initState() {
    super.initState();
    updateFila();
  }

  String transformDate(date) {
    List<String> datas = date.split('T')[0].split('-');
    return datas[2] + "/" + datas[1] + "/" + datas[0];
  }

  Future fetchRelatorios(date) async {
    print(date);
    print('fetchrelatorio');
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    if (date == null) {
      date = transformDate(_date);
    }
    print(date);
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-lim-movld-00/filter'));
    request.body =
        '''{"filters":[{"fieldName":"data.h0_cp016","value":"$date","expression":"EQUAL"},{"fieldName": "data.h0_cp010.name","value": "${widget.dataLogged['obra']['data']['tb01_cp002']}","expression": "EQUAL"}],"sort":{"fieldName":"data.h0_cp008","type":"ASC"}}''';
    request.headers.addAll(headers);

    try {
      showLoading(context);
      http.StreamedResponse response = await request.send();
      print(response.statusCode);
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        print('hahahaha');
        res = jsonDecode(await response.stream.bytesToString());
        setState(() {
          res;

          return true;
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

  void eliminateQueue() {
    SharedPreferences.getInstance().then((value) {
      value.remove('filaFerramentas');
      setState(() {
        medicaoPendente.clear();
      });
    });
  }

  void makeRequestOffline(body) async {
    http.Request request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-lim-movld-00'));
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };

    request.body = jsonEncode(body);
    request.headers.addAll(headers);
    if (await fetchRelatorios(body["data"]["h0_cp016"])) {
      setState(() {
        _selectedDate = body["data"]["h0_cp016"];
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('4 - Controle de Ferramentas'),
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
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: MediaQuery.of(context).size.height * 0.065,
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
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.95,
                          height: MediaQuery.of(context).size.height * 0.065,
                          child: ElevatedButton(
                            onPressed: status == true && dateStatus == true
                                ? () {
                                    setState(() {
                                      var route = MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ToolsProcessPage(
                                          dataLogged: widget.dataLogged,
                                          date: transformDate(_date),
                                        ),
                                      );
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
                  physics: NeverScrollableScrollPhysics(),
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
                            '${medicaoPendente[index]['data']['h0_cp016']}'),
                        subtitle: Text(
                            '${medicaoPendente[index]['data']['tb01_cp106'][0]['tp_cp108']['name']}'),
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
              Center(
                child: Text(
                    "${res.isEmpty ? '' : 'Apontamentos do dia $_selectedDate'}"),
              ),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: res.isEmpty ? 0 : res.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            var route = MaterialPageRoute(
                              builder: (BuildContext context) => ToolsDetails(
                                tool: res[index],
                              ),
                            );
                            Navigator.of(context).push(route);
                          });
                        },
                        child: ListTile(
                          title: Text('${res[index]['data']['h0_cp016']}'),
                          subtitle: Text(
                              '${res[index]['data']['tb01_cp106'][0]['tp_cp108']['name']}'),
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
