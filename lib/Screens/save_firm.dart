import 'dart:typed_data';

import 'package:checador_rola/Functions/request.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Functions/alerts.dart';
import '../Functions/sessions.dart';
import '../Helpers/user.dart';

class SignaturePreviewPage extends StatelessWidget{

  final Uint8List? signature;
  final User user;

  const SignaturePreviewPage({Key? key, required this.signature, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: CloseButton(),
        title: Text('Firma'),
        actions: [
          IconButton(
              onPressed: (){
                //storeSignature(context);
                saveImage2(signature, user.id.toString()).then((value){
                  verifyUser(user, context);
                  showToast("Firma guardada con exito", context);
                });
              },
              icon: Icon(Icons.done))
        ],
      ),
      body: Center(
          child: Image.memory(signature!)
      ),
    );
  }
}
