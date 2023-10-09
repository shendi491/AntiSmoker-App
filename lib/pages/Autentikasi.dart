import 'package:AntiSmoker/pages/MainApp.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class Autentikasi extends StatefulWidget {
  const Autentikasi({super.key});

  @override
  State<Autentikasi> createState() => _Autentikasi();
}

class _Autentikasi extends State<Autentikasi> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool _isBiometricAvailable = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    checkBiometricAvailability();
  }

  Future<void> checkBiometricAvailability() async {
    bool isBiometricAvailable = await _localAuthentication.canCheckBiometrics;
    setState(() {
      _isBiometricAvailable = isBiometricAvailable;
    });
  }

  Future<void> authenticate() async {
    bool isAuthenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_isBiometricAvailable) {
        isAuthenticated = await _localAuthentication.authenticate(
          localizedReason: 'Authenticate using biometric',
          options: AuthenticationOptions(
              useErrorDialogs: true, stickyAuth: true, biometricOnly: false),
        );
      }

      setState(() {
        _isAuthenticating = false;
      });

      if (isAuthenticated) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return MainApp();
          },
        ));
      }
    } catch (e) {
      print('Error during authentication: $e');
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

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
              const SizedBox(height: 40),
              Text('AntiSmoker',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 10),
              Image.asset('assets/images/Logo.png', height: 165.6),
              const SizedBox(height: 50),
              Text('Authenticate Yourself',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(
                height: 20,
              ),
              IconButton(
                  iconSize: 130,
                  onPressed: _isAuthenticating ? null : authenticate,
                  icon: Image.asset('assets/images/finger.png')),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
