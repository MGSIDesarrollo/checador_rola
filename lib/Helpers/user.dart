class User {
  String? nombres;
  String? correo;
  String? telefono;
  int? id;
  int? operativoid;
  String? puesto;

  User({
    this.nombres,
    this.correo,
    this.telefono,
    this.id,
    this.operativoid,
    this.puesto,
  });

  /// Tranforms JSON to [Usuario]
  User.fromJSON (Map<dynamic, dynamic>jsonData) {
    nombres = jsonData['lastname']??'';
    correo = jsonData['email']??'';
    telefono = jsonData['phone']??'';
    var iden = jsonData['contactid'];
    id = iden is int? iden : int.parse(iden);
    var id_op = jsonData['operativoid'] ?? 0;
    operativoid = id_op is int? id_op : int.parse(id_op);
    puesto = jsonData['puesto']??'';
    //id = jsonData['contactid']??'';
  }

  User.fromMap(Map<String, dynamic> map) {
    nombres = map['lastname'] ?? '';
    correo = map['email'] ?? '';
    telefono = map['phone'] ?? '';
    var iden = map['contactid'] ?? 0;
    id = iden is int ? iden : int.parse(iden);
    var id_op = map['operativoid'] ?? 0;
    operativoid = id_op is int ? id_op : int.parse(id_op);
    puesto = map['puesto'] ?? '';
  }

  /// Returns a string whit basic person info.
  @override
  String toString() {
    return 'contactid: $id, operativoid: ${operativoid ?? '0'}, phone: $telefono, lastname: $nombres, email: $correo, puesto: $puesto';
  }

  Map<String, dynamic> toJSON()=>{
    'lastname': nombres,
    'email': correo,
    'phone': telefono,
    'contactid': id,
    'operativoid': operativoid ?? '0',
    'puesto': puesto,
  };

}