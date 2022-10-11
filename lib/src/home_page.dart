import 'dart:convert';
import 'package:constata_0_0_2/src/models/token.dart';
import 'package:constata_0_0_2/src/shared/auth_refresh_controller.dart';
import 'package:constata_0_0_2/src/shared/company_refresh_controller.dart';
import 'package:constata_0_0_2/src/shared/load_controller.dart';
import 'package:constata_0_0_2/src/shared/pallete.dart';
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
    String obra = widget.dataLogged['obra']['data']['tb01_cp002'];
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                isAntiAlias: true,
                alignment: Alignment.center,
                image: AssetImage('assets/constata.png'),
                opacity: 0.25)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                child: Text('Conectado em $obra',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    )),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Container(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/constata_big.png',
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16, left: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  children: <Widget>[
                    GridButton(
                        icon: const Icon(
                          Icons.edit_calendar,
                          size: 30,
                        ),
                        label: "1 - Controle de Efetivo",
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
                        }),
                    GridButton(
                      icon: const Icon(Icons.add_task, size: 30),
                      label: "2 - Controle de medição",
                      onPressed: () => navigateMedicao(context),
                    ),
                    GridButton(
                        label: "3 - Controle de EPI",
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
                        icon: const Icon(Icons.health_and_safety, size: 30)),
                    GridButton(
                        onPressed: () {
                          var route = MaterialPageRoute(
                            builder: (BuildContext context) => SelectDatePage(
                              dataLogged: widget.dataLogged,
                            ),
                          );

                          Navigator.of(context).push(route);
                        },
                        label: "4 - Controle de Ferramentas",
                        icon: const Icon(
                          Icons.handyman,
                          size: 30,
                        )),
                  ],
                ),
              ),
            ),
            Divider(),
            Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.065,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                onPressed: () {
                  exitApplication(context);
                },
                child: Text('Sair'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> exitApplication(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Desconectar'),
          content: const Text(
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
                    children: const [Icon(Icons.approval), Text('Ficar')],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: () {
                    SharedPreferences.getInstance().then(
                      (value) => value.remove("data"),
                    );
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Column(
                    children: const [Icon(Icons.exit_to_app), Text('Sair')],
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void navigateMedicao(BuildContext context) {
    return setState(() {
      showLoading(context);
      CompanyRefreshController.refresh(
              widget.dataLogged['obra']['data']['tb01_cp002'],
              Provider.of<Token>(context, listen: false).token)
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
              builder: (BuildContext context) => Measurement(
                dataLogged: widget.dataLogged,
              ),
            );

            Navigator.of(context).push(route);
          });
        } else if (value.isNotEmpty) {
          Navigator.of(context).pop();
          widget.dataLogged['obra'] = value[0];
          var route = MaterialPageRoute(
            builder: (BuildContext context) => Measurement(
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
                  title: Text('Ocorreu um problema volte e tente novamente!'),
                  content: Text(
                      'Não foi possível sincronizar os dados da obra. Caso prossiga, podem ocorrer inconsistências.'),
                );
              }).then((value) {
            var route = MaterialPageRoute(
              builder: (BuildContext context) => Measurement(
                dataLogged: widget.dataLogged,
              ),
            );
            Navigator.of(context).push(route);
          });
        }
      });
    });
  }

  var _pageController = PageController(initialPage: 1);
  int _selectedIndex = 1;

  void initializer() {
    fetchColaboradores();
    fetchEquipments();
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

class GridButton extends StatelessWidget {
  final void Function() onPressed;

  final Icon icon;

  final String label;

  const GridButton({Key key, this.onPressed, this.icon, this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            elevation: 5, primary: Palette.customSwatch.withOpacity(.9)),
        onPressed: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            Text(
              label,
              textAlign: TextAlign.center,
            )
          ],
        ));
  }
}
