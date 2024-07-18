class Operation {
  String? pro_id;
  String? pro_name;
  String? pro_no;
  String? airline;
  String? task_id;
  String? task_name;
  String? task_no;
  String? cabina;
  String? id_ub;
  String? description;
  String? status;

  Operation({
    this.pro_id,
    this.pro_name,
    this.pro_no,
    this.airline,
    this.task_id,
    this.task_name,
    this.task_no,
    this.cabina,
    this.id_ub,
    this.description,
    this.status,
  });

  /// Tranforms JSON to [Usuario]
  Operation.fromJSON(Map<String, dynamic> jsonData) {
    pro_id = jsonData['pro_id']??'';
    pro_name = jsonData['pro_name']??'';
    pro_no = jsonData['pro_no']??'';
    airline = jsonData['airline'] ?? '';
    task_id = jsonData['task_id']??'';
    task_name = jsonData['task_name']??'';
    task_no = jsonData['task_no']??'';
    cabina = jsonData['cabina']??'';
    id_ub = jsonData['id_ub']??'';
    description = jsonData['description'];
    status = jsonData['status'];
  }

  Operation.fromMap(Map<String, dynamic> map) {
    pro_id = map['pro_id']??'';
    pro_name = map['pro_name']??'';
    pro_no = map['pro_no']??'';
    airline = map['airline'] ?? '';
    task_id = map['task_id']??'';
    task_name = map['task_name']??'';
    task_no = map['task_no']??'';
    cabina = map['cabina']??'';
    id_ub = map['id_ub']??'';
    description = map['description'] ?? '';
    status = map['status'];
  }

  /// Returns a string whit basic person info.
  @override
  String toString() {
    return 'pro_id: $pro_id, '
    'pro_name: $pro_name, '
    'pro_no: $pro_no, '
    'airline: $airline, '
    'task_id: $task_id, '
    'task_name: $task_name, '
    'task_no: $task_no, '
    'cabina: $cabina, '
    'id_ub: $id_ub, '
    'description: $description, '
    'status: $status';
  }

  Map<String, dynamic> toJSON() => {
    'pro_id': pro_id,
    'pro_name': pro_name,
    'pro_no': pro_no,
    'airline': airline,
    'task_id': task_id,
    'task_name': task_name,
    'task_no': task_no,
    'cabina': cabina,
    'id_ub': id_ub,
    'description': description,
    'status': status,
  };

}