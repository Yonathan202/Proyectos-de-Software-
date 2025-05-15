import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static Database? _database;

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'gastos.db');
    print("Ruta de la base de datos: $path");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE gastos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            descripcion TEXT,
            categoria TEXT,
            monto REAL,
            fecha TEXT
          )
        ''');

        print("Base de datos creada en: $path");

      },
    );
  }

  Future<int> insertGasto(Map<String, dynamic> gasto) async {
    final db = await initDB();
    try {
      int id = await db.insert('gastos', gasto);
      print("Gasto insertado correctamente con ID: $id"); 
      return id;
    } catch (e) {
      print("Error al insertar gasto: $e");
      return -1;
    }
  }


  Future<List<Map<String, dynamic>>> getGastos() async {
    final db = await initDB();
    return await db.query('gastos');
  }

  Future<void> deleteGasto(int id) async {
    final db = await initDB();
    await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateGasto(Map<String, dynamic> gasto) async {
    final db = await initDB();
    await db.update('gastos', gasto, where: 'id = ?', whereArgs: [gasto['id']]);
  }

}
