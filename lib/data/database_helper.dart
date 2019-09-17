import 'dart:async';
import 'dart:io' as io;

import 'package:path/path.dart';
import 'package:masjidrahmah/models/athaan_row.dart';
import 'package:masjidrahmah/models/iqamah_row.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if(_db != null)
      return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "prayers.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    //await db.execute("DROP TABLE IF EXISTS athaan");
    //await db.execute("DROP TABLE IF EXISTS iqamah");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS athaan (year INTEGER, month INTEGER, day INTEGER,"
            " fajr TEXT, sunrise TEXT, dhuhr TEXT, asr TEXT, maghrib TEXT,"
            " isha TEXT, PRIMARY KEY (year, month, day))");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS iqamah (id INTEGER PRIMARY KEY CHECK (id=0),"
            " fajr_i TEXT, dhuhr_i TEXT, asr_i TEXT, maghrib_i TEXT,"
            " isha_i TEXT)");
  }

  void saveAthaan(AthaanRow row) async {
    var dbClient = await db;
    Map<dynamic,dynamic> rowMap = row.toMap();
    await dbClient.execute("REPLACE INTO athaan (year, month, day,"
        "fajr, sunrise, dhuhr, asr, maghrib, isha) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [rowMap["year"], rowMap["month"], rowMap["day"], rowMap["fajr"],
        rowMap["sunrise"], rowMap["dhuhr"], rowMap["asr"], rowMap["maghrib"], rowMap["isha"]]);
  }

  void saveIqamah(IqamahRow row) async {
    var dbClient = await db;
    Map<dynamic,dynamic> rowMap = row.toMap();
    /*await dbClient.execute(
        "CREATE TABLE IF NOT EXISTS iqamah (id INTEGER PRIMARY KEY CHECK (id=0),"
            " fajr_i TEXT, dhuhr_i TEXT, asr_i TEXT, maghrib_i TEXT, isha_i TEXT)");*/
    await dbClient.execute("REPLACE INTO iqamah (id, fajr_i, dhuhr_i, asr_i, maghrib_i, isha_i) "
        "VALUES(0, ?, ?, ?, ?, ?)", [rowMap["fajr_i"],
        rowMap["dhuhr_i"], rowMap["asr_i"], rowMap["maghrib_i"], rowMap["isha_i"]]);
  }

  void saveAthaanList(Iterator<AthaanRow> rowsIter) async {
    var dbClient = await db;
    var batch = dbClient.batch();
    while(rowsIter.moveNext()) {
      Map<dynamic,dynamic> rowMap = rowsIter.current.toMap();
      batch.execute("REPLACE INTO athaan (year, month, day,"
          "fajr, sunrise, dhuhr, asr, maghrib, isha) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)",
          [rowMap["year"], rowMap["month"], rowMap["day"], rowMap["fajr"],
          rowMap["sunrise"], rowMap["dhuhr"], rowMap["asr"], rowMap["maghrib"], rowMap["isha"]]);
    }
    await batch.commit(noResult: true);
  }

  Future<AthaanRow> getAthaanToday() async {
    var dbClient = await db;
    var now = new DateTime.now();
    List<Map> results = await dbClient.rawQuery('SELECT * from athaan WHERE year = ?'
        ' AND month = ? AND day = ?', [now.year, now.month, now.day]);
    if(results.length >= 1) {
      return AthaanRow.fromMap(results[0]);
    }
    return AthaanRow.fromMap(Map.fromEntries([MapEntry("year", now.year),
    MapEntry("month", now.month), MapEntry("day", now.day),
    MapEntry("fajr", "00:00"), MapEntry("sunrise", "00:00"),
    MapEntry("dhuhr", "00:00"), MapEntry("asr", "00:00"), MapEntry("maghrib", "00:00"),
    MapEntry("isha", "00:00")]));
  }

  Future<IqamahRow> getIqamahToday() async {
    var dbClient = await db;
    var now = new DateTime.now();
    List<Map> results = await dbClient.rawQuery('SELECT * from iqamah WHERE id = 0');
    if(results.length >= 1) {
      return IqamahRow.fromMap(results[0]);
    }
    return IqamahRow.fromMap(Map.fromEntries([MapEntry("fajr_i", "00:00"), MapEntry("dhuhr_i", "00:00"),
    MapEntry("asr_i", "00:00"), MapEntry("maghrib_i", "00:00"), MapEntry("isha_i", "00:00")]));
  }

  /*Future<int> deleteUsers() async {
    var dbClient = await db;
    int res = await dbClient.delete("athaan");
    return res;
  }

  Future<bool> isLoggedIn() async {
    var dbClient = await db;
    var res = await dbClient.query("athaan");
    return res.length > 0? true: false;
  }*/

}