import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'colors.dart';

showSimpleDialog(BuildContext context, String tittle, String message, {final Icon icono = const Icon(Icons.warning, color: Colors.yellow, size: 55.0)}) {
  AlertDialog alert = AlertDialog(
    title: Row(
      children: <Widget>[
        Text(tittle,),
        icono,
      ]
    ),
    content: Text(message, style: const TextStyle(color: Colors.black,)),
  );
  _showDialog(context, alert);
}

showAlertDialog(BuildContext context, String title, String message, {final Icon icono = const Icon(Icons.warning, color: Colors.yellow, size: 55.0)}) {
  AlertDialog alert = AlertDialog(
    backgroundColor: DARK_BLUE_GHOST,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(title, style: TextStyle(color: Colors.white)),
        icono,
      ],
    ),
    content: Text(message, style: TextStyle(color: Colors.white,), textAlign: TextAlign.center),
  );
  _showDialog(context, alert);
}

showAlertSelectDialog(BuildContext context, Function yesAction, String title, {titleStyle = TEXT_BUTTON_STYLE}) {
  AlertDialog alert = AlertDialog(
    backgroundColor: DARK_BLUE_GHOST,
    title: Row(
      children: <Widget>[
        Expanded(child: Text(title, style: titleStyle, textAlign: TextAlign.center, softWrap: true,)),
        Icon(Icons.warning, color: Colors.yellow, size: 55.0)
      ],
    ),
    actions: <Widget>[
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        child: Text('No', style: TextStyle(color: DARK_BLUE_COLOR)),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        child: Text('Sí', style: TextStyle(color: DARK_BLUE_COLOR)),
        onPressed: () {
          yesAction();
          Navigator.of(context).pop();
        },
      ),
    ],
  );
  _showDialog(context, alert);
}

showAlertWidget(BuildContext context, String title, Widget view, {String? description}){
  AlertDialog alert = AlertDialog(
    title: Text('Dropdown in AlertDialog'),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
      if (description != null)
        Text(description, style: TEXT_LABEL, textAlign: TextAlign.center,),
        view,
    ],),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text('Close'),
      ),
    ],
  );
}

Future<bool?> showAlertOptionDialog(
    BuildContext context,
    String title,
    {content = null, titleStyle = TEXT_BUTTON_STYLE
    }) async {
  AlertDialog alert = AlertDialog(
    backgroundColor: DARK_BLUE_GHOST,
    title: Row(
      children: <Widget>[
        Expanded(child: Text(title, style: titleStyle, textAlign: TextAlign.center, softWrap: true,)),
        Icon(Icons.warning, color: Colors.yellow, size: 55.0)
      ],
    ),
    content: content != null
        ? Text(content.toString(), style: TextStyle(color: Colors.white), textAlign: TextAlign.center,)
        : Text(''),
    actions: <Widget>[
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        child: Text('No', style: TextStyle(color: DARK_BLUE_COLOR)),
        onPressed: () {
          Navigator.of(context).pop(false);
        },
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        child: Text('Sí', style: TextStyle(color: DARK_BLUE_COLOR)),
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      ),
    ],
  );

  // Usamos await para esperar el resultado de la función pop.
  bool? result = await _showDialog(context, alert);

  // Devolvemos el resultado.
  return result;
}

Future<bool?> _showDialog(BuildContext context, var alert) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showMessageDialog(BuildContext context, String tittle, String message){
  AlertDialog alert = AlertDialog(
    title: Text(tittle),
    content: Text(message),
    backgroundColor: ALERTA,
  );
  _showDialog(context, alert);
}

showToast(String message, BuildContext context, {int duration=2, Color background=DARK_BLUE_GHOST, int align=1}){
  ToastContext().init(context);
  Toast.show(message, duration: duration, backgroundColor: background, gravity: align);
}