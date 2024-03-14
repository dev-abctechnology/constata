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
    try {
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
        return false;
      }
    } catch (e) {
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
              children: [
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(70.0)),
                  elevation: 20,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/images/constata.png',
                          width: 40,
                          height: 40,
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
                                onPressed: () async {
                                  SharedPreferences.getInstance().then(
                                    (value) => value.remove("data"),
                                  );
                                  await Provider.of<FirebaseMessagingService>(
                                          context,
                                          listen: false)
                                      .unsubscribeFromAllTopics();
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
                try {
                  Provider.of<AppointmentData>(context, listen: false)
                      .clearAppointmentData();
                  Provider.of<MeasurementData>(context, listen: false)
                      .clearMeasurementData();
                  Navigator.of(context).pop();
                  changeBuild();
                } catch (e) {
                  print(e);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  final loginController = LoginController(LoginRepository(Dio()));

  void changeBuild() async {
    try {
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

      Navigator.of(context).pushReplacement(route);
    } catch (e) {
      print('Failed to generate token: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    checkInitToken();
  }

  void checkInitToken() {
    try {
      tokenSerilizado = Provider.of<Token>(context, listen: false).token;

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        AuthRefreshController authRefreshcontroller = AuthRefreshController();

        try {
          // Check the authentication status using the obtained token
          String value = await authRefreshcontroller.checkAuth(tokenSerilizado);

          debugPrint('Checking Expired Auth Token');

          // If a new token is received, update it in the Provider
          if (value.isNotEmpty) {
            debugPrint('New Token Refreshed');
            Provider.of<Token>(context, listen: false).setToken(value);
          }

          debugPrint('Token Not Expired');
        } catch (authException) {
          // Handle authentication-related exceptions
          debugPrint('Authentication Exception: $authException');
          // You may want to perform specific actions for authentication errors
        }

        try {
          // Fetch Colaboradores data
          fetchColaboradores();
        } catch (colaboradoresException) {
          // Handle exceptions related to fetching Colaboradores data
          debugPrint('Colaboradores Exception: $colaboradoresException');
          // You may want to perform specific actions for Colaboradores data errors
        }

        try {
          // Fetch Equipments data
          fetchEquipments();
        } catch (equipmentsException) {
          // Handle exceptions related to fetching Equipments data
          debugPrint('Equipments Exception: $equipmentsException');
          // You may want to perform specific actions for Equipments data errors
        }
      });
    } catch (e) {
      // Handle any other exceptions that might occur outside the async code
      debugPrint('Unexpected Exception: $e');
      // You may want to perform specific actions for unexpected errors
    }
  }

  changeTheme() async {
    Provider.of<DarkMode>(context, listen: false).changeMode();
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmação'),
              content: const Text('Tem certeza que deseja sair?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Retorna falso se o usuário cancelar
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Retorna verdadeiro se o usuário confirmar
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        ) ??
        false; // Se o usuário fechar o diálogo, retorna false
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool confirmed = await _showConfirmationDialog();
        return confirmed;
      },
      child: Scaffold(
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
      ),
    );
  }
}
