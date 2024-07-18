import 'package:checador_rola/Functions/colors.dart';
import 'package:flutter/material.dart';

class Locked extends StatefulWidget{
  Locked({Key? key}): super(key: key);
  @override
  _LockedStates createState() => _LockedStates();
}

class _LockedStates extends State<Locked> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Aviso', style: TEXT_TITLE_STYLE),
          SizedBox(height: 20),
          Padding(padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('La visualizacion de su tipo de usuario no esta disponible para IOs.', style: TEXT_SUBTITLE_STYLE),
          ),
      ],),
    );
  }
}