import 'package:masjidrahmah/models/athaan_row.dart';

class AthaanRowList {
  final List<AthaanRow> rows;

  AthaanRowList({
    this.rows,
  });

  //Iterator<AthaanRow> iterator() => new AthaanRowIterator(rows);
  Iterator<AthaanRow> iterator() => rows.iterator;

  factory AthaanRowList.fromJson(List<dynamic> parsedJson) {

    List<AthaanRow> rows = new List<AthaanRow>();
    rows = parsedJson.map((i)=>AthaanRow.fromJson(i)).toList();

    return new AthaanRowList(
      rows: rows,
    );
  }

}