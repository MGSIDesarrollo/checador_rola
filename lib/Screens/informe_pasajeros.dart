import 'package:checador_rola/Functions/alerts.dart';
import 'package:checador_rola/Functions/colors.dart';
import 'package:checador_rola/Functions/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../Functions/functions.dart';
import '../Helpers/database.dart';

class InformePasajeros extends StatefulWidget {
  final String projectid;
  final String operativoid;
  const InformePasajeros(this.projectid, this.operativoid, {Key? key,}): super(key: key);
  @override
  _InformePasajerosState createState() => _InformePasajerosState();
}

class _InformePasajerosState extends State<InformePasajeros> {
  bool isChecked = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController paxEntrada = TextEditingController();
  TextEditingController paxSalida = TextEditingController();
  TimeOfDay openDoors = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay closeDoors = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay firstPaxIn = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay lastPaxIn = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay firstPaxOut = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay lastPaxOut = TimeOfDay(hour: 0, minute: 0);
  bool isLoading = true;
  bool isVisible = false;
  bool isEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Control de acceso'),
          backgroundColor: DARK_BLUE_COLOR,
        ),
        body: Center(child: SingleChildScrollView(child: formularioInforme(),),),
      ),
    );
  }

  Widget formularioInforme() {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          SizedBox(height: 5,),
          Text(
            'Apertura de puertas: ${openDoors.format(context) ?? ''}',
            style: TEXT_SUBTITLE_STYLE,
          ),
          selectTime(openDoors, (newTime) {
            setState(() {
              openDoors = newTime;
            });}),
          SizedBox(height: 5,),
          Text(
            'Apertura de puertas: ${closeDoors.format(context) ?? ''}',
            style: TEXT_SUBTITLE_STYLE,
          ),
          selectTime(closeDoors, (newTime) {
            setState(() {
              closeDoors = newTime;
            });}),
          SizedBox(height: 5,),
          Text(
            'Apertura de puertas: ${firstPaxIn.format(context) ?? ''}',
            style: TEXT_SUBTITLE_STYLE,
          ),
          selectTime(firstPaxIn, (newTime) {
            setState(() {
              firstPaxIn = newTime;
            });}),
          SizedBox(height: 5,),
          Text(
            'Apertura de puertas: ${lastPaxIn.format(context) ?? ''}',
            style: TEXT_SUBTITLE_STYLE,
          ),
          selectTime(lastPaxIn, (newTime) {
            setState(() {
              lastPaxIn = newTime;
            });}),
          SizedBox(height: 5,),
          Text(
            'Apertura de puertas: ${firstPaxOut.format(context) ?? ''}',
            style: TEXT_SUBTITLE_STYLE,
          ),
          selectTime(firstPaxOut, (newTime) {
          setState(() {
          firstPaxOut = newTime;
          });}),
          SizedBox(height: 5,),
          Text(
            'Apertura de puertas: ${lastPaxOut.format(context) ?? ''}',
            style: TEXT_SUBTITLE_STYLE,
          ),
          selectTime(lastPaxOut,(newTime) {
          setState(() {
            lastPaxOut = newTime;
          });}),
          SizedBox(height: 20,),
          textEdit(paxEntrada, 'Total pax de llegada'),
          SizedBox(height: 10,),
          textEdit(paxSalida, 'Total pax salida'),
          SizedBox(height: 20,),

            ElevatedButton(
              style: DARK_BUTTON_STYLE,
              child: Text('Confirmar', style: TextStyle(color: LIGHT, fontWeight: FontWeight.w400, fontSize: 18),),
              onPressed: () async{
                if(formKey.currentState!.validate()){
                  final dbHelper = DatabaseHelper();
                  final db = await dbHelper.db;
                  db.insert('informe', {'id_operation': widget.projectid, 'paxEntrada':paxEntrada.text, 'paxSalida':paxSalida.text, 'openDoors':openDoors.format(context), 'closeDoors':closeDoors.format(context), 'firstPaxIn':firstPaxIn.format(context), 'lastPaxIn':lastPaxIn.format(context), 'firstPaxOut':firstPaxOut.format(context), 'lastPaxOut':lastPaxOut.format(context),'status': 1,});
                  isOnline(context).then((conn) {
                    if (conn){
                      newInforme(widget.projectid, widget.operativoid, paxEntrada.text, paxSalida.text, openDoors.format(context), closeDoors.format(context), firstPaxIn.format(context), lastPaxIn.format(context), firstPaxOut.format(context), lastPaxOut.format(context)).then((val) async{
                        print('Respuesta '+val.toString());
                        if (val == 'Exito'){
                          showToast('Se ha registrado el informe, revise el fondo de la lista.', context, duration: 3);
                        } else { showToast('El informe no se registró, vuleva a intentarlo o contacte a soporte.', context, duration: 3); }
                      });
                    }
                  });
                }
              },
            ),
        ],
      ),
    );
  }

  Widget textEdit(TextEditingController controller, String label){
    return Padding(padding: EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: controller,
        decoration: InputDecoration(
          labelStyle: TextStyle(color: LIGHT_BLUE_GHOST, fontStyle: FontStyle.italic),
          focusedBorder: LIGHT_INPUT_STYLE,
          enabledBorder: LIGHT_INPUT_STYLE,
          labelText: label,
        ),
      ),
    );
  }

  Widget selectTime(TimeOfDay time, Function(TimeOfDay) onSelectTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          'Hora de salida: ${time.format(context) ?? ''}',
          style: TEXT_SUBTITLE_STYLE,
        ),
        SizedBox(width: 10,),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: DARK_BLUE_COLOR,
            textStyle: TEXT_BUTTON_STYLE,
          ),
          onPressed: () => _selectStartTime(context, time, onSelectTime),
          child: Text('Cambiar hora'),
        ),
      ],
    );
  }

  void _selectStartTime(BuildContext context, TimeOfDay initialTime, Function(TimeOfDay) onSelectTime) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      onSelectTime(selectedTime);
    }
  }
}
