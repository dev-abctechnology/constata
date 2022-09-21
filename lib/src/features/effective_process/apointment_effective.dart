import 'dart:convert';
import 'dart:developer' as developer;
import 'package:constata_0_0_2/src/models/token.dart';
import 'package:constata_0_0_2/src/shared/load_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class ApointmentEffective extends StatefulWidget {
  var date;

  var dataLogged;

  ApointmentEffective({Key key, this.dataLogged, this.date}) : super(key: key);

  @override
  _ApointmentEffectiveState createState() => _ApointmentEffectiveState();
}

class _ApointmentEffectiveState extends State<ApointmentEffective> {
  // var descriptionController = TextEditingController();
  var cafeManhaController = TextEditingController();
  var cafeTardeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List effectiveList = [];
  bool _flag = true;
  var bodyResponse;
  List viewList = [];
  List<bool> _isChecked;
  List<String> _isCheckedString;
  List<String> val;
  List<int> valInt = [];
  List<Color> colorCollab;

  Future sendApointment() async {
    setState(() {
      _flag = true;
    });
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://abctech.ddns.net:4230/jarvis/api/stuffdata/sdt_a-inm-prjre-00'));
    request.body =
        '''{"data": {"h0_cp002": "EFET","h0_cp003": "","h0_cp004": "Descrição do apontamento","h0_cp008": "${widget.date}","h0_cp005": {"name": "${widget.dataLogged['empresa']['name']}","_id": "${widget.dataLogged['empresa']['id']}"},"h0_cp013": {"name": "${widget.dataLogged['obra']['data']['tb01_cp002']}","_id": "${widget.dataLogged['obra']['id']}"},"h0_cp006": "${widget.dataLogged['local_negocio']['name']}","h0_cp015": "${widget.dataLogged['obra']['data']['tb01_cp026']['name']}","h0_cp009": "${widget.dataLogged['user']['name']}","h0_cp010": "${cafeManhaController.text}","h0_cp011": "${cafeTardeController.text}","f0_cp002": "Não","tb01_cp011": ${jsonEncode(viewList)}},"ckc": "CONPROD001","cko": "000000000000000000"}''';
    request.headers.addAll(headers);
    print('body: ${request.body}\n\n');
    try {
      showLoading(context);
      http.StreamedResponse response = await request.send();
      // print('body: ${request.body}\n\n');

      // print(await response.stream.bytesToString());
      print(response.statusCode);

      if (response.statusCode == 201) {
        setState(() {
          _flag = true;
        });
        print(await response.stream.bytesToString());
        print('enviou');
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("Apontamento enviado com sucesso!"),
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
        Navigator.of(context).pop();
        SharedPreferences.getInstance()
            .then((value) => value.setString("filaApontamento", request.body));
        return false;
      }
    } catch (e) {
      setState(
        () {
          _flag = false;
          SharedPreferences.getInstance().then(
              (value) => value.setString("filaApontamento", request.body));

          // var nav = Navigator.of(context);
          // nav.pop();
          // nav.pop();
        },
      );
      return false;
    }
  }

