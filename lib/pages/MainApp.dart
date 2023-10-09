import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:AntiSmoker/main.dart';
import 'package:AntiSmoker/models/smoke.dart';
import 'package:AntiSmoker/pages/notif.dart';
import 'package:AntiSmoker/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'LoginScreen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../components/constant.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int currentIndex = 0;
  TextEditingController datecontroler = TextEditingController();
  DateTime? dateSearch;
  bool switchValue = false;

  @override
  void initState() {
    try {
      FirebaseMessagingService().initialize(flutterLocalNotificationsPlugin);
    } catch (e) {
      print(e);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      //Home
      Padding(
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
      //Dashboard
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Text(
                  'Toilet Monitoring',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 15),
                StreamBuilder(
                  stream: FirestoreServices.graphSmoke(),
                  builder: (context, snapshot) {
                    List<Smoke> smokes = [];
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      smokes.addAll([
                        Smoke(
                            bilik: 1, co: 0, co2: 0, timestamp: Timestamp.now())
                      ]);
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      if (snapshot.hasData) {
                        smokes.clear();
                        smokes.addAll([
                          Smoke.fromSnapshot(snapshot.data!.docs
                              .where((element) => element['bilik'] == 1)
                              .first),
                          Smoke.fromSnapshot(snapshot.data!.docs
                              .where((element) => element['bilik'] == 2)
                              .first)
                        ]);
                      } else {
                        smokes.clear();
                        smokes.addAll([
                          Smoke(
                              bilik: 1,
                              co: 0,
                              co2: 0,
                              timestamp: Timestamp.now())
                        ]);
                      }
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                      itemCount: smokes.length,
                      itemBuilder: (context, index) {
                        String statusCO = '';
                        String statusCO2 = '';
                        Color colorCO = Colors.white;
                        Color colorCO2 = Colors.white;
                        double finalCountCO =
                            smokes[index].co / thresholdco as double;
                        double finalCountCO2 =
                            smokes[index].co2 / thresholdco2 as double;
                        if (finalCountCO <= 0.25) {
                          statusCO = 'Smokes Clear';
                          colorCO = Colors.green;
                        } else if (finalCountCO >= 0.26 &&
                            finalCountCO <= 0.5) {
                          statusCO = 'Smokes Clear';
                          colorCO = Colors.green;
                        } else if (finalCountCO >= 0.51 &&
                            finalCountCO <= 0.75) {
                          statusCO = 'Smokes Clear';
                          colorCO = Colors.green;
                        } else {
                          statusCO = 'Smokes Detected';
                          colorCO = Colors.red;
                        }

                        if (finalCountCO2 <= 0.25) {
                          colorCO2 = Colors.green;
                          statusCO2 = 'Smokes Clear';
                        } else if (finalCountCO2 >= 0.25 &&
                            finalCountCO2 <= 0.5) {
                          statusCO2 = 'Smokes Clear';
                          colorCO2 = Colors.green;
                        } else if (finalCountCO2 >= 0.5 &&
                            finalCountCO2 <= 0.75) {
                          statusCO2 = 'Smokes Clear';
                          colorCO2 = Colors.green;
                        } else {
                          statusCO2 = 'Smokes Detected';
                          colorCO2 = Colors.red;
                        }

                        return Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: Column(
                              children: [
                                FittedBox(
                                  child: Text(
                                      snapshot.data != null
                                          ? 'Bilik  ${smokes[index].bilik}'
                                          : '...',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Mont Bold')),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CircularPercentIndicator(
                                        header: const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 0, 0, 10),
                                            child: FittedBox(
                                              child: Text(
                                                'CO',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontFamily: 'Mont Bold'),
                                              ),
                                            )),
                                        footer: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 0),
                                          child: FittedBox(
                                            child: Text(
                                              statusCO,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontFamily: 'Mont Bold'),
                                            ),
                                          ),
                                        ),
                                        center: FittedBox(
                                          child: Text(
                                            '${((snapshot.data != null ? smokes[index].co <= thresholdco ? smokes[index].co / thresholdco as double : 1 : 0) * 100).toStringAsFixed(2)}%',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Mont'),
                                          ),
                                        ),
                                        radius: 60.0,
                                        lineWidth: 13.0,
                                        animation: true,
                                        animationDuration: 1000,
                                        percent: snapshot.data != null
                                            ? smokes[index].co <= thresholdco
                                                ? smokes[index].co / thresholdco
                                                : 1
                                            : 0,
                                        backgroundColor: Colors.white,
                                        progressColor: colorCO,
                                        circularStrokeCap:
                                            CircularStrokeCap.round,
                                      ),
                                    ),
                                    Expanded(
                                      child: CircularPercentIndicator(
                                        footer: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 0),
                                          child: FittedBox(
                                            child: Text(
                                              statusCO2,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontFamily: 'Mont Bold'),
                                            ),
                                          ),
                                        ),
                                        header: const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 0, 0, 10),
                                            child: FittedBox(
                                              child: Text(
                                                'CO2',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontFamily: 'Mont Bold'),
                                              ),
                                            )),
                                        radius: 60.0,
                                        lineWidth: 13.0,
                                        animation: true,
                                        animationDuration: 1000,
                                        percent: snapshot.data != null
                                            ? smokes[index].co2 < thresholdco2
                                                ? smokes[index].co2 /
                                                    thresholdco2
                                                : 1
                                            : 0,
                                        center: FittedBox(
                                          child: Text(
                                            '${((snapshot.data != null ? smokes[index].co2 <= thresholdco2 ? smokes[index].co2 / thresholdco2 as double : 1 : 0) * 100).toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Mont'),
                                          ),
                                        ),
                                        backgroundColor: Colors.white,
                                        progressColor: colorCO2,
                                        circularStrokeCap:
                                            CircularStrokeCap.round,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ));
                      },
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Keterangan :',
                  style: TextStyle(
                      fontFamily: 'Mont Bold', fontWeight: FontWeight.bold),
                ),
                Text(
                  '0 - 75% : Tidak Terindikasi Ada Asap',
                  style: TextStyle(
                      fontFamily: 'Mont', fontWeight: FontWeight.bold),
                ),
                Text(
                  '75 - 100% : Terindikasi Ada Asap',
                  style: TextStyle(
                      fontFamily: 'Mont', fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
      //History
      SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 40,
            ),
            Text(' Data History',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                DateTime? datetime = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now());

                                if (datetime != null) {
                                  datecontroler.text =
                                      DateFormat('dd-MM-yyyy').format(datetime);
                                  setState(() {
                                    dateSearch = datetime;
                                  });
                                }
                              },
                              child: TextField(
                                  enabled: false,
                                  controller: datecontroler,
                                  keyboardType: TextInputType.datetime,
                                  style: const TextStyle(color: Colors.black87),
                                  decoration: InputDecoration(
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade800,
                                              width: 1.5)),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade800,
                                              width: 2.0)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20),
                                      suffixIcon: const Icon(
                                        Icons.calendar_month_outlined,
                                        color: Color(0xff545454),
                                      ),
                                      hintText: 'Search by date',
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .labelSmall)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    datecontroler.clear();
                                  });
                                  ;
                                },
                                icon: const Icon(Icons.clear_rounded,
                                    color: Colors.white)),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(25)),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
                child: StreamBuilder(
              stream: FirestoreServices.fetchSmokes(),
              builder: (context, snapshot) {
                print(snapshot.connectionState);
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.connectionState == ConnectionState.done ||
                    snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    final List<Smoke> smokes;

                    smokes = snapshot.data!.docs
                        .map((e) => Smoke.fromSnapshot(e))
                        .where((element) {
                      if (datecontroler.text.isNotEmpty) {
                        return DateUtils.dateOnly(element.timestamp.toDate()) ==
                            DateUtils.dateOnly(dateSearch!);
                      } else {
                        return true;
                      }
                    }).toList();

                    return ListView.builder(
                      itemCount: smokes.length,
                      itemBuilder: (context, index) {
                        return Stack(children: [
                          Container(
                            decoration: BoxDecoration(
                                border: Border(
                              top: BorderSide(
                                  color: Colors.grey.shade800, width: 1),
                            )),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 20),
                              child: Row(children: [
                                Icon(
                                  Icons.warning_rounded,
                                  color: Colors.grey.shade800,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Ada Perokok !!!',
                                        style:
                                            TextStyle(fontFamily: 'Mont Bold')),
                                    Text(
                                        'Terdeteksi Asap di Bilik ${smokes[index].bilik}',
                                        style:
                                            const TextStyle(fontFamily: 'Mont'))
                                  ],
                                ),
                              ]),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 10, bottom: 10),
                              child: Text(
                                  timeago.format(
                                      (smokes[index].timestamp).toDate(),
                                      locale: 'en_short'),
                                  style: const TextStyle(fontFamily: 'Mont')),
                            ),
                          )
                        ]);
                      },
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text('Data belum tersedia'));
                  }
                }
                return Container();
              },
            ))
          ],
        ),
      ),
    ];

    return SafeArea(
        child: Scaffold(
      body: widgets[currentIndex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Color.fromARGB(255, 66, 66, 66),
        color: Colors.white,
        style: TabStyle.textIn,
        items: [
          const TabItem(
            icon: Icons.home_rounded,
            title: 'Home',
            fontFamily: 'Mont Bold',
          ),
          const TabItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              fontFamily: 'Mont Bold'),
          const TabItem(
              icon: Icons.history_rounded,
              title: 'History',
              fontFamily: 'Mont Bold'),
        ],
        onTap: (int i) {
          setState(() {
            currentIndex = i;
          });
        },
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
