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
  String _submittedData = '';
  String _username = 'Loading...';

  final _databaseReference = FirebaseDatabase.instance.ref().child('meal_menu');
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    Future.delayed(Duration(seconds: 1), _updateDateTime);
    _fetchUserData();
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
          print('Error fetching user data: "fullName" field not found');
          setState(() {
            _username = 'User data incomplete';
          });
        }
      } else {
        print('Error fetching user data: User document not found');
        setState(() {
          _username = 'User not found';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
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

  void _submitMealMenu() {
    String breakfast = _breakfastController.text;
    String lunch = _lunchController.text;
    String dinner = _dinnerController.text;

    if (breakfast.isNotEmpty || lunch.isNotEmpty || dinner.isNotEmpty) {
      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      _databaseReference.child(date).set({
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner,
        'submittedAt': _formattedDateTime,
      }).then((_) {
        setState(() {
          _submittedData = 'Breakfast: $breakfast, Lunch: $lunch, Dinner: $dinner';
        });
        _breakfastController.clear();
        _lunchController.clear();
        _dinnerController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meal menu submitted successfully!')),
        );
      }).catchError((error) {
        print('Failed to submit meal menu: $error');
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
        title: Text('Meal Menu'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $_username!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Please enter your meal options below.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              TextField(
                controller: _breakfastController,
                decoration: InputDecoration(
                  labelText: 'Breakfast',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              Divider(height: 20, thickness: 1, color: Colors.grey),
              TextField(
                controller: _lunchController,
                decoration: InputDecoration(
                  labelText: 'Lunch',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              Divider(height: 20, thickness: 1, color: Colors.grey),
              TextField(
                controller: _dinnerController,
                decoration: InputDecoration(
                  labelText: 'Dinner',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _submitMealMenu,
                child: Text('Update'),
              ),
              SizedBox(height: 10),
              SizedBox(height: 20),

              Text(
                'Current Date and Time:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                _formattedDateTime,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              Text(
                'Submitted Meal Options:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  _submittedData.isNotEmpty ? _submittedData : 'No meal options submitted yet.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}