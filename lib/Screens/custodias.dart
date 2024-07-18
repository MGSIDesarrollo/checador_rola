import 'package:checador_rola/Functions/alerts.dart';
import 'package:checador_rola/Functions/colors.dart';
import 'package:checador_rola/Functions/request.dart';
import 'package:checador_rola/Helpers/operation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../Functions/functions.dart';
import '../Helpers/database.dart';
import '../Helpers/user.dart';

class FormatoCustodias extends StatefulWidget {
  final Operation operacion;
  final User user;
  const FormatoCustodias({Key? key, required this.operacion, required this.user}): super(key: key);
  @override
  _FormatoCustodiasState createState() => _FormatoCustodiasState();
}

class _FormatoCustodiasState extends State<FormatoCustodias> {
  bool isChecked = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController pasajero = TextEditingController();
  TextEditingController nacionalidad = TextEditingController();
  TextEditingController migracion = TextEditingController();
  TextEditingController migracion2 = TextEditingController();
  List<Map<String, dynamic>>? registros;
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Custodias', style: TEXT_BUTTON_STYLE,),
          backgroundColor: DARK_BLUE_COLOR,
          foregroundColor: Colors.white,
        ),
        body: body(),
      ),
    );
  }
  Widget body() {
    return Center(child: formularioCustodias());
  }

  Widget formularioCustodias() {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          SizedBox(height: 20,),
          textEdit(pasajero, 'Nombre del pasajero'),
          SizedBox(height: 10,),
          textEdit(nacionalidad, 'Nacionalidad'),
          SizedBox(height: 10,),
          textEdit(migracion, 'Personal de migración traslada custodia'),
          SizedBox(height: 10,),
          textEdit(migracion2, 'Personal de migración traslada custodia'),
          SizedBox(height: 20,),
          if (isVisible)
            ElevatedButton(
              style: DARK_BUTTON_STYLE,
              child: Text('Confirmar', style: TextStyle(color: LIGHT, fontWeight: FontWeight.w400, fontSize: 18),),
              onPressed: () async{
                if(formKey.currentState!.validate()){
                  final dbHelper = DatabaseHelper();
                  final db = await dbHelper.db;
                  //el id de la operacion se cambio por el de la tarea/punto de checada
                  db.insert('custodias', {'id_operation': widget.operacion.task_id, 'name': pasajero.text, 'nationality': nacionalidad.text, 'migration': migracion.text, 'migration2': migracion2.text, 'date': DateTime.now().toString().substring(0, 10), 'time': DateTime.now().toString().substring(11, 19), 'status': 1});
                  print('antes');
                  print(pasajero.text.toString()+' aqui');
                  showToast('Custodia guardada', context);
                  db.query('custodias').then((value){
                  });
                  setState(() {
                    registros;
                    pasajero.clear();
                    nacionalidad.clear();
                    migracion.clear();
                    migracion2.clear();
                    isVisible = false;
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
        controller: controller,
        onChanged: (value) {
          setState(() {
            isVisible = pasajero.text.isNotEmpty && nacionalidad.text.isNotEmpty;
          });
        },
        decoration: InputDecoration(
          labelStyle: TextStyle(color: LIGHT_BLUE_GHOST, fontStyle: FontStyle.italic),
          focusedBorder: LIGHT_INPUT_STYLE,
          enabledBorder: LIGHT_INPUT_STYLE,
          labelText: label,
        ),
      ),
    );
  }

}
