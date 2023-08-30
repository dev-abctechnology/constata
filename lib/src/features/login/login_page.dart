import 'dart:convert';
import 'package:constata/services/messaging/firebase_messaging_service.dart';
import 'package:constata/services/messaging/notification_service.dart';
import 'package:constata/src/features/login/login_controller.dart';
import 'package:constata/src/features/login/login_repository.dart';
import 'package:constata/src/home_page.dart';
import 'package:constata/src/models/token.dart';
import 'package:constata/src/shared/custom_page_route.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/privacy_dialog.dart';
import 'select_build_page.dart';

//LOGIN
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

//ESTADO DO LOGIN
class _LoginState extends State<Login> {
  final loginController = LoginController(
    LoginRepository(
      Dio(),
    ),
  );

  final ValueNotifier _isLoading = ValueNotifier<bool>(false);

  Future<void> login(String username, String password) async {
    _isLoading.value = true;
    try {
      await loginController.generateToken(username, password);

      final user = await loginController.fetchUserSigned(username);

      final userData = await loginController.pegarParceiroDeNegocio(username);

      final obraData =
          await loginController.fetchObraData(userData['tb01_cp004']);

      var route = CustomPageRoute(
        builder: (BuildContext context) => SelectObra(
          obraData: obraData,
          user: user,
        ),
      );
      _usernameController.clear();
      _passwordController.clear();
      await Navigator.of(context).push(route).then((value) async {
        print(value);
        _usernameController.text = 'kkkkkkkkkkk';
        _passwordController.text = 'kkkkkkkkkkk';
        setState(() {});
        await login(value['user'], value['password']);
      });
    } catch (e, s) {
      print(s);
      String error = e.toString();
      error = error.replaceAll('Exception: ', '');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              )
            ],
          );
        },
      );
    }
    _isLoading.value = false;
  }

  Future<void> isLogged() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("data")) {
      Map dataLogged = await json.decode(prefs.getString("data")!);
      Provider.of<Token>(context, listen: false).setToken(dataLogged['token']);

      var route = CustomPageRoute(
        builder: (BuildContext context) => HomePage(
          dataLogged: dataLogged,
        ),
      );
      Navigator.of(context).push(route);
    } else {
      print('nao tem dados salvos no shared preferences');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeFirebaseMessaging();
    checkNotifications();
    isLogged();
    // subscribeToTopic();
  }

  unsubscribeFromTopic() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('all');
  }

  subscribeToTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('all');
  }

  initializeFirebaseMessaging() async {
    await Provider.of<FirebaseMessagingService>(context, listen: false).init();
  }

  checkNotifications() async {
    await Provider.of<NotificationService>(context, listen: false)
        .checkForNotifications();
  }

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seja bem-vindo!'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/constata_big.png',
                      color: Colors.blue,
                      height: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome de usuário',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite seu nome de usuário';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite sua senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder(
                  valueListenable: _isLoading,
                  builder: (context, value, child) {
                    if (value == true) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await login(
                            _usernameController.text,
                            _passwordController.text,
                          );
                        }
                      },
                      child: const Text('Entrar'),
                    );
                  },
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => PrivacyPolicyDialog(),
                    );
                  },
                  child: const Text('Política de privacidade'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
