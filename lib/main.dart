import 'package:constata_0_0_2/src/home_page.dart';
import 'package:constata_0_0_2/src/login_page.dart';
import 'package:constata_0_0_2/src/models/token.dart';

import 'package:constata_0_0_2/src/shared/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

import 'src/features/effective_process/data/appointment_data.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Token>(
          create: (context) => Token(),
        ),
        ChangeNotifierProvider<AppointmentData>(
          create: (context) => AppointmentData(),
        ),
      ],
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Constata - Apontamento Digital",
          theme: ThemeData(
            useMaterial3: false,
            primarySwatch: Palette.customSwatch,
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt', 'BR'),
          ],
          initialRoute: "/",
          routes: {
            '/': (context) => AnimatedSplashScreen(
                  nextScreen: const Login(),
                  splash: Image.asset(
                    'assets/images/constata.png',
                  ),
                  splashTransition: SplashTransition.fadeTransition,
                  backgroundColor: Colors.white,
                  splashIconSize: 100,
                  animationDuration: const Duration(seconds: 2),
                ),
            '/homePage': (context) => HomePage(),
          },
        );
      },
    ),
  );
}
