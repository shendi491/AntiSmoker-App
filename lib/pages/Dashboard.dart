import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../components/constant.dart';
import '../models/smoke.dart';
import '../services/firestore_services.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
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
                      Smoke(bilik: 1, co: 0, co2: 0, timestamp: Timestamp.now())
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
                            bilik: 1, co: 0, co2: 0, timestamp: Timestamp.now())
                      ]);
                    }
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                        statusCO = 'Baik';
                        colorCO = Colors.green;
                      } else if (finalCountCO >= 0.26 && finalCountCO <= 0.5) {
                        statusCO = 'Cukup Baik';
                        colorCO = Colors.yellow;
                      } else if (finalCountCO >= 0.51 && finalCountCO <= 0.75) {
                        statusCO = 'Kurang Baik';
                        colorCO = Colors.orange;
                      } else {
                        statusCO = 'Buruk';
                        colorCO = Colors.red;
                      }
                      if (finalCountCO2 <= 0.25) {
                        colorCO2 = Colors.green;
                        statusCO2 = 'Baik';
                      } else if (finalCountCO2 >= 0.25 &&
                          finalCountCO2 <= 0.5) {
                        statusCO2 = 'Cukup Baik';
                        colorCO2 = Colors.yellow;
                      } else if (finalCountCO2 >= 0.5 &&
                          finalCountCO2 <= 0.75) {
                        statusCO2 = 'Kurang Baik';
                        colorCO2 = Colors.orange;
                      } else {
                        statusCO2 = 'Buruk';
                        colorCO2 = Colors.red;
                      }

                      return Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20))),
                          child: Column(
                            children: [
                              Text(
                                  snapshot.data != null
                                      ? 'Bilik ${smokes[index].bilik}'
                                      : '...',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Mont Bold')),
                              Row(
                                children: [
                                  Expanded(
                                    child: CircularPercentIndicator(
                                      footer: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 10, 0, 0),
                                        child: Text(
                                          statusCO,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: 'Mont Bold'),
                                        ),
                                      ),
                                      header: const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 10),
                                          child: Text(
                                            'CO',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontFamily: 'Mont Bold'),
                                          )),
                                      radius: 60.0,
                                      lineWidth: 13.0,
                                      animation: true,
                                      animationDuration: 1000,
                                      percent: snapshot.data != null
                                          ? smokes[index].co <= thresholdco
                                              ? smokes[index].co / thresholdco
                                              : 1
                                          : 0,
                                      center: Text(
                                        '${((snapshot.data != null ? smokes[index].co <= thresholdco ? smokes[index].co / thresholdco as double : 1 : 0) * 100).toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Mont'),
                                      ),
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
                                        child: Text(
                                          statusCO2,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: 'Mont Bold'),
                                        ),
                                      ),
                                      header: const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 10),
                                          child: Text(
                                            'CO2',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontFamily: 'Mont Bold'),
                                          )),
                                      radius: 60.0,
                                      lineWidth: 13.0,
                                      animation: true,
                                      animationDuration: 1000,
                                      percent: snapshot.data != null
                                          ? smokes[index].co2 < thresholdco2
                                              ? smokes[index].co2 / thresholdco2
                                              : 1
                                          : 0,
                                      center: Text(
                                        '${((snapshot.data != null ? smokes[index].co2 <= thresholdco2 ? smokes[index].co2 / thresholdco2 as double : 1 : 0) * 100).toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Mont'),
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
            ],
          ),
        ),
      ),
    );
  }
}
