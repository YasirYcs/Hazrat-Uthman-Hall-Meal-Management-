import 'package:flutter/material.dart';
import 'package:hallmeal/screens/adminscreen/Bazar/BazarEntry.dart';
import 'package:hallmeal/screens/adminscreen/Meal/MelaMenu.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminMenu extends StatefulWidget {
  @override
  _AdminMenuState createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu> {
  String _formattedDateTime = '';

  void logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Optionally, navigate to the login screen after logout
      Get.offAllNamed('/login'); // Adjust the route name as per your app's routing
    } catch (e) {
      // Handle any errors that occur during logout
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    // Update the time every second
    Future.delayed(Duration(seconds: 1), _updateDateTime);
  }

  void _updateDateTime() {
    setState(() {
      _formattedDateTime = DateFormat('dd/MM/yyyy - hh:mm:ss a').format(DateTime.now());
    });
    Future.delayed(Duration(seconds: 1), _updateDateTime);
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
            child: Image.asset('assets/photos/Pradduman.png', height: 40), // Replace with your logo path
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildDrawerItem(Icons.fastfood, 'Meal Menu', () {
              Get.to(MealMenu(username: 'Sheikh Praddyuman'));
            }),
            Divider(),
            _buildDrawerItem(Icons.list, 'Bazars Entry', () {
              Get.to(BazarEntry(username: 'Sheikh Praddyuman'));
            }),
            Divider(),
            _buildDrawerItem(Icons.add, 'Meal Entry', () {
              // Navigate to Meal Entry
            }),
            Divider(),
            _buildDrawerItem(Icons.person, 'Profile', () {
              // Navigate to Profile
            }),
            Divider(),
            _buildDrawerItem(Icons.info, 'Tips and Updates', () {
              // Navigate to Tips and Updates
            }),
            Divider(),
            _buildDrawerItem(Icons.share, 'Share App', () {
              // Share app functionality
            }),
            Divider(),
            _buildDrawerItem(Icons.info_outline, 'About Us', () {
              // Navigate to About Us
            }),
            Divider(),
            _buildDrawerItem(Icons.logout, 'Logout', () => logout(context)), // Calls the logout function
          ],
        ),
      ),
      body: Column(
        children: [
          // Top Container for Username and Profile Picture
          Container(
            height: 150,
            color: Colors.purple,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/photos/Pradduman.png'), // Replace with your profile picture path
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sheikh Paddyuman', // Replace with dynamic username
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'cid.iiuc@ycs.com', // Replace with dynamic email
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
          // Status Container
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
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Date and Time Block
                Container(
                  padding: EdgeInsets.all(10),
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
                      Text(
                        'Live Date and Time:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formattedDateTime,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                // Meal Rate Block
                _buildInfoBlock('Meal Rate', '\$10.00'),
                // Total Meal Block
                _buildInfoBlock('Total Meal', '100'),
                // Total Bazar Block
                _buildInfoBlock('Total Bazar', '\$500.00'),
                // Total Students Block
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