import 'package:checador_rola/Screens/incidencia.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:checador_rola/Functions/colors.dart';
import 'package:checador_rola/Functions/sessions.dart';
import 'package:checador_rola/home.dart';
import 'package:checador_rola/Screens/home_supervisor.dart';
import 'Screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AsistenciasApp());
}

class AsistenciasApp extends StatelessWidget {

  const AsistenciasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asistencias Ro&la',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: MAIN_COLOR,
          brightness: Brightness.light,
          hintColor: SECONDARY_COLOR,
          buttonTheme: ButtonThemeData(
            buttonColor: LIGHT_BLUE_COLOR,
            textTheme: ButtonTextTheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Login(load: loadSession()),
        '/home': (context) => Home(),
      },
    );
  }
}

