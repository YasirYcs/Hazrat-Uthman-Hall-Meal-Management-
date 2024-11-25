import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hallmeal/screens/aboutpage.dart';
import 'package:hallmeal/screens/studentscreen/MealBook/MealBook.dart';
import 'package:hallmeal/screens/studentscreen/MealStatus/MealStatus.dart';
import 'package:hallmeal/screens/studentscreen/Notice/Notice.dart';
import 'package:hallmeal/screens/studentscreen/Profile/StudentProfile.dart';
import 'package:hallmeal/screens/studentscreen/StudentLoginPage.dart';
import 'package:lottie/lottie.dart';
import 'Prayer.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({Key? key}) : super(key: key);

  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  User? user = FirebaseAuth.instance.currentUser;
  String welcomeMessage = 'Welcome!';
  Future<void>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        String uid = user!.uid;
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('students')
            .doc(uid)
            .get();

        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>?; // Typecasting
          setState(() {
            welcomeMessage = 'Welcome, ${data?['fullName'] ?? 'Student'}!';
          });
        } else {
          print('User data not found');
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    } else {
      print('No authenticated user found.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFFf504172),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              logout(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger a refresh when the user pulls down
          await _fetchUserData(); // Call to refresh user data
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              FutureBuilder<void>(
                future: _userDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      margin: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          welcomeMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              const Divider(
                thickness: 2,
                color: Colors.grey,
                height: 20,
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2, // Increase the number of tiles in each row
                  mainAxisSpacing: 1, // Reduce vertical spacing between tiles
                  crossAxisSpacing: 4, // Reduce horizontal spacing between tiles
                  childAspectRatio: 1.05, // Adjust height and width
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(() => MealBook());
                      },
                      child: _buildGridTile('assets/photos/meals.json', 'Book Meal'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => MealStatus());
                      },
                      child: _buildGridTile('assets/photos/MealStatus.json', 'Meal Status'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => Notice());
                      },
                      child: _buildGridTile('assets/photos/to do.json', 'Notice'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => PrayerTimesPage());
                      },
                      child: _buildGridTile('assets/photos/Prayer.json', 'Prayer'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => StudentProfile());
                      },
                      child: _buildGridTile('assets/photos/dashboard.json', 'Profile'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => AboutPage());
                      },
                      child: _buildGridTile('assets/photos/AboutMe.json', 'About Me'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridTile(String assetPath, String label) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFf504172),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Lottie.asset(assetPath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
