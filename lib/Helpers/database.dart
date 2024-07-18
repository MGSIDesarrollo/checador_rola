import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

  Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'rola.db');

    // Abre la base de datos (crea una nueva si no existe)
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Crea las tablas en la base de datos
        await db.execute(
          'CREATE TABLE users ('
              'contactid INTEGER PRIMARY KEY, '
              'lastname TEXT, '
              'telefono INTEGER, '
              'email TEXT, '
              'puesto TEXT, '
              'status INTEGER '
              ')',
        );
        await db.execute(
          'CREATE TABLE tasks ('
              'id INTEGER PRIMARY KEY, '
              'pro_id TEXT, '
              'pro_name TEXT, '
              'pro_no TEXT, '
              'task_id TEXT, '
              'task_name TEXT, '
              'task_no TEXT, '
              'cabina TEXT, '
              'id_ub TEXT'
          ')',
        );
        await db.execute(
          'CREATE TABLE checks ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'latitude TEXT, '
              'longitude TEXT, '
              'datetime TEXT, '
              'status INTEGER' // 0; eliminada, 1; enviada, 2; sin enviar
              ')',
        );
        await db.execute( //En mysql id, nombre, direccion, lat, lng, status
          'CREATE TABLE checkpoints ('
              'id INTEGER PRIMARY KEY, '
              'name TEXT, '
              //'address TEXT, '
              'latitude TEXT, '
              'longitude TEXT, '
              'status INTEGER'
              ')',
        );
        await db.execute(
          'CREATE TABLE custodias ('
              'id INTEGER PRIMARY KEY, '
              'id_operation TEXT, '
              'name TEXT, '
              'nationality TEXT, '
              'migration TEXT, '
              'migration2 TEXT, '
              'date TEXT, '
              'time TEXT, '
              'status INTEGER' // 0 subido, 1 por subir
              ')',
        );
        await db.execute(
          'CREATE TABLE cabinas ('
              'id INTEGER PRIMARY KEY, '
              'id_operation TEXT, '
              'name TEXT, '
              'enterprise TEXT, '
              'no_tia TEXT, '
              'motivo TEXT, '
              'details TEXT,'
              'startDate TEXT, '
              'endDate TEXT, '
              'visible INTEGER, '
              'status INTEGER, ' // 0 subido, 1 por subir
              'crmid TEXT '
              ')',
        );

        await db.execute(
          'CREATE TABLE informe ('
              'id INTEGER PRIMARY KEY, '
              'id_operation TEXT, '
              'paxEntrada TEXT, '
              'paxSalida TEXT, '
              'openDoors TEXT, '
              'closeDoors TEXT,'
              'firstPaxIn TEXT, '
              'lastPaxIn TEXT, '
              'firstPaxOut TEXT, '
              'lastPaxOut TEXT, '
              'status INTEGER ' // 0 subido, 1 por subir
              ')',
        );

        await db.execute(
          'CREATE TABLE finOperacion ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'idOperacion TEXT, '
              'horaFin TEXT, '
              'status INTEGER'  // 0 subido, 1 por subir
              ')',
        );
      },
    );
  }
}
