import 'dart:io';
import 'package:checador_rola/Functions/request.dart';

import '../Helpers/database.dart';
import '../Helpers/user.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

void verifyUser(User usr, context, {bool saveSession = false}) async {
  Navigator.pushNamedAndRemoveUntil(
      context, '/home', (Route<dynamic> route) => false,
      arguments: {
        'datos': usr,
        'save': saveSession,
      });
}

void saveSessionFunct( String hash, User user) async {
  var directory = await getApplicationDocumentsDirectory();
  var path = directory.path;

  File session = File('$path/gIAU');
  session.writeAsString(hash);

  //Aqui va la insercion a la base de datos solo si no existe un usuario activo
  final dbHelper = DatabaseHelper();
  final db = await dbHelper.db;

  final List<Map<String, dynamic>> data = await db.query('users');
  if (data.isEmpty) {
    await db.insert('users', {'contactid': user.id, 'lastname': user.nombres, 'telefono': user.telefono == '' ? 0 : user.telefono, 'email': user.correo, 'puesto': user.puesto, 'status': 1});
  }else{
    user = User.fromJSON(data.first);
  }
}

Future<String> loadSession() async {
  print('Load session!');
  var directory = await getApplicationDocumentsDirectory();
  var path = directory.path;

  try {
    File session = File('$path/gIAU');
    String contents = await session.readAsString();
    return contents;
  } catch (e) {
    print('Exception here: $e');
    return '';
  }
}

Widget loadingUser = const Column(
    children: <Widget>[
      SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(),
      ),
       Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text('Comprobando si hay una sesión'),
      )
    ]
);