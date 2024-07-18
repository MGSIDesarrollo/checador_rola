
import 'package:checador_rola/Functions/alerts.dart';
import 'package:checador_rola/Screens/informe_pasajeros.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

import '../Functions/colors.dart';
import '../Functions/functions.dart';
import '../Functions/request.dart';
import '../Helpers/database.dart';
import '../Helpers/operation.dart';
import '../Helpers/user.dart';
import 'custodias.dart';
import 'formato_cabina.dart';
import 'incidencia.dart';
import 'operations.dart';


class HomeSup extends StatefulWidget{
  final User info;
  static const routeName = '/Home_gua';

  const HomeSup({Key? key, required this.info}): super(key: key);
  @override
  _HomeSupStates createState() => _HomeSupStates();
}

class _HomeSupStates extends State<HomeSup> {

  @override
  initState(){
    syncState();
    getLocation();
    getOperations();
    super.initState();
  }

  bool? conexion;
  bool _serviceEnabled = false;
  bool loading = true;
  int _isChecked = 3;
  bool _isOperator = false;
  bool _toTerminate = false;
  List<Map<String, dynamic>>? operaciones;
  PermissionStatus _permissionGranted = PermissionStatus.granted;
  LocationData _locationData = LocationData.fromMap({});
  Location location = new Location();
  Operation? operacion;
  DateTime today = DateTime.now();

  getLocation()async{
    conexion = await isOnline(context);
    setState(() {
      conexion;
    });
    if(conexion!){
      operationReq(widget.info.operativoid.toString()).then((value) async {
        operacion = value;
        if(operacion != null){
          final dbHelper = DatabaseHelper();
          final db = await dbHelper.db;
          db.delete('tasks');
          db.insert('tasks', {'id': 1, 'pro_id': operacion!.pro_id, 'pro_name': operacion!.pro_name, 'pro_no': operacion!.pro_no, 'task_id': operacion!.task_id, 'task_name': operacion!.task_name, 'task_no': operacion!.task_no, 'cabina': operacion!.cabina, 'id_ub' : operacion!.id_ub});
        }
        setState(() {
          operacion;
        });
      });
    }else{
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> data = await db.query('tasks');
      if (data.isNotEmpty) {
        operacion = Operation.fromJSON(data.first);
      }
    }
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    setState(() {
      conexion;
      operacion;
      _isOperator = operacion != null;
    });
  }

