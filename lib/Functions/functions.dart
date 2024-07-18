import 'dart:io';
import 'dart:math';
import 'package:checador_rola/Functions/alerts.dart';
import 'package:flutter/material.dart';
import '../Helpers/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


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

void closeSession() async {
  var directory = await getApplicationDocumentsDirectory();
  var path = directory.path;
  File session = File('$path/gIAU');
  session.writeAsString('');
}

void saveSessionFunct( String hash) async {

  var directory = await getApplicationDocumentsDirectory();
  var path = directory.path;

  File session = File('$path/gIAU');
  session.writeAsString(hash);

}

Future <bool> isOnline(context)async{
  bool conexion = await Conn.isInternet().then((connection){
    if (connection) {
      showToast('Conectado a internet', context);
      /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(milliseconds: 500),
        content: Row(
            children: <Widget>[
              Expanded(flex: 2,
                child: Center(
                  child: Icon(
                    Icons.wifi,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(flex: 10,
                child: Text(" Conectado a Internet", textAlign: TextAlign.center,),),
            ]
        ),
      ),);*/

      return true;
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
            children: <Widget>[
              Expanded(flex: 2,
                child: Center(
                  child: Icon(
                    Icons.wifi_off,
                    color: Colors.white,),
                ),
              ),
              Expanded(flex: 10,
                child: Text("En este momento no tienes conexión a Internet", textAlign: TextAlign.center,),)
            ]
        ),
      ),
      );
      return false;
    }
  }); return conexion;
}

double calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
  const radioTierra = 6371000; // en metros

  double convertirARadianes(double grados) {
    return grados * (pi / 180);
  }

  double diferenciaLatitud = convertirARadianes(lat2 - lat1);
  double diferenciaLongitud = convertirARadianes(lon2 - lon1);

  double a = sin(diferenciaLatitud / 2) * sin(diferenciaLatitud / 2) +
      cos(convertirARadianes(lat1)) * cos(convertirARadianes(lat2)) *
          sin(diferenciaLongitud / 2) * sin(diferenciaLongitud / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double distancia = radioTierra * c;
  return distancia;
}

class Conn {
  static Future<bool> isInternet() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      return true;
    } else{
      return false;
    }
  }
}

