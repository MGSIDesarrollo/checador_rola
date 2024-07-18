import 'dart:convert';

import 'package:checador_rola/Functions/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../Functions/alerts.dart';
import '../Functions/functions.dart';
import '../Functions/request.dart';
import '../Helpers/operator.dart';
import '../Helpers/ubications.dart';

class Operations extends StatefulWidget{
  static const routeName = '/Operations';

  Map<String, dynamic> operacion;
  Operations(this.operacion, {Key? key}): super(key: key);
  @override
  _OperationsStates createState() => _OperationsStates();
}

class _OperationsStates extends State<Operations> {

  final ScrollController _scrollController = ScrollController();
  bool _serviceEnabled = false;
  Location location = new Location();
  PermissionStatus _permissionGranted = PermissionStatus.granted;
  LocationData _locationData = LocationData.fromMap({});
  List<Operator> seleccion = [];
  List<MultiSelectItem<Operator>> _items = [];
  List<Ubicacion> listUbi = [];
  Ubicacion? ubi;
  bool conexion = false;
  bool load = true;
  bool enabledButton = false;
  bool _isVisible = false;

  @override
  void initState() {
    _refreshPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Operación'),
        backgroundColor: DARK_BLUE_COLOR,
      ),
      body: load
          ? Center(child: CircularProgressIndicator())
          : conexion
            ? body()
            : Center(child: Text('Sin conexion')),
    );
  }

  Widget body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 15,),
        Text(widget.operacion['title']+' '+widget.operacion['number'].toString(), style: TEXT_TITLE_STYLE),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(children: [
              Row(
                children: [
                  Text('Estatus: ', style: TEXT_FIELD),
                  Text(widget.operacion['status'], style: TEXT_LABEL),
                ],),
              Row(
                children: [
                  Text('Aerolinea: ', style: TEXT_FIELD),
                  Text(widget.operacion['airline'], style: TEXT_LABEL),
                ],),
            ],),
            Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.operacion['date'])), style: TextStyle(fontSize: 20)),
          ],
        ),
        SizedBox(height: 10,),
        puntosVigilancia(),
        SizedBox(height: 10,),
        buttons(jsonEncode(widget.operacion), (widget.operacion.length-6).toString()),
        SizedBox(height: 10,),
      ],
    );
  }

  puntosVigilancia() {
    return Flexible(
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for(int i=0 ; i< widget.operacion.length-6 ; i++)
              if(widget.operacion['$i'] != '')
              checkPoints(widget.operacion['$i'], '$i')
          ],
        ),
      ),
    );
  }

  Widget checkPoints(Map<String, dynamic> point, position) {
    TextEditingController textPoint = TextEditingController(text: point['ubicacion'].toString());
    List<int> asignados=[];
    for(int i=0; i<4 ;i++){
      if(point['op$i'] != '' && point['op$i'] != null){
        asignados.add(int.parse(point['op$i'].toString()));
      }
    }
    List<Operator> asignados_view = seleccion
        .where((operador) {
         return asignados.contains(operador.id);
        })
        .toList();
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
          decoration: BoxDecoration(
            color: LIGHT_BLUE_GHOST,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: DARK_BLUE_GHOST, width: 2)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 5,),
              Center(
                child: TextFormField(controller: textPoint, style: TEXT_SUBTITLE_STYLE, textAlign: TextAlign.center, cursorColor: LIGHT,
                  decoration: InputDecoration(hintText: 'Nombre del punto',
                    hintStyle: TextStyle(fontSize: 18.0, color: GREY_COLOR2, fontStyle: FontStyle.italic,), border: InputBorder.none,),
                  onChanged: ((value){
                    widget.operacion['$position']['ubicacion'] = value;
                  }),
                ),
              ),
              SizedBox(height: 5,),
              if (point.containsKey('lat'))
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(children: [
                      Text('Latitud: ', style: TEXT_FIELD),
                      Text(point['lat'].toString(), style: TEXT_LABEL),
                    ],),
                    Row(children: [
                      Text('Longitud: ', style: TEXT_FIELD),
                      Text(point['lon'].toString(), style: TEXT_LABEL),
                    ],),
                  ],
                ),
              SizedBox(height: 5,),
              selectOperators(point['task_id'].toString(), position, asignados_view),
            ],
          ),
        ),
        if (point['task_id'] == '0')
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: ((){
                widget.operacion[position] = '';
                setState(() {
                  widget.operacion;
                });
              }),
              child:
              Icon(
                Icons.close,
                color: Colors.black,
                size: 32.0,
              ),
            ),
          ),
        if (point['task_no'] != '0')
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: (() async{
                await getLocation();
                showAlertOptionDialog(context, '¿Desea actualizar las coordenadas de este punto?', content: point['task_name'].toString()).then((value) {
                  if (value == true){
                    widget.operacion['$position']['lat'] = _locationData.latitude;
                    widget.operacion['$position']['lon'] = _locationData.longitude;
                    setState(() {
                      showToast('Coordenadas actualizadas', context);
                      widget.operacion;
                    });
                  }
                });
              }),
              child:
              Icon(
                Icons.pin_drop,
                color: Colors.black,
                size: 32.0,
              ),
            ),
          ),
      ],);
  }

  Widget selectOperators (String task_id, String operacion, List<Operator> asignados_view){
    final _multiSelectKey = GlobalKey<FormFieldState>();
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          MultiSelectDialogField(
            key: _multiSelectKey,
            items: _items,
            title: Text("Operativos"),
            selectedColor: DARK_BLUE_GHOST,
            initialValue: asignados_view,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.all(Radius.circular(40)),
              border: Border.all(
                color: DARK_BLUE_GHOST,
                width: 2,
              ),
            ),
            buttonIcon: Icon(
              Icons.people,
              color: DARK_BLUE_COLOR,
            ),
            buttonText: Text(
              "Seleccionar operativos",
              style: TextStyle(
                color: DARK_BLUE_COLOR,
                fontSize: 16,
              ),
            ),
            chipDisplay: MultiSelectChipDisplay(
              chipColor: Colors.white,
              textStyle: TextStyle(color: DARK_BLUE_COLOR),
            ),
            onConfirm: (results) async {
              print('Resultados '+results.toString());
             if(results.length <= 4) {
                List<int> now_ids = [];
                List<String> now_names = [];
                setState(() {
                  _isVisible = false;
                });
                List<Map<String, dynamic>> tasks_ids = [];//tasks_ids son todos los operativos que ya tienen un punto asignado
                for (int i=0; i<4; i++) {
                  if(results.length>i) {
                    now_ids.add(results[i].id); //Now ids son los elementos seleccionados en este momento
                    now_names.add(results[i].name);
                  }else{
                    now_ids.add(0); //Now ids son los elementos seleccionados en este momento
                    now_names.add('');
                  }
                }
                for (int i = 0; i < widget.operacion.length - 6; i++) {
                  for(int j = 1; j <= 4; j++) {
                    print('Datos '+widget.operacion['$i']['op$j'].toString());
                    widget.operacion['$i']['op$j'] == ''
                      ? ()
                      : tasks_ids.add({'abs_pos': i.toString(), 'task_id': widget.operacion['$i']['task_id'], 'task_name': widget.operacion['$i']['task_name'], 'op_id': int.parse(widget.operacion['$i']['op$j'].toString()), 'position': '$j'});
                  }
                }
                for(int i=0; i<now_ids.length ;i++){ //recorremos los operadores que se quieren agregar para verificar que no existen en otra tarea
                  if(tasks_ids.length == 0){
                    print(widget.operacion[operacion]['op${i+1}']);
                    widget.operacion[operacion]['op${i+1}'] = now_ids[i];
                    print('añadido '+widget.operacion.toString() );
                    setState(() {
                      widget.operacion;
                      _refreshPage();
                    });
                  }else {
                    for (int j = 0; j < tasks_ids
                        .length; j++) { // comparamos cada id con cada uno de los ya asignados
                      print('1');
                      if (now_ids[i] != 0 && (now_ids[i].toString() ==
                          tasks_ids[j]['op_id'].toString() &&
                          task_id.toString() != tasks_ids[j]['task_id']
                              .toString())) { //se envia un alert de confirmacion de cambio de punto
                        showAlertOptionDialog(context, 'Advertencia',
                            content: 'El operador ${now_names[i]
                                .toString()} ya esta asignado al punto '
                                '${tasks_ids[j]['task_name']
                                .toString()}.\n ¿Desea cambiar al operador de punto?')
                            .then((flag) {
                          print('2');
                          if (flag == true) {
                            for (int k = 1; k < 5; k++) {
                              if (widget
                                  .operacion['${tasks_ids[j]['abs_pos']}']['op${k}']
                                  .toString() == now_ids[i].toString()) {
                                widget
                                    .operacion['${tasks_ids[j]['abs_pos']}']['op${k}'] =
                                0;
                                widget.operacion[operacion]['op${i + 1}'] =
                                now_ids[i];
                                tasks_ids.removeAt(j);
                              }
                            }
                          } else {
                            tasks_ids.removeAt(j);
                            results.removeAt(i);
                            tasks_ids = [];
                            for (int i = 0; i <
                                widget.operacion.length - 6; i++) {
                              for (int j = 1; j <= 4; j++) {
                                widget.operacion['$i']['op$j'] == ''
                                    ? ()
                                    : tasks_ids.add({
                                  'abs_pos': i.toString(),
                                  'task_id': widget.operacion['$i']['task_id'],
                                  'task_name': widget
                                      .operacion['$i']['task_name'],
                                  'op_id': int.parse(
                                      widget.operacion['$i']['op$j']
                                          .toString()),
                                  'position': '$j'
                                });
                              }
                            }
                          }
                          setState(() {
                            widget.operacion;
                          });
                        });
                      } else { //Aqui se agrega el id del operador a la tarea cuando no esta en ningun otro punto
                        print('añadiendo');
                        print(now_ids.toString()+' $i');
                        widget.operacion[operacion]['op${i + 1}'] = now_ids[i];
                        print('añadido ' + widget.operacion.toString());
                        setState(() {
                          widget.operacion;
                          _refreshPage();
                        });
                      }
                    }
                  }
                }
                tasks_ids = [];
                for (int i = 0; i < widget.operacion.length - 6; i++) {
                  for(int j = 1; j <= 4; j++) {
                    widget.operacion['$i']['op$j'] == ''
                        ? ()
                        : tasks_ids.add({'abs_pos': i.toString(), 'task_id': widget.operacion['$i']['task_id'], 'task_name': widget.operacion['$i']['task_name'], 'op_id': int.parse(widget.operacion['$i']['op$j'].toString()), 'position': '$j'});
                  }
                }
              }else{
                showAlertDialog(context, 'Error', 'Solo pueden asignarse hasta 4 operativos por punto de vigilancia');
              }
            },
          ),
          if (asignados_view != [] &&asignados_view.isNotEmpty)
            selectCabina(asignados_view, operacion),
        ],
      ),
    );
  }

  Widget selectCabina(List<Operator> options, String operacion) {
    List<MultiSelectItem<Operator>> elements = options.map((operator) => MultiSelectItem<Operator>(operator, operator.name)).toList();
    final _multiSelectKey = GlobalKey<FormFieldState>();
    List<int> asignados=[];
    if(widget.operacion[operacion]['cabina'] != '' && widget.operacion[operacion]['cabina'] != null){
        asignados.add(int.parse(widget.operacion[operacion]['cabina'].toString()));
    }

    List<Operator> cabina_view = seleccion
        .where((operador) {
      return asignados.contains(operador.id);
    })
        .toList();
    return MultiSelectDialogField(
      key: _multiSelectKey,
      items: elements,
      separateSelectedItems: true,
      title: Text("Operativo de cabina"),
      selectedColor: DARK_BLUE_GHOST,
      initialValue: cabina_view,
      decoration: BoxDecoration(
        color: DARK_BLUE_GHOST,
        borderRadius: BorderRadius.all(Radius.circular(40)),
        border: Border.all(
          color: LIGHT,
          width: 2,
        ),
      ),
      buttonIcon: Icon(
        Icons.people,
        color: LIGHT,
      ),
      buttonText: Text(
        "Seleccionar operativo de cabina",
        style: TextStyle(
          color: LIGHT,
          fontSize: 16,
        ),
      ),
      chipDisplay: MultiSelectChipDisplay(
        chipColor: DARK_BLUE_COLOR,
        textStyle: TextStyle(color: LIGHT),
      ),
      onConfirm: (List results) async {
        if(results.length <= 4) {
            widget.operacion[operacion]['cabina'] = results[0].id;
        }else{
          showAlertDialog(context, 'Error', 'Solo puede asignarse 1 operativo de cabina por punto de vigilancia');
        }
      },
    );
  }

  Widget buttons(String json, String iter) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                enabledButton ? selectUbi() : null;
              },
              style: DARK_BUTTON_STYLE,
              child: Text('Agregar punto'),
            ),
          ],),
          if(_isVisible)
            ElevatedButton(
              onPressed: () async{
                setState(() {
                  widget.operacion;
                });
                print('Data ' +widget.operacion.toString());
                upPoint(jsonEncode(widget.operacion), iter).then((value) async{
                  if (value == null){ showToast('Error al guardar la operacion', context);}
                  if (value == 'Exito'){showToast('Operacion actualizada', context);}
                  if (value == 'Duplicado'){showToast('Alguno de los puntos tiene un nombre que ya existe', context);}
                });
              },
            style: LIGHT_BUTTON_STYLE,
            child: Text('Guardar cambios', style: TextStyle(color: DARK_BLUE_COLOR, fontWeight: FontWeight.w600, fontSize: 18)),
          ),
      ],
    );
  }

  void selectUbi() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccione la ubicación a agregar.'),
          content: DropdownButton<Ubicacion>(
            value: listUbi.last,
            items: listUbi.map((Ubicacion ubicacion) {
              return DropdownMenuItem<Ubicacion>(
                value: ubicacion,
                child: Text(ubicacion.name),
              );
            }).toList(),
            onChanged: (Ubicacion? newValue) async{
              Navigator.of(context).pop();
              showToast('Por favor espere...', context, duration: 2);
              setState(() {
                _isVisible = false;
              });
              await getLocation();
                ubi = newValue;
                Map<String, dynamic> newpoint = {};
                if (ubi!.name == 'Nueva'){
                  newpoint = {'task_id': '0', 'task_name': '', 'task_no': '0', 'ubicacion': '', 'op1': 0, 'op2': 0, 'op3': 0, 'op4': 0, 'cabina': 0, 'lat': _locationData.latitude, 'lon':_locationData.longitude};
                  widget.operacion['${widget.operacion.length - 6}'] = newpoint;
                  widget.operacion;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  });
                  showToast('Punto añadido', context);
                  ubi = listUbi.last;
                }else{
                  newpoint = {'task_id': '0', 'task_name': widget.operacion['title']+ubi!.name, 'task_no': '0', 'ubicacion': ubi!.name.toString(), 'id_ubi': ubi!.id.toString(), 'op1': 0, 'op2': 0, 'op3': 0, 'op4': 0, 'cabina': 0,};
                  widget.operacion['${widget.operacion.length - 6}'] = newpoint;
                  widget.operacion;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  });
                  showToast('Punto añadido', context);
                  ubi = listUbi.last;
                }
              _refreshPage();
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  getData() async {
    reqUbis().then((value) {
      listUbi = value.map((item) {
        return Ubicacion(
          id: int.parse(item['id']),
          name: item['name'],
        );
      }).toList();
      setState(() {
        listUbi.add(Ubicacion(id: 0, name: 'Nueva'));
        listUbi;
        enabledButton = true;
      });
    });
    operatorsReq().then((value) {
      seleccion = value.map((item) {
        return Operator(
          id: int.parse(item['id']),
          contactid: int.parse(item['contactid']),
          name: item['name'],
        );
      }).toList();
      setState(() {
        seleccion;
        _items = seleccion.map((operator) => MultiSelectItem<Operator>(operator, operator.name)).toList();
        load = false;
      });
    });
  }

  getLocation() async{
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
    _locationData = await location.getLocation();
    setState(() {
      conexion;
    });
  }

  _refreshPage() async {
    await getLocation();
    await getData();

      int total = widget.operacion.length - 7;
      int completas = -1;
      bool flag = false;
      for (int i = 0; i <= total; i++) {
        for(int j = 1; j <= 4; j++) {
          if (widget.operacion['$i']['op$j'] != '' && widget.operacion['$i']['op$j'] != 0){
            flag = true;
          }
        }
        if(flag){
          completas++; flag = false;
        }
      }
      setState(() {
        _isVisible = total == completas;
        widget.operacion;
    });
  }
}