  Widget nombre() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Column(
              children: [
                SizedBox(height: 10,),
                Text('Supervisor '+widget.info.nombres.toString(), style: TEXT_TITLE_STYLE,),
                SizedBox(height: 15,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body (){
    return  Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(child: operations(),),
          SizedBox(height: 15,),
          Text(today.toString().substring(0, 19), style: TEXT_SUBTITLE_STYLE,),
          operatorView(),
          SizedBox(width: 15,),
          ElevatedButton(
            onPressed: () async{
              Navigator.push(context, MaterialPageRoute(builder: (context) => Incidencias()),);
            },
            style: DARK_BUTTON_STYLE,
            child: Text('Incidencia', style: TEXT_BUTTON_STYLE,),
          ),
        ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      onRefresh: _refreshPage,
      child: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (operacion != null && operacion?.status != 'Terminada')
                cerrarOperacion(),
              nombre(),
              conexion == null
                  ? Center(child: CircularProgressIndicator())
                  : Center(child: _body()),
          ],),
        ],
      ),
    );
  }

  Future<void> _refreshPage() async {
    setState(() {
      conexion = null;
      loading = false;
      operaciones = [];
    });
    getLocation();
    getOperations().then((val){
      isOnline(context).then((value) {
       setState(() {
         conexion = value;
       });
      });
      setState(() {
        operaciones;
        loading = true;
      });
    });
    syncState();
  }

  getOperations() async {
    operationsReq(widget.info.id.toString()).then((value) {
      operaciones = value.cast<Map<String, dynamic>>();
      setState(() {
        operaciones;
      });
    });
  }

  Widget operations() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Text('Operaciones', textAlign: TextAlign.center, style: TEXT_SUBTITLE_STYLE),
          SizedBox(height: 5,),
          if(operaciones == null || operaciones == [] || operaciones!.isEmpty)
            emptyOperations()
          else
            for(var operacion in operaciones!)
              operation(operacion),

          if(_isOperator)
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Operación: ', style: TEXT_FIELD,),
                    Text(operacion!.pro_name.toString()+' '+ operacion!.pro_no.toString(), style: TEXT_LABEL, overflow: TextOverflow.ellipsis),
                  ],
                ),
                Text('Punto de vigilancia: ', style: TEXT_FIELD,),
                Text(operacion!.task_name.toString()+' '+operacion!.task_no.toString(), style: TEXT_LABEL, overflow: TextOverflow.ellipsis),
                SizedBox(height: 5,),
                Text('Detalles de la operación: ', style: TEXT_FIELD,),
                Text(operacion!.description ?? 'No hay', style: TEXT_LABEL,),
              ],
            ),
        ],),
    );
  }

  Widget emptyOperations() {
    return Row(children: [
      Expanded(
        child: SizedBox(
          height: 80,
          child: Container(
            margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
            decoration: BoxDecoration(color: LIGHT_BLUE_GHOST, borderRadius: BorderRadius.circular(20), border: Border.all(color: DARK_BLUE_COLOR)),
            child: Center(child: Text('No hay operaciones para asignar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
          ),
        ),
      ),
    ],);
  }

  operation(Map<String, dynamic> operacion) {
    return Row(children: [
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0), // Ajusta el valor según la cantidad de redondeo deseada
          child: Container(
            decoration: BoxDecoration(
                color: LIGHT_BLUE_GHOST,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: DARK_BLUE_GHOST, width: 2)
            ),
            margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              tileColor: LIGHT_BLUE_GHOST,
              title: Center(child: Text(operacion['title'].toString()+' '+operacion['number'].toString())),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(operacion['date'].toString()))),
                  Text(operacion['airline'].toString()),
                ],),
              onTap: ((){
                if(operacion['status'] == 'Terminada'){
                  showAlertOptionDialog(context, 'Enviar el reporte de cabina de la operacion ${operacion['title']}').then((value){
                    if(value == true){
                      reporteOperacionEmail(operacion['id']).then((response){
                        if(response == 'Exito'){
                          showToast('Reporte enviado con exito', context);
                        }else{
                          showToast('Hubo un error al enviar el reporte', context);
                        }
                      });
                    }
                  });
                }else {
                  loading
                      ? Navigator.push(context, MaterialPageRoute(builder: (context) => Operations(operacion)),)
                      : showToast('Se estan actualizando los datos, espere un momento y vuelva a intentarlo', context);
                }
              }),
            ),
          ),
        ),
      ),
    ],);
  }

  saveCheck(lat, long) async{
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.db;
    bool check = false;
    List<Map<String, dynamic>> resultados = await db.query('checkpoints', where: 'status = ?', whereArgs: [1]);
    if (operacion == null){ //Checada sin punto de vigilancia
      for (Map<String, dynamic> fila in resultados) {
        double lat1 = double.parse(fila['latitude']);
        double lon1 = double.parse(fila['longitude']);
        double dist = calcularDistancia(lat1, lon1, double.parse(lat), double.parse(long));
        if (dist <= 25){
          await db.insert('checks', {'latitude': lat, 'longitude': long, 'datetime': DateTime.now().toString().substring(0, 19), 'status': 2});
          check = true; break;
        }
      }
    }else{ //checada con punto de vigilancia
      for (Map<String, dynamic> fila in resultados) {
        if(fila['id'].toString() == operacion!.id_ub.toString()){
          double lat1 = double.parse(fila['latitude']);
          double lon1 = double.parse(fila['longitude']);
          double dist = calcularDistancia(lat1, lon1, double.parse(lat), double.parse(long));
          if (dist <= 25){
            await db.insert('checks', {'latitude': lat, 'longitude': long, 'datetime': DateTime.now().toString().substring(0, 19), 'status': 2});
            check = true; break;
          }
        }
      }
    }
    check ? showMessageDialog(context, 'Registro exitoso', '¡Checada realizada con exito!') : showMessageDialog(context, 'Registro fallido', 'No esta dentro de un rango válido');
  }

  Widget operatorView() {
    return
    Card(color: ULTRALIGHT_GREY_COLOR,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: GREY_COLOR)),
      child: Column(mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(onTap: () => setState(() {_isChecked = 0; }),
            child: Container(
              width: double.infinity,
              child: Card(
                margin: EdgeInsets.fromLTRB(5, 10, 5, 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: DARK_BLUE_GHOST)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Entrada: ', style: TEXT_TITLE_STYLE,),
                    Transform.scale(
                      scale: 1.5,
                      child: Checkbox(
                        activeColor: DARK_BLUE_COLOR,
                        value: _isChecked == 0 ? true : false,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value != null ? (value ? 0 : 3) : 3;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(onTap: () => setState(() {_isChecked = 1; }),
            child: Container(
              width: double.infinity,
              child: Card(
                margin: EdgeInsets.fromLTRB(5, 10, 5, 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: DARK_BLUE_GHOST)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Comida: ', style: TEXT_TITLE_STYLE,),
                    Transform.scale(
                      scale: 1.5,
                      child: Checkbox(
                        activeColor: DARK_BLUE_COLOR,
                        value: _isChecked == 1 ? true : false,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value != null ? (value ? 1 : 3) : 3;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(onTap: () => setState(() {_isChecked = 2; }),
            child: Container(
              width: double.infinity,
              child: Card(
                margin: EdgeInsets.fromLTRB(5, 10, 5, 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: DARK_BLUE_GHOST)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Salida: ', style: TEXT_TITLE_STYLE,),
                    Transform.scale(
                      scale: 1.5,
                      child: Checkbox(
                        activeColor: DARK_BLUE_COLOR,
                        value: _isChecked == 2 ? true : false,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value != null ? (value ? 2 : 3) : 3;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(children: [
            Expanded(
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 5,),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: DARK_BLUE_GHOST)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('Longitud: ', style: TEXT_SUBTITLE_STYLE,),
                      Text(_locationData.longitude != null ? _locationData.longitude.toString() : '...')
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: DARK_BLUE_GHOST)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('Latitud: ', style: TEXT_SUBTITLE_STYLE,),
                      Text(_locationData.latitude != null ? _locationData.latitude.toString() : '...')],
                  ),
                ),
              ),
            ),
          ],),
          SizedBox(height: 10),
          Padding(padding: EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: LIGHT_BUTTON_STYLE,
              child:  Text('Checar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: DARK_BLUE_COLOR),),
              onPressed: (){
                today = DateTime.now();
                if (_isChecked == 3) {
                  showMessageDialog(context, 'Datos insuficientes', 'Por favor verifique alguna de las casillas de checada.');
                }else{
                  getLocation().then((_) {
                    if (conexion!) {
                      print('Datos post '+ _locationData.latitude.toString()+ ' '+_locationData.longitude.toString()+' '+widget.info.id.toString()+' '+operacion.toString());
                      locationReq('${_locationData.latitude}', '${_locationData.longitude}', widget.info.id.toString(), ubi: operacion != null ? operacion!.id_ub.toString() : '').then((res) {
                        if (res == null) {
                          showMessageDialog(context, 'Alerta',
                              'Ha ocurrido un error en el servicio, contacte al area de sistemas');
                          return;
                        }
                        else if (!res) {
                          showMessageDialog(context, 'Alerta',
                              'No se ha detectado un rango válido para checar, por favor intentalo de nuevo');
                          return;
                        } else if (res) {
                          showMessageDialog(context, 'Registro exitoso', '¡Checada realizada con exito!');
                          registro_checada('${_locationData.latitude}',
                            '${_locationData.longitude}',
                            widget.info.id.toString(), _isChecked,);
                          return;
                        }
                      });
                    } else {
                      try {
                        saveCheck(_locationData.latitude.toString(),
                            _locationData.longitude.toString());
                      } catch (e) {
                        showMessageDialog(
                            context, 'Error al realizar el registro',
                            'Checada no realizada ');
                      }
                    }
                  });
                }
              },
            ),
          ),
          SizedBox(height: 5,),
          if(operacion != null)
            Center(child: ElevatedButton(style: DARK_BUTTON_STYLE,
              child:  Text('Custodia', style: TEXT_BUTTON_STYLE,),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => FormatoCustodias(operacion: operacion!, user: widget.info)),);
              },
            ),),
          if(operacion != null)
            if(operacion!.cabina == 'Si')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(style: DARK_BUTTON_STYLE,
                    child:  Text('Formato cabina', style: TEXT_BUTTON_STYLE,),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FormatoCabinas(projectid: operacion!.pro_id.toString(), operativoid: widget.info.operativoid.toString(), airline: operacion!.airline.toString())),);
                    },
                  ),
                  ElevatedButton(style: DARK_BUTTON_STYLE,
                    child:  Text('Informe Pasajeros', style: TEXT_BUTTON_STYLE,),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => InformePasajeros(operacion!.pro_id.toString(), widget.info.operativoid.toString())),);
                    },
                  ),
                ],
              ),
          SizedBox(height: 5,),
        ],
      ),
    );
  }

  Widget cerrarOperacion() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child:
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Terminar operación: ', style: TEXT_FIELD,),
                Checkbox(
                  activeColor: DARK_BLUE_COLOR,
                  value: _toTerminate,
                  onChanged: (bool? value) {
                    setState(() {
                      _toTerminate = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          if(_toTerminate)
            ElevatedButton(
                style: LIGHT_BUTTON_STYLE,
                child:  Text('Terminar misión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: DARK_BLUE_COLOR),),
                onPressed: () async{
                  if (conexion == true) {
                    terminarOperacion(operacion!.task_id.toString(), DateTime.now().toString().substring(11,19)).then((
                        value) {
                      if (value == 'Terminada') {
                        showToast('Misión terminada.', context);
                        _refreshPage();
                        setState(() {
                          operacion?.status = 'Terminada';
                        });
                      } else if (value == 'No terminada') {
                        showAlertDialog(context, 'Error',
                            'La operacion ya se había actualizado.');
                        _refreshPage();
                      }
                      else {
                        showToast('Ocurrió un error al actualizar.', context,
                            background: NOT_EXISTS);
                      }
                    });
                  }else{
                    final dbHelper = DatabaseHelper();
                    final db = await dbHelper.db;
                    db.insert('finOperacion', {'idOperacion': operacion!.pro_id, 'horaFin': DateTime.now().toString().substring(11,19), 'status': 1,});
                    showToast('Misión terminada.', context);
                  }
                }
            ),
        ],
      ),
    );
  }

  syncState() async{
    isOnline(context).then((conect) async{
    if (conect) {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.db;
      db.query('cabinas').then((response){
        for (Map<String, dynamic> row in response) {
          if(row['status'] == 1){
            newCabina(row['name'], row['enterprise'], row['startDate'], row['endDate'], widget.info.operativoid.toString(), row['details'], row['id_operation'], row['crmid'], row['no_tia'], row['motivo']).then((ans){
              db.update('cabinas', where: 'id = ?', whereArgs: [row['id']], {'status': 0,});
            });
          }
        }
      });
      db.query('custodias').then((response){
        for (Map<String, dynamic> row in response) {
          if(row['status'] == 1){
            newCustodia(row['name'], row['migration'], row['migration2'], row['nationality'], row['date']+' '+row['time'], widget.info.operativoid.toString(), row['id_operation']).then((ans){
              db.update('custodias', where: 'id = ?', whereArgs: [row['id']], {'status': 0,});
            });
          }
        }
      });
      List<Map<String, dynamic>> resultados = await db.query(
          'checks', where: 'status = ?', whereArgs: [2]);
      for (Map<String, dynamic> fila in resultados) {
        registro_checada(fila['latitude'], fila['longitude'], widget.info.id.toString(), _isChecked, date: fila['datetime']).then((res){
          db.update('checks', {'status': 1}, where: 'id = ?', whereArgs: [fila['id']]);
        });
      }
      db.query('finOperacion').then((response){
        for (Map<String, dynamic> row in response) {
          if(row['status'] == 1){
            terminarOperacion(row['idOperacion'], row['horaFin'],).then((ans){
              db.update('finOperacion', where: 'id = ?', whereArgs: [row['id']], {'status': 0,});
            });
          }
        }
      });
      db.query('informe').then((response){
        for (Map<String, dynamic> row in response) {
          if(row['status'] == 1){
            newInforme(row['id_operation'], widget.info.operativoid.toString(), row['paxEntrada'], row['paxSalida'], row['openDoors'], row['closeDoors'], row['firstPaxIn'], row['lastPaxIn'], row['firstPaxOut'], row['lastPaxOut']).then((ans){
              db.update('informe', where: 'id = ?', whereArgs: [row['id']], {'status': 0,});
            });
          }
        }
      });
    }
    });
  }
}

