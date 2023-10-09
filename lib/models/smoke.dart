import 'package:cloud_firestore/cloud_firestore.dart';

class Smoke {
  int bilik;
  dynamic co;
  dynamic co2;
  Timestamp timestamp;

  Smoke(
      {required this.bilik,
      required this.co,
      required this.co2,
      required this.timestamp});

  factory Smoke.fromSnapshot(QueryDocumentSnapshot<Object?> snapshot) => Smoke(
      bilik: int.parse(snapshot['bilik'].toString()),
      co: snapshot['co'],
      co2: snapshot['co2'],
      timestamp: snapshot['timestamp']);
}
