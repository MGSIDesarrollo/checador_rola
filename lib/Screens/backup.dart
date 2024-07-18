import 'package:checador_rola/Functions/colors.dart';
import 'package:flutter/material.dart';
import '../Functions/request.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class Operations extends StatefulWidget{
  static const routeName = '/Operations';

  const Operations(Map<String, dynamic>? operacion, {Key? key}): super(key: key);
  @override
  _OperationsStates createState() => _OperationsStates();
}

class _OperationsStates extends State<Operations> {

  @override
  initState(){
    getData();
    super.initState();
  }
  bool? conexion;
  int limite = 4;
  List<Map<String, dynamic>> asignados = [];
  List<Map<String, dynamic>> seleccion = [];
  var _items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Operacion'),
          backgroundColor: DARK_BLUE_COLOR),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 5,),
            Text(
              'Operadores asignados:',
            ),
            if (asignados.isNotEmpty)
              operadoresAsignados(),
            if(asignados.isEmpty)
              asignadosEmpty(),
            SizedBox(height: 20),
            /*DropdownButton<Map<String, String>>(
              value: null, // Valor seleccionado por defecto
              items: seleccion.map((item){
                return DropdownMenuItem<Map<String, String>>(
                  value: item,
                  child: Text(item['nombre'].toString()),
                );
              }).toList(),
              onChanged: (Map<String, String>? newValue) {
                if (newValue != null){
                  setState(() {
                    seleccion.add(newValue);
                  });
                }
              },
            ),*/
          ],
        ),
      ),
    );
  }

  getData() async {
    operatorsReq().then((value) {
      seleccion = value.cast<Map<String, dynamic>>();
      setState(() {
        seleccion;
        _items = seleccion
            .map((operator) => MultiSelectItem<Map<String, dynamic>>(operator, operator['name']))
            .toList();
      });
    });
  }

  Widget operadoresAsignados() {
    return Row(
      children: [ Expanded(
        child:  Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: LIGHT_BLUE_GHOST, borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.lightBlue),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height*.07,
            child: ListTile(
              title: Text(' ${seleccion[0]['name']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              subtitle: Text(' ${seleccion[0]['puesto']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  addOperator(),
                  IconButton(onPressed: (){}, icon: Icon(Icons.delete_outline_sharp, color: Colors.red[700],)),
                ],),
            ),
          ),
        ),
      )],
    );
  }

  Widget asignadosEmpty() {
    print('empty');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              addOperator();
            },
            child: Container(
              child: Icon(Icons.add_box_rounded, color: LIGHT_BLUE_GHOST, size: MediaQuery.of(context).size.height*.08,),
            ),
          ),
        ],
      ),
    );
  }

  addOperator() {
    print('En dropdown: '+seleccion.toString()+' : '+asignados.toString());
    return Container(
      // Puedes ajustar el padding según tus necesidades
      padding: EdgeInsets.all(10),
      child: MultiSelectDialogField(
        items: _items,
        title: Text("Seleccionar Operador"),
        selectedColor: Colors.blue,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.all(Radius.circular(40)),
          border: Border.all(
            color: Colors.blue,
            width: 2,
          ),
        ),
        buttonIcon: Icon(
          Icons.add,
          color: Colors.black,
        ),
        buttonText: Text(
          "Agregar Operador",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        onConfirm: (results) {
          // Puedes manejar los resultados aquí si es necesario
          if (results.isNotEmpty) {
            print('Results: '+results.toString());
            setState(() {
              //asignados.add(results); // Suponiendo que solo se permite seleccionar un operador
            });
          }
        },
      ),
    );
    /*return PopupMenuButton<dynamic>(
      initialValue: null,
      itemBuilder: (BuildContext context) {
        print('ingresado');
        return seleccion.map((item) {
          print('Elementos '+item.toString());
          return PopupMenuItem<dynamic>(
            value: item,
            child: Text(item['name'].toString()),
          );
        }).toList();
      },
      onSelected: (dynamic newValue) {
        setState(() {
          if (newValue != null && newValue is Map<String, dynamic>) {
            // Convierte el mapa en un formato que desees y agrégalo a la lista
            var operatorToAdd = {
              'id': newValue['id'],
              'name': newValue['name'],
              'puesto': newValue['puesto'],
            };
            seleccion.add(operatorToAdd);
          }
        });
      },
      child: IconButton(
          onPressed: null, // Puedes proporcionar la lógica del botón aquí si es necesario
          icon: Icon(Icons.add, color: Colors.black)
      ),
    );*/
  }

/*Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: operadores.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(operadores[index]['name']!),
                  // Puedes agregar más widgets aquí para personalizar cada elemento de la lista
                );
              },
            ),
          ),
          if (asignados.length < limite)
            ElevatedButton(
              onPressed: () {
                // Agregar un nuevo elemento
                setState(() {

                });
              },
              child: Text('Agregar Elemento'),
            ),
        ],
      ),*/
}
