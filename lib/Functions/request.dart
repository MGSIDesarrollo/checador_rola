import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Helpers/database.dart';
import '../Helpers/operation.dart';
import '../Helpers/user.dart';
import '../Resources/urls.dart';

Future<dynamic> loginReq(String usr, String pass) async {

  var url = '$PRE_URL/user.php';
  var response = await http.post(Uri.parse(url), body:{
    'infoU': usr,
    'load': pass
  });

  if(response.statusCode != 200){
    return null;
  }

  var data;
  try{
    data = jsonDecode(response.body);
  }catch(e){
    print(e.toString());
    return null;
  }

  if(data['status']==200 && !(data['data']==null || data['data']=='no ok' || data['data'].isEmpty)){
    User user = User.fromJSON(data['data']);
    if (data['firma'] == 'Existe'){
      return user;
    } if (user.puesto != 'Supervisor' && user.puesto != 'Jefa de grupo Guardia (A)'){
      return user;
    } else {
      return [user, 'Sin firma'];
    }
  }
  return null;
}

Future<bool?> saveTokenReq( String fcmToken, String hash, String id ) async {
  var url = PRE_URL + '/hash-token-save.php';

  var response = await http.post(Uri.parse(url), body: {
    'token': fcmToken,
    'hash': hash,
    'id': id
  });

  if (response.statusCode!=200) {
    return null;
  }
  var data;

  try {
    data = jsonDecode(response.body);
  } catch (e) {
    return null;
  }
  return data['status']==200;
}
///Login with persistence
Future<dynamic> loadSessionReq( String hash, ) async {
  var url = PRE_URL + '/load-session2.php'; //todo cambiar a load session
  var response = await http.post(Uri.parse(url), body: {
    'auth-key': hash,
  });

  if (response.statusCode!=200) {
    return null;
  }
  var data;

  try {
    data = jsonDecode(response.body);
    await downCheckpoints(data['data']['contactid'].toString());
  } catch (e) {
    return null;
  }

  if(data['status']==200 && data['data']!=null){
    User user = User.fromJSON(data['data']);
    print('object '+data.toString());
    if (data['firma'] == 'Existe'){
      return user;
    } else{
      switch(user.puesto.toString().toUpperCase()){
        case 'SUPERVISOR' || 'SUPERVISOR CDMX' || 'OPERADOR' || 'JEFA DE GRUPO GUARDIA (A)' || 'GUARDIA (A)' || 'GUARDIA (B)' || 'GUARDIA (A) CDMX' || 'GUARDIA ADUANA' || 'JEFE DE GRUPO (B)' || 'JEFE DE OPERACIONES':
          return [user, 'Sin firma'];
          default:
            return user;
      }
    }
  }
  return null;
}

Future<bool?> locationReq(String lat, String lng, String id, {String? ubi}) async {
  var url = PRE_URL + '/localizacion_sucursales2.php';
  var response = await http.post(Uri.parse(url), body: {
    'lat': lat,
    'lng': lng,
    'id': id,
    'ubi': ubi ?? '',
  });

  if (response.statusCode!=200) {
    return null;
  }
  var data;

  try {
    data = jsonDecode(response.body);
  } catch (e) {
    return null;
  }
  //devuelve un booleano
  return data['status'] == 200;
}

Future<bool?> registro_checada(String lat, String lng, id, int check, {String? date}) async {
  var url = PRE_URL + '/registro_checadas.php';
  var response = await http.post(Uri.parse(url), body: {
    'lat': lat,
    'lng': lng,
    'id_contact': id.toString(),
    'check': check.toString(),
    'date': date ?? '',
  });

  if (response.statusCode!=200) {
    return null;
  }
  var data;

  try {
    data = jsonDecode(response.body);
  } catch (e) {
    return null;
  }

  return data['status']==200;
}

Future<dynamic>saveImage2(imagen, filename)async {
  var url = PRE_URL + '/saveImages.php';
  var request = new http.MultipartRequest("POST", Uri.parse(url));

  var image = http.MultipartFile.fromBytes('imagen', imagen, filename: filename.toString());
  request.files.add(image);

  var response = '';
  await request.send().then((value){
    if(value == null){
      response = 'Error';
    }else{
      response = 'Ok';
    }
  });
  return response;
}

operationsReq(String id) async{
  var url = PRE_URL + '/operations.php';
  var response = await http.post(Uri.parse(url), body: {
    'id': id,
  });
  if (response.statusCode!=200) {
    return null;
  }
  var data;
  try {
    data = jsonDecode(response.body);
    return data['data'];
  } catch (e) {
    return null;
  }
}

reporteOperacionEmail(String id_operation) {
  sendEmail(id_operation).then((val){
    return val;
  });
}

sendEmail(String id_operation) async{
  var url = PRE_URL + '/reporteOperacionEmail.php';
  var response = await http.post(Uri.parse(url), body: {
    'operacion': id_operation,
  });
  if (response.statusCode!=200) {
    return null;
  }
  var data;
  try {
    data = jsonDecode(response.body);
    return true;//data['data'];
  } catch (e) {
    return null;
  }
}

Future<Operation?> operationReq(String id) async{
  var url = PRE_URL + '/operation.php';
  var response = await http.post(Uri.parse(url), body: {
    'id': id,
  });
  if (response.statusCode!=200) {
    return null;
  }
  var data;
  try {
    data = jsonDecode(response.body);
    return Operation.fromJSON(data['data'][0]);
  } catch (e) {
    return null;
  }
}

