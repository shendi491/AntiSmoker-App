import 'package:AntiSmoker/pages/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

class RegistScreen extends StatefulWidget {
  @override
  _RegistScreenState createState() => _RegistScreenState();
}

class _RegistScreenState extends State<RegistScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool isObscured = true;
  bool isSuccess = false;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

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
                  Text(
                    'Just one step you can see what\'s happened in the world',
                    style: TextStyle(
                      fontFamily: 'Mont',
                      fontSize: 18,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  buildEmail(context),
                  SizedBox(height: 10),
                  buildFullName(context),
                  SizedBox(height: 10),
                  buildPassword(context),
                  SizedBox(height: 30),
                  buildLoginbtn(context),
                  SizedBox(height: 20),
                  buildRegistbtn(),
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
            controller: emailController,
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

  Widget buildFullName(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 5),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 11),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade800, width: 3)),
          height: 50,
          child: TextFormField(
            controller: nameController,
            keyboardType: TextInputType.name,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 10),
                prefixIcon: Icon(
                  Icons.person_2_rounded,
                  color: Color(0xff545454),
                ),
                hintText: 'Full Name',
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
        SizedBox(height: 5),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 11),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade800, width: 3)),
          height: 50,
          child: TextFormField(
            controller: passwordController,
            obscureText: isObscured,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 12),
                suffixIcon: IconButton(
                    icon: isObscured
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        isObscured = !isObscured;
                      });
                    }),
                prefixIcon: Icon(
                  Icons.lock_outlined,
                  color: Color(0xff545454),
                ),
                hintText: 'Password',
                hintStyle: Theme.of(context).textTheme.labelSmall),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        FlutterPwValidator(
          controller: passwordController,
          uppercaseCharCount: 1,
          numericCharCount: 1,
          specialCharCount: 1,
          width: 400,
          height: 150,
          minLength: 8,
          onSuccess: () {
            setState(() {
              isSuccess = true;
            });
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Good Password")));
          },
          onFail: () {
            setState(() {
              isSuccess = false;
            });
          },
        )
      ],
    );
  }

  Widget buildRegistbtn() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 11),
      width: double.infinity,
      child: ElevatedButton(
        child: Text('Register'),
        onPressed: () async {
          try {
            UserCredential userCredential =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            );
            await userCredential.user!.sendEmailVerification();
            print('Registrasi berhasil: ${userCredential.user!.uid}');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
              'Cek Email untuk Verifikasi',
              textAlign: TextAlign.center,
            )));
          } on FirebaseAuthException catch (e) {
            print(e.code);
            if (e.code == 'email-already-in-use') {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                'Email Sudah Terdaftar',
                textAlign: TextAlign.center,
              )));
              print('Kesalahan: email sudah digunakan');
            } else if (emailController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Email masih kosong!',
                      textAlign: TextAlign.center)));
            } else if (nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text('Nama masih kosong!', textAlign: TextAlign.center)));
            } else if (passwordController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Password masih kosong!',
                      textAlign: TextAlign.center)));
            } else if (e.code == 'weak-password') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password terlalu lemah')),
              );
            }
          } catch (e) {
            print('Kesalahan: $e');
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
              text: "Have an account ?",
              style: Theme.of(context).textTheme.labelMedium),
          TextSpan(
              text: ' Log in',
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Mont Bold',
                  color: Colors.grey.shade800),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return LoginScreen();
                  }));
                })
        ]),
      ),
    );
  }
}
