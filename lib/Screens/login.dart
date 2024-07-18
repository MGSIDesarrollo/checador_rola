import 'package:checador_rola/Functions/alerts.dart';
import 'package:checador_rola/Functions/colors.dart';
import 'package:flutter/material.dart';

import '../../Functions/request.dart';
import '../Functions/functions.dart';
import '../Functions/sessions.dart';
import '../Helpers/database.dart';
import '../Helpers/user.dart';
import 'firm.dart';

class Login extends StatefulWidget {
  final Future<String> load;
  Login({Key? key, required this.load}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController? usrCtr;
  TextEditingController? pssCtr;

  int hasSession = -1;
  bool conexion = false;

  Future<void> isInteret() async{
    await Conn.isInternet().then((connection) {
    });
  }

  @override
  void initState() {
    super.initState();

    Conn.isInternet().then((connection) {
      if (connection) {
        this.widget.load.then((res) {
          setState(() {
            conexion = connection;
            hasSession = res == '' ? 1 : -1;
          });
          if (res != '') {
            loadSessionReq(res).then((value) async{
              print('test '+value.toString());
              if (value != null && !(value is List)) {
                verifyUser(value, context, saveSession: true);
              } else if (value == null){
                setState(() {
                  hasSession = -1;
                });
              } else if(value[1] == 'Sin firma'){
                Navigator.pushReplacement<void, void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => Firma(user: value[0],),
                  ),
                );
              }
            });
          }
        });
      }else{
        print('Without connection');
        user_local();
      }
    });
    usrCtr = TextEditingController();
    pssCtr = TextEditingController();
  }

  @override
  void dispose() {
    usrCtr?.dispose();
    pssCtr?.dispose();
    super.dispose();
  }

  Widget logIn(){
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*.15,),
          Center(
            child: Container(decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: Colors.white,
            ),
              width: MediaQuery.of(context).size.width*.80,
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 27.0, right: 10, left: 10),
                    child: Column(children: <Widget>[
                      Container(
                        width: 200.0, // Establece el ancho deseado
                        child: Image.asset('assets/icon/logo_rola.jpeg'),
                      ),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text('Usuario', style: TextStyle(fontSize: 22, color: Colors.blueGrey),),
                      ),
                      TextFormField(
                        controller: usrCtr,
                        autocorrect: false,
                        validator: (value){
                          if(value==''){
                            return 'Se requiere ingresar su usuario';
                          }
                          return null;
                          },
                      ),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Contraseña',
                          style: TextStyle(fontSize: 22, color: Colors.blueGrey
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: pssCtr,
                        obscureText: true,
                        autocorrect: false,
                        maxLength: 15,
                        validator: (value){
                          if(value==''){
                            return 'Se requiere ingresar su contraseña';
                          }
                          return null;
                          },
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: ElevatedButton(
                          style: DARK_BUTTON_STYLE,
                          child: Text('Ingresar', style: TextStyle(color: Colors.white),),
                          onPressed: () {
                            if(_formKey.currentState!.validate()){
                              loginReq(usrCtr!.text, pssCtr!.text).then((onValue){
                                print('test2 '+onValue.toString());
                                if (onValue != null && !(onValue is List)) {
                                  showToast('Por favor espere', context);
                                  downCheckpoints(onValue.id.toString());
                                  verifyUser(onValue, context);
                                } else if (onValue == null || onValue == 'no ok'){
                                  showToast('Hay un error en los datos, por favor vuelva a intentarlo.', context);
                                  setState(() {
                                    hasSession = -1;
                                  });
                                } else if(onValue[1] == 'Sin firma'){
                                  Navigator.pushReplacement<void, void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) => Firma(user: onValue[0],),
                                    ),
                                  );
                                }
                              });
                            }},
                        ),
                      ),
                      SizedBox(height: 5,),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget BackgroundImage(){
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/icon/login-background.jpg'),
          fit: BoxFit.fill,
          //colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken)
        ),
      )
    );
  }

  Widget _session() => hasSession == 1 ? Center(child: loadingUser) : Text('');

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackgroundImage(),
        Scaffold(
            backgroundColor: Colors.transparent,
            body:ListView(
                children: <Widget>[
                  logIn(),
                  _session()
                ]
            )
        ),
      ],
    );

  }

  void user_local() async{
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.db;

    String whereCondition = 'status > ?';
    List<dynamic> whereArgs = [1];
    final List<Map<String, dynamic>> data = await db.query(
      'users',
    );
    User user = User.fromJSON(data.first);
    Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (Route<dynamic> route) => false,
        arguments: {
          'datos': user,
          'save': false,
        }
    );
  }

  void queryUser() async{
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.db;

    final List<Map<String, dynamic>> data = await db.query('users');

    User? user;
    if (data.isNotEmpty) {
      user = User.fromJSON(data.first);
    }

    if (user != null) {
      verifyUser(user, context);
    } else {
      setState(() {
        hasSession = -1;
      });
    }
  }
}


