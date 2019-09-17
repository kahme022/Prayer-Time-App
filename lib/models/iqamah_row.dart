import 'dart:core';

class IqamahRow {
  String _fajr;
  String _dhuhr;
  String _asr;
  String _maghrib;
  String _isha;

  IqamahRow(this._fajr, this._dhuhr, this._asr, this._maghrib, this._isha);

  IqamahRow.map(dynamic obj) {
    this._fajr = obj["fajr_i"];
    this._dhuhr = obj["dhuhr_i"];
    this._asr = obj["asr_i"];
    this._maghrib = obj["maghrib_i"];
    this._isha = obj["isha_i"];
  }

  String get fajr => _fajr;
  String get dhuhr => _dhuhr;
  String get asr => _asr;
  String get maghrib => _maghrib;
  String get isha => _isha;


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["fajr_i"] = _fajr;
    map["dhuhr_i"] = _dhuhr;
    map["asr_i"] = _asr;
    map["maghrib_i"] = _maghrib;
    map["isha_i"] = _isha;
    return map;
  }

  factory IqamahRow.fromJson(List<dynamic> parsedJson) {
    return new IqamahRow(
        parsedJson[0][1].toString(), // Ignore first element, since it is the id
        parsedJson[0][2].toString(),
        parsedJson[0][3].toString(),
        parsedJson[0][4].toString(),
        parsedJson[0][5].toString()
    );
  }

  factory IqamahRow.fromMap(Map<dynamic,dynamic> m) {
    return new IqamahRow(m["fajr_i"], m["dhuhr_i"], m["asr_i"],
        m["maghrib_i"], m["isha_i"]);
  }
}