import 'dart:convert';

import 'dart:developer' as developer;
import 'package:constata_0_0_2/src/models/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'epi_report_task_page.dart';

class EpiProcess extends StatefulWidget {
  Map dataLogged;

  final String selectedDate;
  EpiProcess({Key key, this.dataLogged, this.selectedDate}) : super(key: key);

  @override
  _EpiProcessState createState() => _EpiProcessState();
}

class _EpiProcessState extends State<EpiProcess> {
  var result = [];

  var res = [];
  Map selectedEPI = {};
  List epiReport = [];
  List body = [];
  List effectiveList = [];
  Map _selectedColaborator;
  String _selectedDate;
  String _date;
  int opened = 0;
  bool pending = false;
  bool sending = false;
  List filaDeApontamento = [];

  // Future<void> _openDatePicker(BuildContext context) async {
  //   setState(() {
  //     res = [];
  //   });

  //   final DateTime d = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime.now().subtract(
  //       Duration(days: 2000000),
  //     ),
  //     lastDate: DateTime.now().add(
  //       Duration(days: 2000000),
  //     ),
  //   );
  //   if (d != null) {
  //     setState(() {
  //       _selectedDate = DateFormat(" d 'de' MMMM 'de' y", "pt_BR").format(d);
  //       _date = DateFormat('dd/MM/yyyy', "pt_BR").format(d);
  //       // _date = DateFormat('yyyy-MM-ddTHH:mm:ss', "pt_BR").format(d);
  //       var _date2 = DateFormat('yyyy-MM-ddTHH:mm:ss', "pt_BR").format(d);
  //       print('jarvis: 2021-11-12T00:00:00');
  //       print('timePicker: $d');
  //       print('converted: $_date2');
  //       //2021-11-12T00:00:00
  //     });
  //   }
  // }

  Future fetchColaboradores() async {
    setState(() {});
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
        }
      ]
    });
    request.headers.addAll(headers);

    developer.log(request.body, name: "BODY");

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        effectiveList = jsonDecode(await response.stream.bytesToString());
        print(effectiveList.length);
        setState(() {});
        return true;
      } else {
        print(response.reasonPhrase);
        return false;
      }
    } catch (e, s) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDate;
    fetchColaboradores().then((value) {
      if (value == false) {
        mountEffective();
      }
    });

    print(widget.dataLogged['obra']);
  }

  apagarApontamentoPendente(indice) async {
    SharedPreferences filaEpi = await SharedPreferences.getInstance();
    if (filaEpi.containsKey("filaApontamentoEPI")) {
      var temp =
          jsonDecode(filaEpi.getStringList("filaApontamentoEPI").toString());

      print(temp);
    }

    // setState(() {
    //   SharedPreferences.getInstance().then((value) async {
    //     value.remove("filaApontamentoEPI");
    //     filaDeApontamento = [];
    //     pending = false;
    //   });
    // });
  }

  Future<void> mountEffective() async {
    SharedPreferences preferenciasCompartilhadas =
        await SharedPreferences.getInstance();
    if (preferenciasCompartilhadas.containsKey('colaboradores')) {
      developer.log('Colaboradores na memoria');
      effectiveList =
          jsonDecode(preferenciasCompartilhadas.getString("colaboradores"));
      print(jsonDecode(preferenciasCompartilhadas.getString("colaboradores")));
      setState(() {
        _isOffline = true;
      });
    }
  }

  bool _isOffline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isOffline
          ? AppBar(
              backgroundColor: Colors.red,
              title: Text('EPIs - ${widget.selectedDate}\nVocê está offline'),
              centerTitle: true,
            )
          : AppBar(
              title: Text('EPIs - ${widget.selectedDate}'),
              centerTitle: true,
            ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const Text("Escolha o colaborador"),
              effectiveList.isEmpty
                  ? CircularProgressIndicator()
                  : effectiveListing(),
            ],
          ),
        ),
      ),
    );
  }

  GridView effectiveListing() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 1.85),
      shrinkWrap: true,
      itemCount: effectiveList.isEmpty ? 0 : effectiveList.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: InkWell(
            onTap: () async {
              setState(() {
                _selectedColaborator = effectiveList[index];
              });

              //there is await inside, so add async tag

              if (widget.dataLogged.isNotEmpty &&
                  _selectedColaborator.isNotEmpty) {
                try {
                  var result = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return EpiReportTask(
                      dataLogged: widget.dataLogged,
                      date: _date,
                      userSelected: _selectedColaborator,
                    );
                  }));
                  try {
                    developer.log(result.toString(), name: "Retorno da pagina");
                  } catch (error, s) {
                    print(error);
                  }
                } catch (e, s) {
                  developer.log("error", error: e, stackTrace: s);
                }
              } else {
                developer.log('Alguma variavel está vazia');
              }
            },
            child: ListTile(
              title: Center(
                  child: Text(
                '${effectiveList[index]['data']['tb01_cp002']}',
                textAlign: TextAlign.center,
                maxLines: 3,
              )),
            ),
          ),
        );
      },
    );
  }
}
