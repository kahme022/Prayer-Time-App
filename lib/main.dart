import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:masjidrahmah/Theme.dart' as Theme;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:masjidrahmah/models/athaan_row.dart';
import 'package:masjidrahmah/models/athaan_row_list.dart';
import 'package:masjidrahmah/models/iqamah_row.dart';
import 'package:masjidrahmah/data/database_helper.dart';
import 'package:rxdart/subjects.dart';
import 'package:rxdart/rxdart.dart';
import 'package:async/async.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PrayerTimesProvider(
      prayerTimesBloc: PrayerTimesBloc(),
      child: MaterialApp(
        home: new PTPage(),
      ),
    );
  }
}

class PrayerTimesProvider extends InheritedWidget {
  final PrayerTimesBloc prayerTimesBloc;

  PrayerTimesProvider({
    Key key,
    @required this.prayerTimesBloc,
    Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static PrayerTimesBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(PrayerTimesProvider) as PrayerTimesProvider)
      .prayerTimesBloc;
}

class PrayerTimesBloc {
  //final _prayerTimes = PrayerTimes();

  Sink<AthaanRowList> get updateAthaan => _updateAthaanController.sink;
  final _updateAthaanController = StreamController<AthaanRowList>();

  Sink<IqamahRow> get updateIqamah => _updateIqamahController.sink;
  final _updateIqamahController = StreamController<IqamahRow>();

  Stream<AthaanRow> get athaanToday => _athaanTodaySubject.stream;
  final _athaanTodaySubject = BehaviorSubject<AthaanRow>();

  Stream<IqamahRow> get iqamahToday => _iqamahTodaySubject.stream;
  final _iqamahTodaySubject = BehaviorSubject<IqamahRow>();

  CombineLatestStream _timeTableToday;
  Stream<Map<dynamic,dynamic>> get timeTableToday => _timeTableToday
      .cast<Map<dynamic,dynamic>>();

  PrayerTimesBloc() {
    _getTimesFromDb();
    _updateAthaanController.stream.listen(_handleAthaanUpdate);
    _updateIqamahController.stream.listen(_handleIqamahUpdate);
    _timeTableToday = CombineLatestStream.combine2(
      _athaanTodaySubject.stream, _iqamahTodaySubject.stream,
      (a,b) => {}..addAll(a.toMap())..addAll(b.toMap())
    );
  }

  void _getTimesFromDb() async {
    var databasesPath = await getApplicationDocumentsDirectory();
    String path = join(databasesPath.toString(), 'prayers.db');
    var db = new DatabaseHelper();
    AthaanRow ar = await db.getAthaanToday();
    IqamahRow ir = await db.getIqamahToday();
    _athaanTodaySubject.add(ar);
    _iqamahTodaySubject.add(ir);
  }

  void _handleAthaanUpdate(AthaanRowList athaanrows) async {
    var databasesPath = await getApplicationDocumentsDirectory();
    String path = join(databasesPath.toString(), 'prayers.db');
    var db = new DatabaseHelper();
    db.saveAthaanList(athaanrows.iterator());
    _getTimesFromDb();
  }

  void _handleIqamahUpdate(IqamahRow iqamahrow) async {
    var databasesPath = await getApplicationDocumentsDirectory();
    String path = join(databasesPath.toString(), 'prayers.db');
    var db = new DatabaseHelper();
    db.saveIqamah(iqamahrow);
    _getTimesFromDb();
  }
}

class PTPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new PTPageState();
  }
}

