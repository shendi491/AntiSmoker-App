import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/smoke.dart';
import '../services/firestore_services.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  TextEditingController datecontroler = TextEditingController();
  DateTime? dateSearch;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 50,
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
                                        borderRadius: BorderRadius.circular(50),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade800,
                                            width: 1.5)),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(50),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade800,
                                            width: 2.0)),
                                    contentPadding: const EdgeInsets.symmetric(
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
    );
  }
}
