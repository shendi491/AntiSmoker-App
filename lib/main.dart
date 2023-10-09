import 'package:AntiSmoker/pages/MainApp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import './pages/LoginScreen.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: "smoke detection system",
      options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    print(user?.uid.toString());
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return MaterialApp(
      title: 'Flutter Login UI',
      debugShowCheckedModeBanner: false,
      home: user != null ? MainApp() : LoginScreen(),
      theme: ThemeData(
          textTheme: TextTheme(
            headlineLarge: TextStyle(
                fontFamily: 'Mont Bold',
                color: Colors.grey.shade800,
                fontSize: 42,
                fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(
                fontFamily: 'Mont Bold',
                color: Colors.grey.shade800,
                fontSize: 25,
                fontWeight: FontWeight.bold),
            headlineSmall: TextStyle(
                fontFamily: 'Mont ',
                color: Colors.grey.shade800,
                fontSize: 20,
                fontWeight: FontWeight.bold),
            labelSmall: TextStyle(
                fontFamily: 'Mont', color: Colors.grey.shade500, fontSize: 14),
            labelMedium: TextStyle(
                fontFamily: 'Mont',
                color: Colors.grey.shade800,
                fontSize: 15,
                fontWeight: FontWeight.bold),
            labelLarge: TextStyle(
              fontFamily: 'Mont Bold',
              color: Colors.grey.shade800,
              fontSize: 18,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  backgroundColor: Colors.grey.shade800))),
    );
  }
}
