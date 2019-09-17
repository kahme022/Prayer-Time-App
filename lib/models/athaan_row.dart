import 'dart:core';

class AthaanRow {
  int _year;
  int _month;
  int _day;
  String _fajr;
  String _sunrise;
  String _dhuhr;
  String _asr;
  String _maghrib;
  String _isha;

  AthaanRow(this._year, this._month, this._day, this._fajr, this._sunrise,
    this._dhuhr, this._asr, this._maghrib, this._isha);

  AthaanRow.map(dynamic obj) {
    this._year = obj["year"];
    this._month = obj["month"];
    this._month = obj["day"];
    this._fajr = obj["fajr"];
    this._sunrise = obj["sunrise"];
    this._dhuhr = obj["dhuhr"];
    this._asr = obj["asr"];
    this._maghrib = obj["maghrib"];
    this._isha = obj["isha"];
  }

  int get year => _year;
  int get month => _month;
  int get day => _day;
  String get fajr => _fajr;
  String get sunrise => _sunrise;
  String get dhuhr => _dhuhr;
  String get asr => _asr;
  String get maghrib => _maghrib;
  String get isha => _isha;


  Map<String, dynamic> toMap() {
      var map = new Map<String, dynamic>();
      map["year"] = _year;
      map["month"] = _month;
      map["day"] = _day;
      map["fajr"] = _fajr;
      map["sunrise"] = _sunrise;
      map["dhuhr"] = _dhuhr;
      map["asr"] = _asr;
      map["maghrib"] = _maghrib;
      map["isha"] = _isha;
      return map;
  }

  factory AthaanRow.fromJson(List<dynamic> parsedJson) {
    return new AthaanRow(
      parsedJson[0],
      parsedJson[1],
      parsedJson[2],
      parsedJson[3],
      parsedJson[4],
      parsedJson[5],
      parsedJson[6],
      parsedJson[7],
      parsedJson[8],
    );
  }

  factory AthaanRow.fromMap(Map<dynamic,dynamic> m) {
    return new AthaanRow(m["year"], m["month"], m["day"], m["fajr"], m["sunrise"],
      m["dhuhr"], m["asr"], m["maghrib"], m["isha"]);
  }

}