import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'RegistScreen.dart';
import 'ForgotScreen.dart';
import 'Autentikasi.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool filled = false;
  var _isObscured;
  @override
  void initState() {
    emailController.addListener(() {
      if (emailController.text.isNotEmpty) {
        setState(() {
          filled = true;
        });
      }
      if (emailController.text.isEmpty) {
        setState(() {
          filled = false;
        });
      }
    });
    super.initState();
    print(filled);
    _isObscured = true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 40),
                  Text('AntiSmoker',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/images/Logo.png',
                    height: 165.6,
                    width: 165.6,
                  ),
                  const SizedBox(height: 30),
                  buildEmail(context),
                  const SizedBox(height: 10),
                  buildPassword(context),
                  const SizedBox(height: 20),
                  buildLoginbtn(),
                  const SizedBox(height: 5),
                  buildForgotPassbtn(context),
                  buildRegisterbtn(context)
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
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 11),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade800, width: 3)),
          height: 50,
          child: TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 10),
                prefixIcon: const Icon(
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

  Widget buildPassword(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 11),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade800, width: 3)),
          height: 50,
          child: TextFormField(
            controller: passwordController,
            obscureText: _isObscured,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 12),
                suffixIcon: IconButton(
                    icon: _isObscured
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    }),
                prefixIcon: const Icon(
                  Icons.lock_outlined,
                  color: Color(0xff545454),
                ),
                hintText: 'Password',
                hintStyle: Theme.of(context).textTheme.labelSmall),
          ),
        )
      ],
    );
  }

  Widget buildLoginbtn() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 11),
      width: double.infinity,
      child: ElevatedButton(
        child: const Text('Login'),
        onPressed: !filled
            ? null
            : () async {
                try {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: Colors.white,
                      ));
                    },
                  );
                  UserCredential userCredential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text)
                      .then((value) async {
                    CollectionReference firestoreTokens =
                        FirebaseFirestore.instance.collection('tokens');
                    String? thisDeviceToken =
                        await FirebaseMessaging.instance.getToken();

                    var tokens = await firestoreTokens
                        .where('fcm_tokens', isEqualTo: thisDeviceToken)
                        .get();

                    if (tokens.size < 1) {
                      await firestoreTokens.add({
                        'fcm_tokens':
                            await FirebaseMessaging.instance.getToken()
                      });
                    }
                    return value;
                  });

                  if (userCredential.user!.emailVerified) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Autentikasi()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                      'Email Belum Terverifikasi',
                      textAlign: TextAlign.center,
                    )));
                    Navigator.pop(context);
                  }
                } on FirebaseAuthException catch (e) {
                  print(e.code);
                  Navigator.pop(context);
                  if (e.code == 'user-not-found') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                      'User Tidak Ditemukan',
                      textAlign: TextAlign.center,
                    )));
                  } else if (e.code == 'wrong-password') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                      'Password Salah',
                      textAlign: TextAlign.center,
                    )));
                  }
                }
              },
        style: ElevatedButton.styleFrom(
            elevation: 5,
            padding: const EdgeInsets.all(15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            primary: Colors.grey.shade800,
            onPrimary: Colors.white,
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Mont Bold',
            )),
      ),
    );
  }

  Widget buildForgotPassbtn(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return ForgotScreen();
            },
          ));
        },
        child: Text(
          'Forgot Password?',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }

  Widget buildRegisterbtn(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: "Don't have any account ?",
              style: Theme.of(context).textTheme.labelMedium),
          TextSpan(
              text: ' Sign Up',
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                  fontFamily: 'Mont Bold',
                  color: Colors.grey.shade800),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return RegistScreen();
                    },
                  ));
                })
        ]),
      ),
    );
  }
}
