import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../screens/studentscreen/StudenHomePage.dart';
import 'package:flutter_login/flutter_login.dart';
import '../screens/studentscreen/StudentLoginPage.dart';
import '../screens/adminscreen/AdminMenu.dart';

// User Log in
Future<String?> authUser (LoginData data) async {
  try {
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
    String userEmail = user?.email ?? 'Email not available';
    String userName = user?.displayName ?? 'Name not available'; // If you have a display name
    // Show login success message using Snackbar
    Get.snackbar(
      'Login Successful',
      'Welcome, $userEmail',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
    await Future.delayed(Duration(seconds: 2));

    Get.off(StudentHomePage());
    return null; // Return user ID on successful login
  } catch (e) {
    return e.toString(); // Return error message
  }
}


//Admin Login in

Future<String?> authAdmin (LoginData data) async {
  try {
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
    String userEmail = user?.email ?? 'Email not available';
    String userName = user?.displayName ?? 'Name not available'; // If you have a display name
    // Show login success message using Snackbar
    Get.snackbar(
      'Login Successful',
      'Welcome, $userEmail',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
    await Future.delayed(Duration(seconds: 2));

    Get.off(AdminMenu());
    return null; // Return user ID on successful login
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

// Sign up
Future<String?> signUp(SignupData data) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: data.name!, // Assuming SignupData has an email field
      password: data.password!, // Assuming SignupData has a password field
    );

    // Get user details
    User? user = userCredential.user;

    // Send verification email
    await user?.sendEmailVerification();

    String userEmail = user?.email ?? 'Boss';
    String userName = user?.displayName ?? 'Boss'; // If you have a display name

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
    Get.off(Studentloginpage()); // Ensure LoginPage is correctly referenced
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