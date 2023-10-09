import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreServices {
  static Stream<QuerySnapshot> fetchSmokes() {
    CollectionReference reference =
        FirebaseFirestore.instance.collection('detected');
    var data = reference.orderBy('timestamp', descending: true).snapshots();

    return data;
  }

  static Stream<QuerySnapshot> graphSmoke() {
    CollectionReference reference =
        FirebaseFirestore.instance.collection('master');

    var data = reference.orderBy('timestamp', descending: true).snapshots();
    return data;
  }

  static Stream<QuerySnapshot> getSensorState() {
    CollectionReference reference =
        FirebaseFirestore.instance.collection('buzzer');

    var data = reference.snapshots();
    return data;
  }

  static void updateSensorState(bool value, BuildContext context) async {
    try {
      CollectionReference reference =
          FirebaseFirestore.instance.collection('buzzer');

      var documents = await reference.get();
      var buzzerId = documents.docs.first.id;
      reference.doc(buzzerId).update({'value': value});

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          'Buzzer ${value ? 'Aktif' : 'Nonaktif'}',
          textAlign: TextAlign.center,
        )));
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          'Terjadi kesalahan',
          textAlign: TextAlign.center,
        )));
      });
    }
  }
}
