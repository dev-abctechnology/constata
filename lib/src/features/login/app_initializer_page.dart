import 'dart:convert';

import 'package:constata/services/messaging/firebase_messaging_service.dart';
import 'package:constata/services/messaging/notification_service.dart';
import 'package:constata/src/features/login/login_page.dart';
import 'package:constata/src/home_page.dart';
import 'package:constata/src/models/token.dart';
import 'package:constata/src/shared/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    // Inicialize outros serviços aqui, se necessário
    initializeFirebaseMessaging();
    checkNotifications();

    // Adicione uma pequena pausa antes de verificar o status de login
    isLogged();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  initializeFirebaseMessaging() async {
    await Provider.of<FirebaseMessagingService>(context, listen: false).init();
  }

  checkNotifications() async {
    await Provider.of<NotificationService>(context, listen: false)
        .checkForNotifications();
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
      Navigator.of(context).pushReplacement(route);
    } else {
      var route = CustomPageRoute(
        builder: (BuildContext context) => const Login(),
      );
      Navigator.of(context).pushReplacement(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RotationTransition(
          turns: _controller,
          child: Container(
            height: MediaQuery.of(context).size.shortestSide * 0.25,
            child: Image.asset(
              'assets/images/constata.png',
            ),
          ),
        ),
      ),
    );
  }
}
