import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../Functions/alerts.dart';
import '../Functions/colors.dart';
import '../Functions/functions.dart';
import '../Functions/request.dart';
import '../Helpers/user.dart';

class HomeOfi extends StatefulWidget{
  final User info;
  static const routeName = '/Home_ofi';

  const HomeOfi( {Key? key, required this.info}): super(key: key);
  @override
  _HomeOfiStates createState() => _HomeOfiStates();
}//fin clase home

class _HomeOfiStates extends State<HomeOfi> {

  @override
  initState(){
    getLocation();
    super.initState();
  }
  bool? conexion;
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.granted;
  LocationData _locationData = LocationData.fromMap({});
  Location location = new Location();
  final _formKey1 = GlobalKey<FormState>();
  DateTime today = DateTime.now();
  int _isChecked = 3;

  getLocation()async{
    conexion = await isOnline(context);
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
    try {
      _locationData = await location.getLocation();
      //print('locacion obtenida '+_locationData.toString());
      //print('Latitud: ${_locationData.latitude}, Longitud: ${_locationData.longitude}');
    } catch (e) {
      print('Error al obtener la ubicación: $e');
    }
    //_locationData = await location.getLocation();
    setState(() {
      conexion;
    });
  }

  Widget nombre() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Column(
              children: [
                //Text('Bievenido: ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                Text(widget.info.nombres.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                SizedBox(height: 15,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body (){
    return checador();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshPage,
      child: ListView(
        children: <Widget>[
          nombre(),
          Text(today.toString().substring(0, 19), style: TEXT_SUBTITLE_STYLE,),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: GREY_COLOR)),
            color: ULTRALIGHT_GREY_COLOR,
            child: _body(),),],
      ),
    );
  }

  Future<void> _refreshPage() async {
    await getLocation(); // Actualiza la ubicación
    setState(() {
      checador();
    });
  }

  Widget checador(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Form(
          key: _formKey1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
              Container(
                width: double.infinity,
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: DARK_BLUE_GHOST)),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('Longitud: ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                        Text(_locationData.longitude != null ? _locationData.longitude.toString() : '...')
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: DARK_BLUE_GHOST)),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('Latitud: ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                        Text(_locationData.latitude != null ? _locationData.latitude.toString() : '...')],
                    ),
                  ),
                ),
              ),
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
                          locationReq('${_locationData.latitude}',
                              '${_locationData.longitude}',
                              widget.info.id.toString()).then((res) {
                            if (res == null) {
                              showMessageDialog(context, 'Alerta',
                                  'Ha ocurrido un error en el servicio, contacte al area de sistemas');
                              return;
                            }
                            else if (!res) {
                              showMessageDialog(context, 'Alerta',
                                  'No se ha detectado un rango válido para checar, por favor intentalo de nuevo');
                              //registro_checada('${_locationData.latitude}', '${_locationData.longitude}', _arguments['datos'].id.toString());
                              return;
                            } else if (res) {
                              showMessageDialog(context, 'Registro exitoso',
                                  '¡Checada realizada con exito!');
                              registro_checada('${_locationData.latitude}',
                                  '${_locationData.longitude}',
                                  widget.info.id.toString(), _isChecked);
                              return;
                            }
                          });
                        } else
                          showToast(
                              'Necesitas conexión para realizar tu checada.',
                              context);
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 10,),
            ],
          ),
        ),
      ],
    );
  }
}
