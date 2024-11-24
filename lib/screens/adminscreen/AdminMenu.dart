import 'package:flutter/material.dart';
import 'package:hallmeal/screens/adminscreen/AdminLoginPage.dart';
import 'package:hallmeal/screens/adminscreen/Bazar/BazarEntry.dart';
import 'package:hallmeal/screens/adminscreen/Meal/MealRequests.dart';
import 'package:hallmeal/screens/adminscreen/Meal/MelaMenu.dart';
import 'package:hallmeal/screens/adminscreen/Noticeboard/SendNotice.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AdminMenu extends StatefulWidget {
  @override
  _AdminMenuState createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu> {
  String _formattedDateTime = '';
  String? _fullName;
  String? _studentId;

  @override
  void initState() {
    super.initState();
    _startDateTimeUpdates();
    _fetchStudentFullName();
  }

  void _startDateTimeUpdates() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _formattedDateTime =
            DateFormat('dd/MM/yyyy - hh:mm:ss a').format(DateTime.now());
      });
    });
  }

  //admin logout
// Logout function
  Future<void> adminlogout(BuildContext context) async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Navigate to the login page after logout
      Get.off(AdminloginPage()); // Ensure LoginPage is correctly referenced
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

  Future<void> _fetchStudentFullName() async {
    try {
      User? currentUser  = FirebaseAuth.instance.currentUser ;
      if (currentUser  == null) {
        throw Exception('No user is logged in.');
      }

      String uid = currentUser .uid;
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance.collection('students').doc(uid).get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data();
        setState(() {
          _fullName = data?['fullName'] ?? 'Unknown User';
          _studentId = data?['studentId'] ?? 'Unknown ID';
        });
      } else {
        throw Exception('No document found for UID: $uid');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      setState(() {
        _fullName = 'Unknown User';
        _studentId = 'Unknown ID';
      });
    }
  }

  void logout(BuildContext context) async {
    // Show a confirmation dialog before logging out
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        Get.offAllNamed('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(title),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hall Meal Management System IIUC'),
        backgroundColor: Colors.purple,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/photos/Pradduman.png', height: 40),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple),
              child: Text(
                'Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            _buildDrawerItem(Icons.fastfood, 'Set Meal Menu', () {
              Get.to(MealMenu());
            }),
            Divider(),
            _buildDrawerItem(Icons.list, 'Bazars Entry ', () {
              Get.to(BazarEntry(username: _fullName ?? 'User '));
            }),
            Divider(),
            _buildDrawerItem(Icons.request_page_outlined, 'Meal Requests', () {
              Get.to(MealEntry());
            }),
            Divider(),
            _buildDrawerItem(Icons.newspaper_rounded, 'Send Notice', () {
              Get.to(SendNotice());
            }),
            Divider(),
            _buildDrawerItem(Icons.logout, 'Logout', () => adminlogout(context)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 150,
            color: Colors.purple,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/photos/Pradduman.png'),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fullName ?? 'Unknown User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _studentId ?? 'Unknown ID',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Date and Time Block
                Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Live Date and Time:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Center(
                          child: Text(
                            _formattedDateTime,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildInfoBlock('Meal Rate', '\$10.00'),
                _buildInfoBlock('Total Meal', '100'),
                _buildInfoBlock('Total Bazar', '\$500.00'),
                _buildInfoBlock('Total Students', '200'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock(String title, String value) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}