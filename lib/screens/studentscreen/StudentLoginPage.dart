// login_page.dart
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hallmeal/screens/studentscreen/StudentSignUpPage.dart';
import '../adminscreen/AdminLoginPage.dart';
import 'package:hallmeal/services/AuthService.dart';
import '../studentscreen/StudentSignUpPage.dart';

class StudentloginPage extends StatelessWidget {
  const StudentloginPage({super.key});

  // Loading time
  Duration get loadingTime => const Duration(milliseconds: 2000);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // FlutterLogin section (unchanged)
          FlutterLogin(
            onLogin: (LoginData data) => authUser(data),
            onRecoverPassword: (String email) => recoverPassword(email),
            onSignup: (SignupData data) => signUp(data),
          ),

          // "STUDENT PAGE" label (unchanged)
          Positioned(
            top: 80,
            left: 80,
            child: Theme(
              data: ThemeData(
                primarySwatch: Colors.blue, // Assuming your primary color is blue
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  color: Colors.transparent, // Make container transparent
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.8), // Darker shade of primary color
                    width: 5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.7),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'STUDENT PAGE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor, // Use primary color for text
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Add the Admin Login button as a floating button
          Positioned(
            bottom: 20.0, // Adjust position as needed
            right: 20.0, // Adjust position as needed
            child: Theme(
              data: ThemeData(
                primarySwatch: Colors.blue, // Assuming your primary color is blue
                canvasColor: Colors.lightBlue, // Assuming your accent color is lightBlue
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Get.to(AdminloginPage());
                },
                icon: Icon(Icons.school_outlined, color: Theme.of(context).canvasColor),
                label: Text(
                  'Admin Login',
                  style: TextStyle(color: Theme.of(context).canvasColor),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                    color: Color(0xFF080808), // Darker shade of blue using hex code
                    width: 2.0, // Set the border width
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}