import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MealMenu extends StatefulWidget {
  @override
  _MealMenuState createState() => _MealMenuState();
}

class _MealMenuState extends State<MealMenu> {
  final TextEditingController _breakfastController = TextEditingController();
  final TextEditingController _lunchController = TextEditingController();
  final TextEditingController _dinnerController = TextEditingController();
  String _formattedDateTime = '';
  String _username = 'Loading...';
  String _currentDate = '';
  String breakfastMenu = "No Ready Yet";
  String lunchMenu = "No Ready Yet";
  String dinnerMenu = "No Ready Yet";

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref().child('meal_menu');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    Future.delayed(Duration(seconds: 1), _updateDateTime);
    _fetchUserData();
    _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    fetchMealData(_currentDate);
  }

  Future<void> _fetchUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      DocumentSnapshot userDoc = await _firestore.collection('students').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('fullName')) {
          setState(() {
            _username = userData['fullName'];
          });
        } else {
          setState(() {
            _username = 'User data incomplete';
          });
        }
      } else {
        setState(() {
          _username = 'User not found';
        });
      }
    } catch (e) {
      setState(() {
        _username = 'Error fetching user data';
      });
    }
  }

  void _updateDateTime() {
    setState(() {
      _formattedDateTime = DateFormat('dd/MM/yyyy - hh:mm:ss a').format(DateTime.now());
    });
    Future.delayed(Duration(seconds: 1), _updateDateTime);
  }

  Future<void> fetchMealData(String date) async {
    try {
      DatabaseReference mealRef = _databaseReference.child(date);
      DataSnapshot snapshot = await mealRef.get();
      if (snapshot.exists && snapshot.value != null) {
        Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          breakfastMenu = data['breakfast'] ?? "No Ready Yet";
          lunchMenu = data['lunch'] ?? "No Ready Yet";
          dinnerMenu = data['dinner'] ?? "No Ready Yet";
        });
      } else {
        setState(() {
          breakfastMenu = "No Ready Yet";
          lunchMenu = "No Ready Yet";
          dinnerMenu = "No Ready Yet";
        });
      }
    } catch (e) {
      print('Error fetching meal data: $e');
      setState(() {
        breakfastMenu = "Error loading breakfast";
        lunchMenu = "Error loading lunch";
        dinnerMenu = "Error loading dinner";
      });
    }
  }

  void _submitMealMenu() {
    String breakfast = _breakfastController.text;
    String lunch = _lunchController.text;
    String dinner = _dinnerController.text;

    if (breakfast.isNotEmpty || lunch.isNotEmpty || dinner.isNotEmpty) {
      _databaseReference.child(_currentDate).set({
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner,
        'submittedAt': _formattedDateTime,
      }).then((_) {
        setState(() {
          // Clear the input fields
          _breakfastController.clear();
          _lunchController.clear();
          _dinnerController.clear();
        });
        fetchMealData(_currentDate); // Refresh the meal data after submission
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meal menu submitted successfully!')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit meal menu')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter at least one meal option')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Menu', textAlign: TextAlign.center),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.teal,  // Teal color theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal[100],  // Light teal background
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $_username!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal[800]),  // Dark teal text
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Please enter your meal options below.',
                      style: TextStyle(fontSize: 16, color: Colors.teal[600]),  // Medium teal text
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(thickness: 2),
              ),

              // Meal Input Container
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal[100],  // Light teal background
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Current Date and Time\n $_formattedDateTime',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildMealInputField('Breakfast', _breakfastController),
                    SizedBox(height: 10),
                    _buildMealInputField('Lunch', _lunchController),
                    SizedBox(height: 10),
                    _buildMealInputField('Dinner', _dinnerController),
                    SizedBox(height: 20),

                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,  // Teal button color
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 20),
                        ),
                        onPressed: _submitMealMenu,
                        child: Text('Update', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Divider(thickness: 2),
              SizedBox(height: 10),
              // Submitted Meal Options
              _buildInfoCard('Submitted Meal Options',
                  'Breakfast: $breakfastMenu\nLunch: $lunchMenu\nDinner: $dinnerMenu'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealInputField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal[100],  // Light teal background
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[800]),
          ),
          SizedBox(height: 10),
          Text(content, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