class PTPageState extends State<PTPage> {
  TableRow _buildPrayerTimeRow(String salah, String athaan, String iqamah) {
    if(iqamah != "") {
      DateTime aTime = DateTime.tryParse('19700101T' + athaan);
      DateTime iTime;
      int delta = 0;
      try {
        iTime = DateTime.parse('19700101T' + iqamah);
      } on FormatException {
        if(iqamah.startsWith('+')) {
          delta = int.tryParse(iqamah.substring(1));
          iTime = new DateTime(1970, 1, 1, aTime.hour, aTime.minute);
          iTime = iTime.add(new Duration(minutes: delta));
        }
        else if(iqamah.startsWith('-')) {
          delta = int.tryParse(iqamah.substring(1));
          iTime = new DateTime(1970, 1, 1, aTime.hour, aTime.minute);
          iTime = iTime.subtract(new Duration(minutes: delta));
        }
      }
      iqamah = iTime.hour.toString().padLeft(2, '0') + ':'
          + iTime.minute.toString().padLeft(2, '0');
    }

    return TableRow(
        children: <Widget> [
          TableCell(
              child: new Text(salah, style: Theme.TextStyles.tableRowText)
          ), TableCell(
            child: new Text(athaan, style: Theme.TextStyles.tableRowText),
          ), TableCell(
            child: new Text(iqamah, style: Theme.TextStyles.tableRowText),
          ),
        ]
    );
  }



  @override
  Widget build(BuildContext context) {
    final prayerTimesBloc = PrayerTimesProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Masjid ar-Rahmah'),
      ),
      /*body: FutureBuilder(
        future: loadData(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return body(snapshot.data);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),*/
      body: StreamBuilder<Map<dynamic,dynamic>>(
        stream: prayerTimesBloc.timeTableToday,
        builder: (context, snapshot) {
          if(snapshot.data == null || snapshot.data.isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return body(snapshot.data);
        }
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
        onPressed: () => updateData(context),
      ),
    );
  }

  Widget body(Map<dynamic,dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        // Box decoration takes a gradient
        gradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          // Add one stop for each color. Stops should increase from 0 to 1
          stops: [0.1, 0.5, 0.7, 0.9],
          colors: [
            // Colors are easy thanks to Flutter's Colors class.
            Colors.lightBlue[800],
            Colors.lightBlue[700],
            Colors.lightBlue[500],
            Colors.lightBlue[400],
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          /*Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset(
              'images/masjid-rahmah-horizantal-logo.png',
              height: 240.0,
              fit: BoxFit.contain,
            ),
          ),*/
          //Divider(),layout
          //Text('Profile Details'),
          Table(
            //border: TableBorder.all(width: 1.0),
            children: [
              TableRow(children: [
                TableCell(
                    child: new Text('', style: Theme.TextStyles.tableHeadingText)
                ), TableCell(
                    child: new Text('Athaan', style: Theme.TextStyles.tableHeadingText),
                ), TableCell(
                    child: new Text('Iqamah', style: Theme.TextStyles.tableHeadingText),
                ),
              ]),
              _buildPrayerTimeRow('Fajr',data["fajr"].toString(),data["fajr_i"].toString()),
              _buildPrayerTimeRow('Sunrise',data["sunrise"].toString(),""),
              _buildPrayerTimeRow('Dhuhr',data["dhuhr"].toString(), data["dhuhr_i"].toString()),
              _buildPrayerTimeRow('Asr',data["asr"].toString(),data["asr_i"].toString()),
              _buildPrayerTimeRow('Maghrib',data["maghrib"].toString(),data["maghrib_i"].toString()),
              _buildPrayerTimeRow('Isha',data["isha"].toString(),data["isha_i"].toString()),
              _buildPrayerTimeRow('Jumuah',"12:45",""),
            ],
          ),
        ],
      ),
    );
  }

  void updateData(BuildContext context) async {
    final prayerTimesBloc = PrayerTimesProvider.of(context);

    http.Response response = await http.get(
        Uri.encodeFull("https://app.mymasjid.ca/protected/public/getathaan"));
    List<dynamic> jsonRows = jsonDecode(response.body);
    final AthaanRowList athaanrows = AthaanRowList.fromJson(jsonRows);

    http.Response response2 = await http.get(
        Uri.encodeFull("https://app.mymasjid.ca/protected/public/getiqamah"));
    List<dynamic> jsonRows2 = jsonDecode(response2.body);
    final IqamahRow iqamahrow = IqamahRow.fromJson(jsonRows2);

    prayerTimesBloc.updateAthaan.add(athaanrows);
    prayerTimesBloc.updateIqamah.add(iqamahrow);

  }


}
