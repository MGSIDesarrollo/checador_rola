import 'package:flutter/material.dart';

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