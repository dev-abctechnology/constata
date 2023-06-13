import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:constata/firebase_options.dart';
import 'package:constata/src/features/login/login_page.dart';
import 'package:constata/src/features/measurement/data/measurement_data.dart';
import 'package:constata/src/models/token.dart';
import 'package:constata/src/shared/dark_mode.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/features/effective_process/data/appointment_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  //TODO: request permission
  //TODO: Register with FCM
  //TODO: Set up foreground message handler
  //TODO: Set up background message handler

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DarkMode>(
          create: (context) => DarkMode(),
        ),
        ChangeNotifierProvider<Token>(
          create: (context) => Token(),
        ),
        ChangeNotifierProvider<AppointmentData>(
          create: (context) => AppointmentData(),
        ),
        ChangeNotifierProvider<MeasurementData>(
          create: (context) => MeasurementData(),
        ),
      ],
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Constata - Apontamento Digital",
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Provider.of<DarkMode>(context).isDarkMode
                  ? Brightness.dark
                  : Brightness.light,
            ),
            // primarySwatch: Palette.customSwatch,
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
                  splashTransition: SplashTransition.slideTransition,
                  curve: Curves.easeInOutCubic,
                  backgroundColor: Provider.of<DarkMode>(context).isDarkMode
                      ? const Color.fromARGB(221, 27, 27, 27)
                      : const Color.fromARGB(255, 231, 231, 231),
                  splashIconSize: 100,
                  animationDuration: const Duration(milliseconds: 1000),
                ),
            // '/home': (context) => const HomePage(),
          },
        );
      },
    ),
  );
}
