// ignore_for_file: avoid_print

import 'package:AntiSmoker/pages/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgotScreen extends StatefulWidget {
  @override
  _ForgotScreenState createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final TextEditingController forgotPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Color(0xffffffff),
                  Color(0xffffffff),
                  Color(0xccffffff),
                  Color(0x99ffffff),
                ])),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 40),
                  Text('AntiSmoker',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 30),
                  Image.asset(
                    'assets/images/lock.png',
                    height: 135.6,
                    width: 135.6,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Enter your email and we\'ll send you a link to change a new password',
                    style: Theme.of(context).textTheme.labelLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  buildEmail(context),
                  SizedBox(height: 20),
                  buildLoginbtn(context),
                  SizedBox(height: 20),
                  buildSendbtn(),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget buildEmail(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 11),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade800, width: 3)),
          height: 50,
          child: TextFormField(
            controller: forgotPasswordController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 10),
                prefixIcon: Icon(
                  Icons.mail_outlined,
                  color: Color(0xff545454),
                ),
                hintText: 'Email',
                hintStyle: Theme.of(context).textTheme.labelSmall),
          ),
        )
      ],
    );
  }

  Widget buildSendbtn() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 11),
      width: double.infinity,
      child: ElevatedButton(
        child: Text('Send Email'),
        onPressed: () async {
          var forgotEmail = forgotPasswordController.text.trim();

          try {
            await FirebaseAuth.instance
                .sendPasswordResetEmail(email: forgotEmail)
                .then((value) => {
                      print("Email Sent!"),
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                        'Email Sudah Terkirim!',
                        textAlign: TextAlign.center,
                      ))),
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()))
                    });
          } on FirebaseAuthException catch (e) {
            print(e.code);
            if (e.code == 'user-not-found') {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                'Email tidak terdaftar',
                textAlign: TextAlign.center,
              )));
            } else if (forgotPasswordController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                'Email masih kosong!',
                textAlign: TextAlign.center,
              )));
            }
          }
        },
        style: ElevatedButton.styleFrom(
            elevation: 5,
            padding: EdgeInsets.all(15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            primary: Colors.grey.shade800,
            onPrimary: Colors.white,
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Mont Bold',
            )),
      ),
    );
  }

  Widget buildLoginbtn(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: "Remember your password ?",
              style: Theme.of(context).textTheme.labelMedium),
          TextSpan(
              text: ' Log in',
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Mont Bold',
                  color: Colors.grey.shade800),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).pop();
                })
        ]),
      ),
    );
  }
}
