import 'package:flutter_login/flutter_login.dart';
import 'package:flutter/material.dart';
import '../adminscreen/AdminLoginPage.dart';
import '../adminscreen/AdminMenu.dart';
import 'package:hallmeal/services/AuthService.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Adminloginpage extends StatelessWidget {
  const Adminloginpage({super.key});

// Loading time
  Duration get loadingTime => const Duration(milliseconds: 2000);


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [

            FlutterLogin(
              onLogin:  (LoginData data) => authAdmin (data),
              onRecoverPassword: (String email) => recoverPassword(email),
              onSignup: (SignupData data) => signUp(data),
            ),

            Positioned(
              top: 100,
              left: 40,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Center(
                  child: Text(
                    'ADMIN PAGE',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

}







