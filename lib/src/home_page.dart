import 'dart:convert';

import 'package:constata/services/messaging/firebase_messaging_service.dart';
import 'package:constata/src/features/login/login_controller.dart';
import 'package:constata/src/features/login/login_repository.dart';
import 'package:constata/src/features/login/select_build_page.dart';
import 'package:constata/src/shared/custom_page_route.dart';
import 'package:constata/src/shared/dark_mode.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:constata/src/models/token.dart';
import 'package:constata/src/shared/auth_refresh_controller.dart';

import 'features/effective_process/data/appointment_data.dart';
import 'features/measurement/data/measurement_data.dart';
import 'widgets/home_page.dart';

class HomePage extends StatefulWidget {
  final Map
      dataLogged; // ---> OBJETO COM TODOS OS DADOS DAS TELAS ANTERIORES (usuário, token,empresa, filial, local de negocio e empresa)

  const HomePage({Key? key, required this.dataLogged}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String tokenSerilizado = '';

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
      debugPrint('gravou na memoria');
      return true;
    } else {
      debugPrint(await response.stream.bytesToString());

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
        debugPrint('pegous os EPI na home page');
        SharedPreferences.getInstance().then((value) async => value.setString(
            "epi",
            jsonEncode(jsonDecode(await response.stream.bytesToString()))));
        debugPrint('gravou na memoria os EPI');
        return true;
      } else {
        debugPrint(response.statusCode.toString());
        return false;
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  customDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
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
              trailing: const Icon(Icons.lock_open, color: Colors.red),
              onTap: () {
                showDialog(
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
                                child: const Column(
                                  children: [
                                    Icon(Icons.approval),
                                    Text('Ficar')
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () {
                                  SharedPreferences.getInstance().then(
                                    (value) => value.remove("data"),
                                  );
                                  SystemChannels.platform
                                      .invokeMethod('SystemNavigator.pop');
                                },
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.exit_to_app,
                                    ),
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
          Card(
            child: ListTile(
              title: const Text('Mudar de obra'),
              trailing: const Icon(Icons.change_circle, color: Colors.blue),
              onTap: () async {
                var prefs = await SharedPreferences.getInstance();
                Map username = jsonDecode(prefs.getString('authentication')!);
                debugPrint(username.toString());
                Provider.of<AppointmentData>(context, listen: false)
                    .clearAppointmentData();
                Provider.of<MeasurementData>(context, listen: false)
                    .clearMeasurementData();
                Navigator.of(context).pop();
                changeBuild();
              },
            ),
          ),
        ],
      ),
    );
  }

  final loginController = LoginController(LoginRepository(Dio()));

  void changeBuild() async {
    var prefs = await SharedPreferences.getInstance();
    Map authParam = jsonDecode(prefs.getString('authentication')!);
    await loginController.generateToken(
        authParam['user'], authParam['password']);
    final user = await loginController.fetchUserSigned(authParam['user']);

    final userData =
        await loginController.pegarParceiroDeNegocio(authParam['user']);

    final obraData =
        await loginController.fetchObraData(userData['tb01_cp004']);

    var route = CustomPageRoute(
      builder: (BuildContext context) => SelectObra(
        obraData: obraData,
        user: user,
      ),
    );

    Navigator.of(context).push(route);
  }

  @override
  void initState() {
    super.initState();
    checkInitToken();
  }

  void checkInitToken() {
    tokenSerilizado = Provider.of<Token>(context, listen: false).token;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      AuthRefreshController authRefreshcontroller = AuthRefreshController();
      await authRefreshcontroller.checkAuth(tokenSerilizado).then((value) {
        debugPrint('Checking Expired Auth Token');
        // Navigator.pop(context);
        if (value.isNotEmpty) {
          debugPrint('New Token Refreshed');

          Provider.of<Token>(context, listen: false).setToken(value);
        }
        debugPrint('Token Not Expired');
      });

      fetchColaboradores();
      fetchEquipments();
    });
  }

  changeTheme() async {
    Provider.of<DarkMode>(context, listen: false).changeMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${widget.dataLogged['user']['name']}.'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              changeTheme();
            },
            icon: Provider.of<DarkMode>(context, listen: false).isDarkMode
                ? const Icon(Icons.wb_sunny)
                : const Icon(Icons.nightlight_round),
          ),
        ],
      ),
      drawer: customDrawer(context),
      body: HomePageBody(arguments: widget.dataLogged),
    );
  }
}
