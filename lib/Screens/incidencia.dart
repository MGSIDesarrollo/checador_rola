import 'package:checador_rola/Functions/alerts.dart';
import 'package:checador_rola/Functions/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Functions/functions.dart';
import '../Functions/request.dart';
import '../Helpers/operator.dart';

class Incidencias extends StatefulWidget{
  static const routeName = '/Incidencia';

  Incidencias({Key? key}): super(key: key);
  @override
  _IncidenciasStates createState() => _IncidenciasStates();
}

class _IncidenciasStates extends State<Incidencias> {

  final ScrollController _scrollController = ScrollController();
  bool _serviceEnabled = false;
  List<Operator> seleccion = [];
  List incidencias = [];
  String selectedValue = '';
  Operator? selectedOperator;
  Map<String, dynamic>? punto;
  bool conexion = false;
  bool load = true;
  TimeOfDay? startTime;
  TimeOfDay? endTime = TimeOfDay.now();
  TextEditingController motivo = TextEditingController();

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permiso', style: TEXT_BUTTON_STYLE,),
        backgroundColor: DARK_BLUE_COLOR,
        foregroundColor: Colors.white,
      ),
      body: load
          ? Center(child: CircularProgressIndicator())
          : conexion
          ? body()
          : Center(child: Text('Sin conexion')),
    );
  }

  Widget body() {
    selectedOperator = selectedOperator ?? seleccion[0];
    List<String> optionsOp = [];
    seleccion.forEach((element) {optionsOp.add(element.name);});

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 15,),
          Text('Operador', style: TEXT_SUBTITLE_STYLE,),
          SizedBox(height: 10,),
          DropdownButton<Operator>(
            value: selectedOperator,
            items: seleccion.map((Operator value) {
              return DropdownMenuItem<Operator>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
            onChanged: (Operator? newValue) async {
              setState(() {
                selectedOperator = newValue;
              });},
          ),
          SizedBox(height: 10,),
          Text(
            'Hora de llegada: ${startTime?.format(context) ?? ''}',
            style: TEXT_SUBTITLE_STYLE,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DARK_BLUE_COLOR,
            ),
            onPressed: () => _selectStartTime(context),
            child: Text('Cambiar hora', style: TEXT_BUTTON_STYLE,),
          ),
          SizedBox(height: 20),
          Text(
            'Hora de salida: ${endTime?.format(context) ?? ''}',
            style: TEXT_SUBTITLE_STYLE,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _selectEndTime(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: DARK_BLUE_COLOR,
            ),
            child: Text('Cambiar hora', style: TEXT_BUTTON_STYLE,),
          ),
          SizedBox(height: 20),
          Text('Motivo del permiso',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: TextFormField(
              maxLines: 5,
              controller: motivo,
              style: TEXT_SUBTITLE_STYLE,
              decoration: InputDecoration(
                hintText: 'Describa el motivo por el que se da el permiso',
                hintStyle: TextStyle(fontSize: 18.0, color: GREY_COLOR2, fontStyle: FontStyle.italic,),
                labelText: 'Situación',
                border: InputBorder.none,
                focusColor: DARK_BLUE_COLOR,
                labelStyle: DARK_TEXT_LABEL,
                counterStyle: TEXT_SUBTITLE_STYLE,
                alignLabelWithHint: true,
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: (() async {
              showToast('Por favor espere...', context);
              var response = await new_incidencia(selectedOperator!.contactid.toString(), formatTime(startTime??TimeOfDay(hour: 0, minute: 0))+':00', formatTime(endTime??TimeOfDay(hour: 0, minute: 0))+':00', motivo.text);
              if (response == 'Exito'){
                Navigator.pop(context);
                showAlertDialog(context, 'Exito', 'Se ha creado la incidencia correctamente.');
              }else{
                showAlertDialog(context, 'Error', 'Ha ocurrido un error al crear la incidencia.');
              }
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: DARK_BLUE_COLOR,
            ),
            child: Text('Guardar', style: TEXT_BUTTON_STYLE,),
          ),
        ],
      ),
    );
  }

  getData() async {
    conexion = await isOnline(context);
    //consultar los tipos de incidencias
    incidencias = await incidenciasReq();
    operatorsReq().then((value) {
      seleccion = value.map((item) {
        return Operator(
          id: int.parse(item['id']),
          contactid: int.parse(item['contactid']),
          name: item['name'],
        );
      }).toList();
      setState(() {
        incidencias;
        seleccion;
        load = false;
      });
    });
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay(hour: 0, minute: 0),
    );

    if (picked != null && picked != startTime) {
      setState(() {
        startTime = picked;
        endTime = null;
      });
    }
  }
  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endTime ?? TimeOfDay(hour: 0, minute: 0),
    );

    if (picked != null && picked != endTime) {
      setState(() {
        endTime = picked;
        startTime = null;
      });
    }
  }

  String formatTime(TimeOfDay time, {int hoursToAdd = 0}) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Sumar o restar horas y minutos según los parámetros
    final modifiedDateTime = dateTime.add(Duration(
      hours: hoursToAdd,
    ));

    final formatter = DateFormat.Hm(); // 'H' para formato de 24 horas
    return formatter.format(modifiedDateTime);
  }
}