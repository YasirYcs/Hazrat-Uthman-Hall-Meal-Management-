// login_page.dart
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hallmeal/screens/studentscreen/StudentSignUpPage.dart';
import '../adminscreen/AdminLoginPage.dart';
import 'package:hallmeal/services/AuthService.dart';
import '../studentscreen/StudentSignUpPage.dart';
 // Import the new BottomBar widget

class Studentloginpage extends StatelessWidget {
  const Studentloginpage({super.key});

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
              onLogin:  (LoginData data) => authUser (data),
              onRecoverPassword: (String email) => recoverPassword(email),
              onSignup: (SignupData data) => signUp(data),

            ),
            // Inside your Loginpage widget, add the following code for the Admin Login button
            Positioned(
              bottom: 200,
              left: 120,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the AdminLogin page using Get.to
                  Get.to(Adminloginpage());
                },
                child: Text('Admin Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Set the background color of the button
                  foregroundColor: Colors.white, // Set the text color
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Button padding
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
                ),
              ),
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
                    'STUDENT PAGE',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            // Add the BottomBar widget here
            // Pass the size to the BottomBar
          ],
        ),
      ),
    );
  }
}