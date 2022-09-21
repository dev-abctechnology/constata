import 'dart:convert';
import 'package:constata_0_0_2/src/login_page.dart';
import 'package:constata_0_0_2/src/models/token.dart';
import 'package:constata_0_0_2/src/select_build_page.dart';
import 'package:constata_0_0_2/src/shared/auth_refresh_controller.dart';
import 'package:constata_0_0_2/src/shared/company_refresh_controller.dart';
import 'package:constata_0_0_2/src/shared/load_controller.dart';
import 'package:constata_0_0_2/src/shared/verifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/effective_process/effective_control.dart';
import 'features/epi_process/epi_home_page.dart';
import 'features/measurement/measurement_page.dart';
import 'features/tools/select_date_page.dart';

class HomePage extends StatefulWidget {
  Map dataLogged; // ---> OBJETO COM TODOS OS DADOS DAS TELAS ANTERIORES (usuário, token,empresa, filial, local de negocio e empresa)

  HomePage({Key key, this.dataLogged}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var tokenAccess;
  var tokenSerilizado;

  String loggedSince = '';

  Future fetchColaboradores() async {
    var headers = {
      'Authorization':
          'Bearer ${Provider.of<Token>(context, listen: false).token}',
      'Content-Type': 'application/json'
    };
    AuthRefreshController authRefreshController = AuthRefreshController();
    String x = await authRefreshController
        .checkAuth(Provider.of<Token>(context, listen: false).token);
    if (x.isNotEmpty) {
      Provider.of<Token>(context, listen: false).setToken(x);
    }
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

    if (response.statusCode == 200) {
      SharedPreferences.getInstance().then((value) async => value.setString(
          "colaboradores",
          jsonEncode(jsonDecode(await response.stream.bytesToString()))));
      print('gravou na memoria');
      return true;
    } else {
      print(response.reasonPhrase);
      return false;
    }
  }

  Future fetchEquipments() async {
    setState(() {});
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
        print('pegous os EPI na home page');
        SharedPreferences.getInstance().then((value) async => value.setString(
            "epi",
            jsonEncode(jsonDecode(await response.stream.bytesToString()))));
        print('gravou na memoria os EPI');
        return true;
      } else {
        print(response.reasonPhrase);
        return false;
      }
    } on Exception catch (e) {
      return false;
    }
  }

  void loginDate() async {
    SharedPreferences sharedPreferences;
    await SharedPreferences.getInstance()
        .then((value) => sharedPreferences = value);
    if (sharedPreferences != null &&
        sharedPreferences.containsKey("timeLogged")) {
      setState(() {
        loggedSince = sharedPreferences.getString("timeLogged");
      });
    }
  }

  CustomDrawer(BuildContext context) {
    buttonDrawer(labelText, icon, page) {
      return Card(
        child: ListTile(
          title: Text(labelText),
          trailing: Icon(icon),
          onTap: botao
              ? () {
                  setState(() {
                    var route = MaterialPageRoute(
                        builder: (BuildContext context) => page);
                    Navigator.of(context).push(route);
                  });
                }
              : () {},
        ),
      );
    }

    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Color(0xff000d1b), Color(0xff003c7a)],
              ),
            ),
            child: Column(
              children: <Widget>[
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(70.0)),
                  elevation: 20,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/images/constata.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'CONSTATA\nAPONTAMENTO DIGITAL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'RobotoMono',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Card(
          //   child: ListTile(
          //     title: const Text('Usuários'),
          //     trailing: const Icon(Icons.person),
          //     onTap: botao
          //         ? () {
          //             Navigator.pushNamed(context, '/secondPage');
          //           }
          //         : () {},
          //   ),
          // ),
          // buttonDrawer('Configurações Globais', Icons.circle, GlobalConfig()),
          // buttonDrawer('Organização', Icons.business_center, Organization()),
          // buttonDrawer('Parceiros de Negócio', Icons.flag, BussinessPartners()),
          // buttonDrawer('Cadastros das Coisas', Icons.person_add, MasterData()),
          Card(
            child: ListTile(
              title: const Text('Sobre'),
              trailing: const Icon(Icons.notes),
              onTap: () {
                Navigator.pushNamed(context, '/about');
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Sair'),
              trailing: const Icon(Icons.lock_open),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Desconectar'),
                        content: Text(
                            'Tem certeza que deseja sair?\n\nSerá necessário entrar com seu usuário e senha na próxima vez que for utilizar o aplicativo.\n'
                            '\nTodos os dados armazenados no aplicativo serão apagados.'),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.approval),
                                    Text('Ficar')
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red),
                                onPressed: () {
                                  SharedPreferences.getInstance().then(
                                    (value) => value.remove("data"),
                                  );
                                  SystemChannels.platform
                                      .invokeMethod('SystemNavigator.pop');
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.exit_to_app),
                                    Text('Sair')
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }

  bool botao = false;

  BodyPage(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                alignment: Alignment.center,
                image: AssetImage('assets/constata.png'),
                opacity: 0.25)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                child: Text(
                    'Você está na ${widget.dataLogged['obra']['data']['tb01_cp002']}\n',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                    )),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: Image.asset(
                'assets/constata_big.png',
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 5.0, 12.0, 5.0),
                    // ignore: sized_box_for_whitespace
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.065,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            var route = MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  EffectiveControl(
                                dataLogged: widget.dataLogged,
                              ),
                            );

                            Navigator.of(context).push(route);
                          });
                        },
                        child: const Text("1 - Controle de Efetivo"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 5.0, 12.0, 5.0),
                    // ignore: sized_box_for_whitespace
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.065,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showLoading(context);
                            CompanyRefreshController.refresh(
                                    widget.dataLogged['obra']['data']
                                        ['tb01_cp002'],
                                    Provider.of<Token>(context, listen: false)
                                        .token)
                                .then((value) {
                              if (value == null) {
                                Navigator.of(context).pop();
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Verifique sua conexão!'),
                                        content: Text(
                                            'Não foi possível sincronizar os dados da obra. Caso prossiga, podem ocorrer inconsistências.'),
                                      );
                                    }).then((value) {
                                  var route = MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Measurement(
                                      dataLogged: widget.dataLogged,
                                    ),
                                  );

                                  Navigator.of(context).push(route);
                                });
                              } else if (value.isNotEmpty) {
                                Navigator.of(context).pop();
                                widget.dataLogged['obra'] = value[0];
                                var route = MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      Measurement(
                                    dataLogged: widget.dataLogged,
                                  ),
                                );

                                Navigator.of(context).push(route);
                              } else {
                                Navigator.of(context).pop();
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                            'Ocorreu um problema volte e tente novamente!'),
                                        content: Text(
                                            'Não foi possível sincronizar os dados da obra. Caso prossiga, podem ocorrer inconsistências.'),
                                      );
                                    }).then((value) {
                                  var route = MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Measurement(
                                      dataLogged: widget.dataLogged,
                                    ),
                                  );
                                  Navigator.of(context).push(route);
                                });
                              }
                            });
                          });
                        },
                        child: const Text("2 - Controle de medição"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 5.0, 12.0, 5.0),
                    // ignore: sized_box_for_whitespace
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.065,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            var route = MaterialPageRoute(
                              builder: (BuildContext context) => EpiHome(
                                dataLogged: widget.dataLogged,
                              ),
                            );

                            Navigator.of(context).push(route);
                          });
                        },
                        child: const Text("3 - Controle de EPI"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 5.0, 12.0, 5.0),
                    // ignore: sized_box_for_whitespace
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.065,
                      child: ElevatedButton(
                        onPressed: () {
                          var route = MaterialPageRoute(
                            builder: (BuildContext context) => SelectDatePage(
                              dataLogged: widget.dataLogged,
                            ),
                          );

                          Navigator.of(context).push(route);
                        },
                        child: const Text("4 - Controle de Ferramentas"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.065,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Desconectar'),
                        content: Text(
                            'Tem certeza que deseja sair?\n\nSerá necessário entrar com seu usuário e senha na próxima vez que for utilizar o aplicativo.\n'
                            '\nTodos os dados armazenados no aplicativo serão apagados.'),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.approval),
                                    Text('Ficar')
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red),
                                onPressed: () {
                                  SharedPreferences.getInstance().then(
                                    (value) => value.remove("data"),
                                  );
                                  SystemChannels.platform
                                      .invokeMethod('SystemNavigator.pop');
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.exit_to_app),
                                    Text('Sair')
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      );
                    },
                  );
                },
                child: Text('Sair'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  var _pageController = PageController(initialPage: 1);
  int _selectedIndex = 1;

  void initializer() {
    fetchColaboradores();
    fetchEquipments();
    loginDate();
  }

  @override
  void initState() {
    super.initState();
    tokenSerilizado = Provider.of<Token>(context, listen: false).token;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initializer();
      AuthRefreshController authRefreshcontroller = AuthRefreshController();
      authRefreshcontroller.checkAuth(tokenSerilizado).then((value) {
        print('\n\n\n\n\nChecking Expired Auth Token\n\n\n\n\n');
        // Navigator.pop(context);
        if (value.isNotEmpty) {
          print('\n\n\n\n\nNew Token Refreshed\n\n\n\n\n');

          Provider.of<Token>(context, listen: false).setToken(value);
        }
        print('\n\n\n\n\nToken Not Expired\n\n\n\n\n');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Olá, ${widget.dataLogged['user']['name']}.'),
        // title: Text("${tokenSerilizado['access_token']}"),
        centerTitle: true,
      ),

      drawer: CustomDrawer(context),
      body: BodyPage(context),
    );
  }
}
