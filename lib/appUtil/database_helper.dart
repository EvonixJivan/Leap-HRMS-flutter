import 'dart:async';
import 'dart:io' as io;

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;
  static Database? _db;

  String formatted = DateFormat('dd-MM-yyyy').format(DateTime.now());

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  DatabaseHelper.internal();
  

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = p.join(documentsDirectory.path, "hrms_new.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute("CREATE TABLE Item (id INTEGER PRIMARY KEY, "
        "server_id TEXT, "
        "punchDate TEXT, "
        "inTime TEXT, "
        "outTime TEXT, "
        "startLatitude TEXT, "
        "startLongitude TEXT, "
        "endLatitude TEXT, "
        "endLongitute TEXT, "
        "attachment TEXT, "
        "status INTEGER )");
  }

  //For Start
  Future<int> startAttendance(Attendance item) async {
    var dbClient = await db;
    int res = await dbClient.insert("Item", item.toMap());
    return res;
  }

  //For Stop
  Future<bool> stopAttendance(Attendance item) async {
    var dbClient = await db;
    int res = await dbClient.update("Item", item.toMap(),
        where: "id = ?", whereArgs: <int>[item._id]);
    return res > 0 ? true : false;
  }

  //For pause
  Future<bool> pauseAttendance(Attendance item) async {
    var dbClient = await db;
    int res = await dbClient.update("Item", item.toMap(),
        where: "id = ?", whereArgs: <int>[item._id]);
    return res > 0 ? true : false;
    //return res;
  }

  //For resume
  Future<bool> resumeAttendance(Attendance item) async {
    var dbClient = await db;
    int res = await dbClient.update("Item", item.toMap(),
        where: "id = ?", whereArgs: <int>[item._id]);
    return res > 0 ? true : false;
    //return res;
  }
}


class Attendance {
  String? _attachment;
  String? _endLatitude;
  String? _endLongitute;
 late int _id;
 String? _inTime;
 String? _outTime;
 String? _punchDate;
 String? _startLatitude;
 String? _startLongitude;
String? _totalPauseHours;
 String? _totalWorkingHours;
  late int _userId;

  Attendance();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attachment'] = this._attachment;
    data['endLatitude'] = this._endLatitude;
    data['endLongitute'] = this._endLongitute;
    data['id'] = this._id;
    data['inTime'] = this._inTime;
    data['outTime'] = this._outTime;
    data['punchDate'] = this._punchDate;
    data['startLatitude'] = this._startLatitude;
    data['startLongitude'] = this._startLongitude;
    data['totalPauseHours'] = this._totalPauseHours;
    data['totalWorkingHours'] = this._totalWorkingHours;
    data['userId'] = this._userId;
    return data;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attachment'] = this._attachment;
    data['endLatitude'] = this._endLatitude;
    data['endLongitute'] = this._endLongitute;
    data['id'] = this._id;
    data['inTime'] = this._inTime;
    data['outTime'] = this._outTime;
    data['punchDate'] = this._punchDate;
    data['startLatitude'] = this._startLatitude;
    data['startLongitude'] = this._startLongitude;
    data['totalPauseHours'] = this._totalPauseHours;
    data['totalWorkingHours'] = this._totalWorkingHours;
    data['userId'] = this._userId;
    return data;
  }

  int get userId => _userId;

  String get totalWorkingHours => _totalWorkingHours ?? "";

  String get totalPauseHours => _totalPauseHours ?? "";

  String get startLongitude => _startLongitude ?? "";

  String get startLatitude => _startLatitude ?? "";

  String get punchDate => _punchDate ?? "";

  String get outTime => _outTime ?? "";

  String get inTime => _inTime ?? "";

  int get id => _id;

  String get endLongitute => _endLongitute ?? "";

  String get endLatitude => _endLatitude ?? "";

  String get attachment => _attachment ?? "";

  set userId(int value) {
    _userId = value;
  }

  set totalWorkingHours(String value) {
    _totalWorkingHours = value;
  }

  set totalPauseHours(String value) {
    _totalPauseHours = value;
  }

  set startLongitude(String value) {
    _startLongitude = value;
  }

  set startLatitude(String value) {
    _startLatitude = value;
  }

  set punchDate(String value) {
    _punchDate = value;
  }

  set outTime(String value) {
    _outTime = value;
  }

  set inTime(String value) {
    _inTime = value;
  }

  set id(int value) {
    _id = value;
  }

  set endLongitute(String value) {
    _endLongitute = value;
  }

  set endLatitude(String value) {
    _endLatitude = value;
  }

  set attachment(String value) {
    _attachment = value;
  }


}

class User {
  String? _username;
 late  String _password;

  User(this._username, this._password);

  User.map(dynamic obj) {
    this._username = obj['username'];
    this._password = obj['password'];
  }

  String get username => _username ?? "";

  String get password => _password;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["username"] = _username;
    map["password"] = _password;
    return map;
  }
}
