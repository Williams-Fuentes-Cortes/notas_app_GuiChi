import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:notes_app/modal_class/notes.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  // Variables como atributos de la base de datos
  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colColor = 'color';
  String colDate = 'date';
// Constructor con nombre para crear una instancia de DatabaseHelper
  DatabaseHelper._createInstance(); 

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // Esto se ejecuta solo una vez, objeto singleton
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Se obtiene la ruta del directorio para Android e iOS para almacenar la base de datos.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';
    //print('db location :'+ path);

    // Abrir/ crear la base de datos en la ruta dada
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  // Se crea la tabla de la base de datos
  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colPriority INTEGER, $colColor INTEGER,$colDate TEXT)');
  }

  // Operación de búsqueda: Obtener todos los objetos de NOTA de la base datos
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database;

//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  // Operación de insersión: Insertar un objeto de NOTA en la base de datos
  Future<int> insertNote(Note note) async {
    Database db = await database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // Operación de actualización: Actualiza un objeto NOTA y se guarda en la base de datos
  Future<int> updateNote(Note note) async {
    var db = await database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Operación de eliminación: elimina un objeto de NOTA de la base de datos
  Future<int> deleteNote(int id) async {
    var db = await database;
    int result =
        await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  // Obtener el número de objetos NOTA en la base de datos
  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Obtiene la 'Map List' [ List<Map> ] y se convierte en  'Note List' [ List<Note> ]
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList(); // Obtiene 'Map List' de la database
    int count =
        noteMapList.length; // Contar el número de entradas del mapa en la tabla db

    List<Note> noteList = [];
    // Bucle for para crear una 'Note List' a partir de una 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }
}
