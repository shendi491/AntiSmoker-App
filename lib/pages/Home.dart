import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/firestore_services.dart';
import 'LoginScreen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool switchValue = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 60,
              ),
              Text(
                'AntiSmoker',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(
                height: 30,
              ),
              Image.asset(
                'assets/images/Logo.png',
                height: 165.6,
              ),
              const SizedBox(
                height: 60,
              ),
              Text('Buzzer Status :',
                  style:
                      const TextStyle(fontFamily: 'Mont Bold', fontSize: 18)),
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  child: StreamBuilder(
                      stream: FirestoreServices.getSensorState(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            showDialog(
                              context: context,
                              builder: (context) => Center(
                                child: CircularProgressIndicator(
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            );
                          });
                        } else if (snapshot.connectionState ==
                            ConnectionState.active) {
                          Navigator.pop(context);

                          if (snapshot.hasData) {
                            var data = snapshot.data;
                            switchValue = data!.docs.first['value'];
                          }
                        } else {
                          Navigator.pop(context);
                        }
                        return CupertinoSwitch(
                          activeColor: Colors.green.withOpacity(0.9),
                          thumbColor: Colors.grey.shade800,
                          value: switchValue,
                          onChanged: (value) {
                            setState(() {});
                            FirestoreServices.updateSensorState(value, context);
                          },
                        );
                      })),
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                width: double.infinity,
                child: HomeButtonUI(
                    text: 'Log Out',
                    onTap: () async {
                      await FirebaseAuth.instance.signOut().then((value) async {
                        CollectionReference firestoreTokens =
                            FirebaseFirestore.instance.collection('tokens');
                        String? thisDeviceToken =
                            await FirebaseMessaging.instance.getToken();

                        var tokens = await firestoreTokens
                            .where('fcm_tokens', isEqualTo: thisDeviceToken)
                            .get();

                        if (tokens.size > 0) {
                          await firestoreTokens
                              .doc(tokens.docs.first.id)
                              .delete();
                        }
                        return value;
                      });
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    context: context),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  ElevatedButton HomeButtonUI(
      {required String text,
      required void Function() onTap,
      required BuildContext context}) {
    return ElevatedButton(
        onPressed: onTap,
        style: Theme.of(context).elevatedButtonTheme.style,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            text,
            style: const TextStyle(fontFamily: 'Mont Bold', fontSize: 16),
          ),
        ));
  }
}