  Future alerta(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
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
                nav.pop();
                nav.pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future fetchColaboradores() async {
    try {
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

      http.StreamedResponse response = await request.send();
      print('heeeeeeeehee');
      if (response.statusCode == 200) {
        effectiveList = jsonDecode(await response.stream.bytesToString());

        print(effectiveList.length);
        return true;
      } else {
        print(response.reasonPhrase);
        print('a');
        return false;
      }
    } catch (e, s) {
      print('erro');
    }
  }

  criarListaDeEfetivosParaSelect([List<String> fixo, List<String> ausente]) {
    viewList = [];
    if (fixo == null) fixo = List<String>.filled(effectiveList.length, "");
    if (ausente == null)
      ausente = List<String>.filled(effectiveList.length, "Ausente");
    for (var i = 0; i < effectiveList.length; i++) {
      try {
        var genUuid = Uuid();
        setState(() {
          viewList.add({
            "tp_cp012": "${effectiveList[i]['data']['tb01_cp004']}", // codigo
            "tp_cp013": "${effectiveList[i]['data']['tb01_cp002']}", // nome
            "tp_cp014": "${fixo[i]}", //fixo ou rotativo
            "tp_cp015": "${ausente[i]}", //presente ausente transferencia
            "_id": "${genUuid.v4()}"
          });
        });
      } catch (e) {
        print(e);
      }

      print(jsonEncode(viewList));
    }
  }

  void mountArrays() {
    criarListaDeEfetivosParaSelect();

    _isChecked = List<bool>.filled(viewList.length, false);
    _isCheckedString = List<String>.filled(viewList.length, "Fixo");
    val = List<String>.filled(viewList.length, "");
    valInt = List<int>.filled(viewList.length, 0);
    colorCollab = List.filled(viewList.length, Colors.red);
    print(colorCollab);
  }

  void initializer() {
    print('comecou');
    fetchColaboradores().then(
      (value) async {
        if (value == true) {
          print('a');
          mountArrays();
        } else if (value == false) {
          print('erro');
        } else {
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          if (sharedPreferences.containsKey("colaboradores")) {
            effectiveList =
                jsonDecode(sharedPreferences.getString("colaboradores"));
            mountArrays();
          }
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initializer();
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Efetivo - ${widget.date}"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Informe a quantidade de cafés da manhã';
                                  }
                                  return null;
                                },
                                controller: cafeManhaController,
                                decoration: InputDecoration(
                                    icon: Icon(Icons.wb_twilight),
                                    labelText: 'cafés da manhã'),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Informe a quantidade de cafés da tarde';
                                  }
                                  return null;
                                },
                                controller: cafeTardeController,
                                decoration: InputDecoration(
                                    icon: Icon(Icons.wb_sunny),
                                    labelText: 'cafés da tarde'),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
              ListView.builder(
                shrinkWrap: true,
                itemCount: viewList.isEmpty ? 0 : viewList.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  var color = Colors.transparent;
                  print(index);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Card(
                      borderOnForeground: false,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 600),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            right:
                                BorderSide(color: colorCollab[index], width: 2),
                            left:
                                BorderSide(color: colorCollab[index], width: 2),
                            bottom:
                                BorderSide(color: colorCollab[index], width: 2),
                            top:
                                BorderSide(color: colorCollab[index], width: 2),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nome: ${viewList[index]['tp_cp013']}'),
                                  Text('ID: ${viewList[index]['tp_cp012']}'),
                                  Divider()
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  colorCollab[index] = Colors.transparent;
                                  valInt[index] = 1;
                                  val[index] = "Presente";
                                });
                                print(val);
                              },
                              child: SizedBox(
                                height: 40,
                                child: Row(
                                  children: [
                                    Container(
                                      height: 20,
                                      child: Radio(
                                        activeColor: Colors.blue,
                                        value: 1,
                                        groupValue: valInt[index],
                                        onChanged: (value) {
                                          setState(() {
                                            colorCollab[index] =
                                                Colors.transparent;
                                            valInt[index] = value;
                                            val[index] = "Presente";
                                          });
                                          print(val);
                                        },
                                      ),
                                    ),
                                    Text('Presente'),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  colorCollab[index] = Colors.transparent;
                                  valInt[index] = 2;
                                  val[index] = "Ausente";
                                });
                                print(val);
                              },
                              child: SizedBox(
                                height: 40,
                                child: Row(
                                  children: [
                                    Container(
                                      height: 20,
                                      child: Radio(
                                        activeColor: Colors.blue,
                                        value: 2,
                                        groupValue: valInt[index],
                                        onChanged: (value) {
                                          setState(() {
                                            colorCollab[index] =
                                                Colors.transparent;
                                            valInt[index] = value;
                                            val[index] = "Ausente";
                                          });
                                          print(val);
                                        },
                                      ),
                                    ),
                                    Text('Ausente'),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  colorCollab[index] = Colors.transparent;
                                  valInt[index] = 3;
                                  val[index] = "Em transferência";
                                });
                                print(val);
                              },
                              child: SizedBox(
                                height: 40,
                                child: Row(
                                  children: [
                                    Container(
                                      height: 20,
                                      child: Radio(
                                        activeColor: Colors.blue,
                                        value: 3,
                                        groupValue: valInt[index],
                                        onChanged: (value) {
                                          setState(() {
                                            colorCollab[index] =
                                                Colors.transparent;
                                            valInt[index] = value;
                                            val[index] = "Em transferência";
                                          });
                                          print(val);
                                        },
                                      ),
                                    ),
                                    Text('Em transferência'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Container(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       if (_formKey.currentState.validate()) {
              //         developer.log(cafeManhaController.text, name: "MANHÃ");
              //         developer.log(cafeTardeController.text, name: "TARDE");
              //         if (viewList.isNotEmpty) {
              //           if (val.contains('')) {
              //             showDialog(
              //                 context: context,
              //                 builder: (BuildContext context) {
              //                   List pendingFields = [];
              //                   for (var i = 0; i < val.length; i++) {
              //                     if (val[i] == "") {
              //                       pendingFields.add(viewList[i]);
              //                     }
              //                   }

              //                   return AlertDialog(
              //                       content: Text(
              //                           'Preencha todos os colaboradores.\nColaboradores restantes: ${pendingFields.length}'));
              //                 });
              //           } else {
              //             criarListaDeEfetivosParaSelect(_isCheckedString, val);
              //             sendApointment().then((value) {
              //               if (value == false) {
              //                 alerta(context);
              //               }
              //             });
              //           }
              //         } else {
              //           print('lista vazia');
              //         }
              //       } else {
              //         print('error');
              //       }
              //     },
              //     child: Text('Enviar'),
              //   ),
              // ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: valInt != []
                ? valInt.every((element) => element != 0)
                    ? null
                    : Color.fromARGB(255, 231, 80, 80)
                : null,
            onPressed: () {
              if (_formKey.currentState.validate()) {
                developer.log(cafeManhaController.text, name: "MANHÃ");
                developer.log(cafeTardeController.text, name: "TARDE");
                if (viewList.isNotEmpty) {
                  if (val.contains('')) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          List pendingFields = [];
                          for (var i = 0; i < val.length; i++) {
                            if (val[i] == "") {
                              pendingFields.add(viewList[i]);
                            }
                          }

                          return AlertDialog(
                              content: Text(
                                  'Preencha todos os colaboradores.\nColaboradores restantes: ${pendingFields.length}'));
                        });
                  } else {
                    criarListaDeEfetivosParaSelect(_isCheckedString, val);
                    sendApointment().then((value) {
                      if (value == false) {
                        alerta(context);
                      }
                    });
                  }
                } else {
                  print('lista vazia');
                }
              } else {
                print('error');
              }
            },
            label: Text(valInt.every((element) => element != 0)
                ? "Pronto para enviar"
                : "Preencha todos")));
  }
}
