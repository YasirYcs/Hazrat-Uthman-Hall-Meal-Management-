import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
var size= Get.size;
class MealBook extends StatefulWidget {

  @override
  _MealBookState createState() => _MealBookState();
}

class _MealBookState extends State<MealBook> {
  bool _breakfast = false;
  bool _lunch = false;
  bool _dinner = false;

  final _databaseReference = FirebaseDatabase.instance.ref();
  final _firestore = FirebaseFirestore.instance.collection('students');

  String breakfastMenu = "Loading...";
  String lunchMenu = "Loading...";
  String dinnerMenu = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchMealData();
  }

  Future<void> _fetchMealData() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    await fetchMealData(formattedDate);
  }

  Future<void> fetchMealData(String date) async {
    try {
      DatabaseReference mealRef = _databaseReference.child('meal_menu').child(date);
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

  void _submitRequest() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Fluttertoast.showToast(msg: "User not logged in", toastLength: Toast.LENGTH_SHORT);
      return;
    }

    String uid = user.uid;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    Map<String, dynamic> requestData = {
      'breakfast': _breakfast,
      'lunch': _lunch,
      'dinner': _dinner,
    };

    try {
      String path = 'MealBook/$uid/$formattedDate';
      await _databaseReference.child(path).set(requestData);
      Fluttertoast.showToast(msg: "Request submitted successfully!", toastLength: Toast.LENGTH_SHORT);
      setState(() {
        _breakfast = false;
        _lunch = false;
        _dinner = false;
      });
    } catch (error) {
      Fluttertoast.showToast(msg: "Error submitting request: $error", toastLength: Toast.LENGTH_SHORT);
    }
  }

  Color _getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Center(child: Text('Book Meal')),
        backgroundColor:  Color(0xFF5A4A75),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 8.0,
                      spreadRadius: 2.0,
                      offset: Offset(2, 4), // Position of the shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          "Important Notice",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Please select your meal on time. If you are late, your meal booking request will not be accepted.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: Text(
                          "Thank you for your cooperation!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMealContainer('Breakfast', breakfastMenu),
                  _buildMealContainer('Lunch', lunchMenu),
                  _buildMealContainer('Dinner', dinnerMenu),
                ],
              ),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 5.0,
                      spreadRadius: 0.0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: Text('Breakfast'),
                      value: _breakfast,
                      onChanged: (value) {
                        setState(() {
                          _breakfast = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Lunch'),
                      value: _lunch,
                      onChanged: (value) {
                        setState(() {
                          _lunch = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Dinner'),
                      value: _dinner,
                      onChanged: (value) {
                        setState(() {
                          _dinner = value!;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: _submitRequest,
                      child: Text('Submit Request'),
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

  Widget _buildMealContainer(String mealType, String mealData) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: _getRandomColor(), // Random color for the container
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 5.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              mealType,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Container(
              height: size.width*.3,
              width:size.width*.2,
              alignment: Alignment.center,
              child: Text(
                mealData,
                style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w800,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
