import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hallmeal/screens/studentscreen/StudentPage.dart';
import 'package:flutter_login/flutter_login.dart';
import '../screens/studentscreen/StudentLoginPage.dart';
import '../screens/adminscreen/Home/AdminMenu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> authUser (LoginData data) async {
  try {
    // Sign in the user
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: data.name, // Assuming LoginData has an email field
      password: data.password, // Assuming LoginData has a password field
    );

    // Get user details
    User? user = userCredential.user;

    // Check if the email is verified
    if (user != null && !user.emailVerified) {
      return 'Please verify your email before logging in.';
    }

    // Fetch user role from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

    if (userDoc.exists) {
      String userEmail = user.email ?? 'Email not available';
      String role = userDoc['role']; // Get the role from Firestore

      // Check if the user is a student
      if (role == 'student') {
        // Show login success message using Snackbar
        Get.snackbar(
          'Login Successful',
          'Welcome, $userEmail',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );

        await Future.delayed(Duration(seconds: 2));

        Get.off(StudentPage()); // Navigate to StudentPage
      } else {
        return 'You are not registered as a student.';
      }
    } else {
      return 'User  document does not exist.';
    }

    return null; // Return null on successful login
  } catch (e) {
    return e.toString(); // Return error message
  }
}


//Admin Login in

Future<String?> authAdmin (LoginData data) async {
  try {
    // Sign in the user
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: data.name, // Assuming LoginData has an email field
      password: data.password, // Assuming LoginData has a password field
    );

    // Get user details
    User? user = userCredential.user;

    // Check if the email is verified
    if (user != null && !user.emailVerified) {
      return 'Please verify your email before logging in.';
    }

    // Fetch user role from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

    if (userDoc.exists) {
      String userEmail = user.email ?? 'Email not available';
      String role = userDoc['role']; // Get the role from Firestore

      // Check if the user is a student
      if (role == 'admin') {
        // Show login success message using Snackbar
        Get.snackbar(
          'Login Successful As an Admin',
          'Welcome, $userEmail',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );

        await Future.delayed(Duration(seconds: 2));

        Get.off(AdminMenu()); // Navigate to StudentPage
      } else {
        return 'You are not registered as a Admin';
      }
    } else {
      return 'Admin Details does not exist.';
    }

    return null; // Return null on successful login
  } catch (e) {
    return e.toString(); // Return error message
  }
}



// Forgot password
Future<String?> recoverPassword(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    return 'Password reset email sent!'; // Success message
  } catch (e) {
    return e.toString(); // Return error message
  }
}

Future<String?> signUp(SignupData data) async {
  try {
    // Create user with email and password
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: data.name!, // Assuming SignupData has an email field
      password: data.password!, // Assuming SignupData has a password field
    );

    // Get user details
    User? user = userCredential.user;

    // Send verification email
    await user?.sendEmailVerification();

    // Store user role as 'student' in Firestore
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'email': user.email,
      'role': 'student', // Hardcoded role as 'student'
    });

    String userEmail = user.email ?? 'Boss';

    return 'SignUp successful: $userEmail. A verification email has been sent to your email address.'; // Return user ID on successful sign-up
  } catch (e) {
    return e.toString(); // Return error message
  }
}


// Logout function
Future<void> logout(BuildContext context) async {
  try {
    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Navigate to the login page after logout
    Get.off(StudentloginPage()); // Ensure LoginPage is correctly referenced
  } catch (e) {
    // Handle logout error
    print('Error logging out: $e');
    // Optionally, you can show a Snackbar or dialog to inform the user
    Get.snackbar(
      'Logout Error',
      'An error occurred while logging out. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }
}