Future<String?> terminarOperacion(String id, hora) async{
  var url = PRE_URL + '/terminarOperacion.php';
  var response = await http.post(Uri.parse(url), body: {
    'id': id,
    'hora': hora
  });
  if (response.statusCode!=200) {
    return null;
  }
  var data;
  try {
    data = jsonDecode(response.body);
    return data['data'];
  } catch (e) {
    return null;
  }
}

downCheckpoints(String id) async {
  var url = PRE_URL + '/checkpoints2.php';
  var response = await http.post(Uri.parse(url), body: {
    'id': id,
  });

  if (response.statusCode!=200) {
    return null;
  }
  var data;

  try {
    data = jsonDecode(response.body);
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.db;
    for(var suc in data['data']){
      db.insert('checkpoints', {'id': suc['id'], 'name': suc['name'] /*, 'address': suc['address']*/ , 'latitude': suc['latitude'].toString(), 'longitude' : suc['longitude'].toString(), 'status': suc['status'] == 'Activa' ? 1 : 0});
    }
  } catch (e) {
    return null;
  }
  return data['status']==200;
}

Future<List<dynamic>> operatorsReq() async {
  var url = PRE_URL + '/operators.php';
  var response = await http.post(Uri.parse(url), body: {});

  if (response.statusCode!=200) {
    return [];
  }
  var data;

  try {
    data = jsonDecode(response.body);
    return data['data'];
  } catch (e) {
    return [];
  }
}

Future<List<dynamic>> incidenciasReq() async {
  var url = PRE_URL + '/get_incidencias.php';
  var response = await http.post(Uri.parse(url), body: {});

  if (response.statusCode!=200) {
    return [];
  }
  var data;

  try {
    data = jsonDecode(response.body);
    return data['data'];
  } catch (e) {
    return [];
  }
}

Future<dynamic> upPoint(json, String iter) async {
  var url = PRE_URL + '/upPoints.php';
  var response = await http.post(Uri.parse(url),
    body: {'json': json, 'count': iter,},
  );
  if (response.statusCode!=200) {
    return null;
  }
  var data;
  try {
    data = jsonDecode(response.body);
    return data['data'];
  } catch (e) {
    return null;
  }
}

newCabina(String name, String empresa, String start, String end, String operativo, String observaciones, String operacion, String crmid, String no_tia, String motivo) async{
  var url = PRE_URL + '/insertCabina.php';
  var response = await http.post(Uri.parse(url), body: {
    'name': name,
    'empresa': empresa,
    'start': start,
    'end': end,
    'operativo': operativo,
    'observaciones': observaciones,
    'operacion': operacion,
    'crmid': crmid,
    'no_tia': no_tia,
    'motivo': motivo,
  });
  if (response.statusCode!=200) {
    return null;
  }
  var data;
  try {
    data = jsonDecode(response.body);
    return data['data'];
  } catch (e) {
    return null;
  }
}

newInforme(String id_operation, String operativo, String paxEntrada, String paxSalida, String openDoors, String closeDoors, String firstPaxIn, String lastPaxIn, String firstPaxOut, String lastPaxOut,) async{
  var url = PRE_URL + '/insertInforme.php';
  var response = await http.post(Uri.parse(url), body: {
    'id_operation': id_operation,
    'operativo': operativo,
    'paxEntrada': paxEntrada,
    'paxSalida': paxSalida,
    'openDoors': openDoors,
    'closeDoors': closeDoors,
    'firstPaxIn': firstPaxIn,
    'lastPaxIn': lastPaxIn,
    'firstPaxOut': firstPaxOut,
    'lastPaxOut': lastPaxOut,
  });
  if (response.statusCode!=200) {
    return null;
  }
  var data;
  try {
    data = jsonDecode(response.body);
    return data['data'];
  } catch (e) {
    return 'catch '+response.body.toString();
  }
}

newCustodia(String pasajero, String migracion, String migracion2, String nacionalidad, String date, String operativo, String operacion) async{
  var url = PRE_URL + '/insertCustodia.php';
  var response = await http.post(Uri.parse(url), body: {
    'pasajero': pasajero,
    'migracion': migracion,
    'migracion2': migracion2,
    'nacionalidad': nacionalidad,
    'date': date.substring(0, 10),
    'time': date.substring(11, 19),
    'operativo': operativo,
    'operacion': operacion,
  });
  if (response.statusCode!=200) {

    return null;
  }
  var data;
  try {
    data = jsonDecode(response.body);
    return data['data'];
  } catch (e) {
    return null;
  }
}

Future<dynamic> new_incidencia(String contact, String start, String end, String motivo) async {
  var url = PRE_URL + '/incidencias.php';
  var response = await http.post(Uri.parse(url),
    body: {'contact': contact, 'start': start, 'end': end, 'motivo': motivo},
  );
  if (response.statusCode!=200) {
    return null;
  }
  var data;
  try {
    data = jsonDecode(response.body);
    return data['data'];
  } catch (e) {
    return null;
  }
}

Future<List<dynamic>> reqUbis() async {
  var url = PRE_URL + '/getUbis.php';
  var response = await http.post(Uri.parse(url), body: {},);
  if (response.statusCode != 200) {
    return [];
  }
  var data;
  try {
    data = jsonDecode(response.body);
    return data['data'];
  } catch (e) {
    return [];
  }
}
