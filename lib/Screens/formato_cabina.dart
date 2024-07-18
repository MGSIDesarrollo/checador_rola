import 'package:checador_rola/Functions/alerts.dart';
import 'package:checador_rola/Functions/colors.dart';
import 'package:checador_rola/Functions/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../Functions/functions.dart';
import '../Helpers/database.dart';

class FormatoCabinas extends StatefulWidget {
  final String projectid;
  final String operativoid;
  final String airline;
  const FormatoCabinas({Key? key, required this.projectid, required this.operativoid, required this.airline}): super(key: key);
  @override
  _FormatoCabinasState createState() => _FormatoCabinasState();
}

class _FormatoCabinasState extends State<FormatoCabinas> {
  bool isChecked = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController ingresante = TextEditingController();
  TextEditingController observaciones = TextEditingController();
  TextEditingController empresa = TextEditingController();
  TextEditingController no_tia = TextEditingController();
  List<Map<String, dynamic>>? registros;
  String motivo = 'Mecánico (Inspección de seguridad)';
  bool isLoading = true;
  bool isVisible = false;
  bool isEnabled = false;

  @override
  void initState() {
    getRecords();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Control de acceso', style: TEXT_BUTTON_STYLE),
          backgroundColor: DARK_BLUE_COLOR,
          foregroundColor: Colors.white,
        ),
        body: isLoading ? Center(child: CircularProgressIndicator()) : Center(child: SingleChildScrollView(child: body(),),),
      ),
    );
  }

  Widget body() {
    return registros!.isEmpty ? emptyRecords() : viewRecords();
  }

  Widget formularioCabina() {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          SizedBox(height: 20,),
          textEdit(ingresante, 'Nombre de quien ingresa'),
          SizedBox(height: 10,),
          textEdit(observaciones, 'Observaciones'),
          SizedBox(height: 10,),
          textEdit(empresa, 'Empresa'),
          SizedBox(height: 10,),
          textEdit(no_tia, 'Número TIA'),
          SizedBox(height: 10,),
          Text('Motivo', style: TEXT_FIELD, textAlign: TextAlign.center),
          Container(child:
            DropdownButton<String>(
              value: motivo,
              items: ['Mecánico (Inspección de seguridad)', 'Piloto (Inspección de seguridad)', 'No. de comisariato (Equipo uso diario)', 'Camión combustible (Equipo uso diario)',
              'Aduana (Inspección de seguridad)', 'C. aguas negras (Equipo uso diario)', 'Planta eléctrica (Equipo uso diario)', 'Planta de aire (Equipo uso diario)', 'Otro (Inspección de seguridad)', 'Otro (Equipo uso diario)'
              ].map((String moti) {
                return DropdownMenuItem<String>(
                  value: moti,
                  child: Text(moti),
                );
              }).toList(),
              onChanged: (String? newValue) async{
                setState(() {
                  motivo = newValue!;
                });
              },
            ),
          ),
          SizedBox(height: 20,),
          if (isVisible)
            ElevatedButton(
              style: DARK_BUTTON_STYLE,
              child: Text('Confirmar', style: TextStyle(color: LIGHT, fontWeight: FontWeight.w400, fontSize: 18),),
              onPressed: () async{
                if(formKey.currentState!.validate()){
                  final dbHelper = DatabaseHelper();
                  final db = await dbHelper.db;
                  db.insert('cabinas', {'id_operation': widget.projectid, 'name': ingresante.text, 'enterprise': empresa.text, 'no_tia': no_tia.text, 'motivo': motivo, 'details': observaciones.text, 'startDate': DateTime.now().toString().substring(11,19), 'endDate': '', 'visible': 1, 'status': 1, 'crmid': ''});
                  showToast('Entrada insertada', context);
                  isOnline(context).then((conn) {
                    if (conn){
                      newCabina(ingresante.text, empresa.text, DateTime.now().toString().substring(11,19), '', widget.operativoid, observaciones.text, widget.projectid, '', no_tia.text, motivo).then((val) async{
                        if (val['Response'] == 'Exito'){
                          List<Map<String, dynamic>> data = await db.query('cabinas', orderBy: 'id DESC', limit: 1,);
                          int rows = await db.update('cabinas', where: 'id = ?', whereArgs: [data.first['id']], {'status': 0, 'crmid': val['ID']});
                          showToast('Se ha registrado el ingreso, revise el fondo de la lista.', context, duration: 3);
                        } else { showToast('El ingreso no se registró, vuleva a intentarlo o contacte a soporte.', context, duration: 3); }
                      });
                    }
                  });
                  getRecords().then((value){
                    setState(() {
                      registros;
                      ingresante.clear();
                      observaciones.clear();
                      no_tia.clear();
                      empresa.clear();
                      isVisible = false;
                    });
                  });
                }
              },
            ),
        ],
      ),
    );
  }

  Widget emptyRecords() {
    return Column(
      children: [
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 80,
              child: Container(
                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                decoration: BoxDecoration(color: LIGHT_BLUE_GHOST, borderRadius: BorderRadius.circular(20), border: Border.all(color: DARK_BLUE_COLOR)),
                child: Center(child: Text('No hay registros por cerrar', style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold))),
              ),
            ),
          ),
        ],),
        formularioCabina(),
      ],
    );
  }

  Widget viewRecords() {
    return SizedBox(
      //height: 80 * (double.parse(registros!.length.toString()) ?? 1) , // Establece la altura máxima deseada
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height*.8,
          minHeight: 100, // Establece la altura mínima deseada
        ),
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(child: SingleChildScrollView(child: ingresosView(),),),
        formularioCabina(),
      ],
    )));
  }

  Widget textEdit(TextEditingController controller, String label){
    return Padding(padding: EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          setState(() {
            isVisible = ingresante.text.isNotEmpty && observaciones.text.isNotEmpty && empresa.text.isNotEmpty && no_tia.text.isNotEmpty;
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

  Future getRecords() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.db;
    List<Map<String, dynamic>> resultados = await db.query(
        'cabinas', where: 'visible = ? ', whereArgs: [1]);
    setState(() {
      registros = resultados;
      isLoading = false;
    });
  }

  ingresoView(Map<String, dynamic> registro, int position) {
    TextEditingController nameController = TextEditingController(text: registro['name'].toString());
    TextEditingController detailsController = TextEditingController(text: registro['details'].toString());
    FocusNode nameFocusNode = FocusNode();
    FocusNode detailsFocusNode = FocusNode();
    return GestureDetector(
      onLongPress: (() async{
        showAlertOptionDialog(context, 'Confirmación', content: '¿Desea registrar la salida de '+registro['name'].toString()+'?').then((value) async{
          if(value == true){
            final dbHelper = DatabaseHelper();
            final db = await dbHelper.db;
            db.update('cabinas', where: 'id = ?',
                whereArgs: [registros![position]['id'].toString()],
                {'status': 1, 'visible': 0, 'endDate': DateTime.now().toString().substring(11,19)});
            setState(() {
              getRecords();
            });
          }
        });
      }),
      onDoubleTap: ((){
        isEnabled = !isEnabled;
        setState(() {isEnabled;}); }),
      child: Card(
        color: LIGHT_BLUE_GHOST,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(controller: nameController, style: TEXT_LABEL, textAlign: TextAlign.center, cursorColor: LIGHT,
              enabled: isEnabled,
              focusNode: nameFocusNode,
              decoration: InputDecoration(hintText: 'Nombre del ingresante',
                hintStyle: TextStyle(fontSize: 15.0, color: GREY_COLOR2, fontStyle: FontStyle.italic,), border: InputBorder.none,),
              onEditingComplete: () {
                showAlertOptionDialog(context, 'Confirmacion', content: '¿Desea actualizar este campo?' ).then((value) async{
                  if (value == true){
                    final dbHelper = DatabaseHelper();
                    final db = await dbHelper.db;
                    db.update('cabinas', where: 'id = ?',
                        whereArgs: [registros![position]['id']],
                        {'status': 1, 'name': nameController.text}).then((value) async{
                      await getRecords();
                    });
  
                  }
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Empresa: ', style: TEXT_FIELD),
                Text(registro['enterprise'].toString(), style: TEXT_LABEL),
                Text('Ingreso: ', style: TEXT_FIELD),
                Text(registro['startDate'].toString(), style: TEXT_LABEL),
              ],
            ),
            Text('Observaciones: ', style: TEXT_FIELD),
            TextField(controller: detailsController, style: TEXT_LABEL, textAlign: TextAlign.center, cursorColor: LIGHT,
              enabled: isEnabled,
              focusNode: detailsFocusNode,
              decoration: InputDecoration(hintText: 'Detalles del ingreso',
                hintStyle: TextStyle(fontSize: 15.0, color: GREY_COLOR2, fontStyle: FontStyle.italic,), border: InputBorder.none,),
              onEditingComplete: () {
                showAlertOptionDialog(context, 'Confirmacion', content: '¿Desea actualizar este campo?' ).then((value) async{
                  if (value == true){
                    final dbHelper = DatabaseHelper();
                    final db = await dbHelper.db;
                    db.update('cabinas', where: 'id = ?',
                        whereArgs: [registros![position]['id']],
                        {'status': 1, 'details': detailsController.text}).then((value) async{
                      await getRecords();
                    });

                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  ingresosView() {
    return Column(children: [
      for(int i=0 ; i< registros!.length ; i++)
        ingresoView(registros![i], i),
    ],);
  }
}
