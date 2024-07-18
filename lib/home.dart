import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../Functions/colors.dart';
import '../Functions/request.dart';
import '../Functions/sessions.dart';
import '../Screens/home_guardias.dart';
import 'Helpers/user.dart';
import 'Screens/home_oficina.dart';
import 'Screens/home_supervisor.dart';
import 'Screens/lookIOs.dart';

class Home extends StatefulWidget{

  static const routeName = '/Home';

  Home({Key? key,}): super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool? _save;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Map? _arguments;
  User? user;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
      FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('error');
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return scaffold();
          }
          return Center(child: Text(''));
        },
      );
  }

  Widget scaffold(){
    _arguments = ModalRoute.of(context)!.settings.arguments as Map;
    _save = _arguments!['save'];
    user = _arguments!['datos'];
    if (!_save!) {
      _firebaseMessaging.getToken().then((res) {
        var key = utf8.encode(user!.id.toString());
        var bytes = utf8.encode(user!.operativoid.toString());

        var hmacSha256 = new Hmac(sha256, key);
        var digest = hmacSha256.convert(bytes);
        saveSessionFunct(digest.toString(), user!);
        saveTokenReq(
            res!,
            digest.toString(),
            user!.id.toString()
        );
        _save = true;
      });
    }
    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Checador', style: TEXT_BUTTON_STYLE),
          centerTitle: true,
          backgroundColor: DARK_BLUE_COLOR,
      ),
      body: options(user!),
      bottomSheet: Text('Versión 1.1.2', style: TEXT_FIELD, textAlign: TextAlign.left,),
    );
  }

  Widget options(User user) {
    switch(user.puesto.toString().toUpperCase()) {
      case 'SUPERVISOR' || 'SUPERVISOR CDMX':
        return Platform.isIOS ? Locked() : HomeSup(info: user);
      case 'OPERADOR' || 'JEFA DE GRUPO GUARDIA (A)' || 'GUARDIA (A)' || 'GUARDIA (B)' || 'GUARDIA (A) CDMX' || 'GUARDIA ADUANA' || 'JEFE DE GRUPO (B)' || 'JEFE DE OPERACIONES':
        return Platform.isIOS ? Locked() : HomeGua(info: user);
      default:
        return HomeOfi(info: user);
    }
  }
}
