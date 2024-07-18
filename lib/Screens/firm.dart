import 'dart:typed_data';

import 'package:checador_rola/Screens/save_firm.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../Functions/colors.dart';
import '../Helpers/user.dart';

class Firma extends StatefulWidget {

  final User user;
  static const routeName = '/firm';
  Firma({Key? key, required this.user}) : super(key: key);

  @override
  _FirmaState createState() => _FirmaState();
}

SignatureController? controller;

class _FirmaState extends State<Firma> {

  @override
  void initState() {
    super.initState();

    controller = SignatureController(
        penColor: Colors.white,
        penStrokeWidth: 2.5
    );
  }

  @override
  void dispose() {
    super.dispose();

    controller?.dispose();
  }

  Widget buildButtons(BuildContext context)=>
      Container(
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              buildCheck(context),
              buildClear()
            ],
          )
      );

  Widget buildCheck(BuildContext context) =>
      IconButton(
        iconSize: 35,
        icon: Icon(Icons.check, color: Colors.green),
        onPressed: () async {
          if(controller!.isNotEmpty){
            final signature = await exportSignature();
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SignaturePreviewPage(
              user:widget.user, signature: signature,))
            );
            controller?.clear();
          }
        },
      );

  Widget buildClear() =>
      IconButton(
        iconSize: 35,
        icon: Icon(Icons.clear, color: Colors.red),
        onPressed: () {
          controller?.clear();
          // print('presionaste el boton de limpiar');
        },
      );

  Future<Uint8List?> exportSignature() async{
    final exportController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
      points: controller?.points,
    );
    final signature = await exportController.toPngBytes();
    exportController.dispose();

    return signature;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.nombres.toString()),
        backgroundColor: DARK_BLUE_COLOR,
      ),
      body: SingleChildScrollView(child:
        Column (
          children: <Widget>[
            Signature(
              controller: controller!,
              backgroundColor: Colors.black,
              height: 500,
            ),
            buildButtons(context)
          ],
        ),
      ),
    );
  }
}
