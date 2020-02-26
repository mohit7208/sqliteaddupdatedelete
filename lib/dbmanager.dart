import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbStudentManager {
  Database _database;

  Future openDb() async {
    if (_database == null) {
      _database = await openDatabase(
          join(await getDatabasesPath(), "ss.db"),
          version: 1, onCreate: (Database db, int version) async {
        await db.execute(         
           "CREATE TABLE student(id INTEGER PRIMARY KEY autoincrement, firstname TEXT, lastname TEXT)",
           
            );
      } );
    }
  }

  Future<int> insertStudent(Student student) async {
    await openDb();
    return await _database.insert('student', student.toMap());
  }

  Future<List<Student>> getNameList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('student');
    return List.generate(maps.length, (i) {
      return Student(
          id: maps[i]['id'], firstname: maps[i]['firstname'], lastname: maps[i]['lastname']);
    });
  }

  Future<int> updateName(Student student) async {
    await openDb();    
    return await _database.update('student', student.toMap(),
        where: "id = ?", whereArgs: [student.id]);
  }

  Future<void> deleteName(int id) async {
    await openDb();
    await _database.delete(
      'student',
        where: "id = ?", whereArgs: [id]
    );
  }
}

class Student {
  int id;
  String firstname;
  String lastname;
  Student({@required this.firstname, @required this.lastname, this.id});
  Map<String, dynamic> toMap() {
    return {'firstname': firstname, 'lastname': lastname};
  }
}
