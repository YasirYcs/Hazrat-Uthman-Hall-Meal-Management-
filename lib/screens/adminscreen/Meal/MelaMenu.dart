import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

class MealMenu extends StatefulWidget {
  final String username; // Pass the username to the constructor

  MealMenu({required this.username});

  @override
  _MealMenuState createState() => _MealMenuState();
}

class _MealMenuState extends State<MealMenu> {
  final TextEditingController _breakfastController = TextEditingController();
  final TextEditingController _lunchController = TextEditingController();
  final TextEditingController _dinnerController = TextEditingController();
  String _formattedDateTime = '';
  String _submittedData = '';

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

  void _submitMealMenu() {
    String breakfast = _breakfastController.text;
    String lunch = _lunchController.text;
    String dinner = _dinnerController.text;

    if (breakfast.isNotEmpty || lunch.isNotEmpty || dinner.isNotEmpty) {
      // Get the current date in YYYY-MM-DD format
      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Reference to the Firebase Realtime Database
      DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('meal_menu').child(date);

      // Write the meal data to the database
      databaseReference.set({
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner,
        'submittedAt': _formattedDateTime, // Optional: Store the formatted date and time
      }).then((_) {
        setState(() {
          _submittedData = 'Breakfast: $breakfast, Lunch: $lunch, Dinner: $dinner';
        });
        // Clear the text fields after submission
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
      // Show an error message if all fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter at least one meal option')),
      );
    }
  }

  void _updateMealMenu() {
    // Logic to update the meal menu (to be implemented)
    print('Meal Menu Updated: Breakfast: ${_breakfastController.text}, Lunch: ${_lunchController.text}, Dinner: ${_dinnerController.text}');
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
              // Welcome Section
              Text(
                'Welcome, ${widget.username}!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Please enter your meal options below.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              // Breakfast Text Field
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
              // Lunch Text Field
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
              // Dinner Text Field
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

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                onPressed: _submitMealMenu,
                child: Text('Submit'),
              ),
              SizedBox(height: 10),

              // Update Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                onPressed: _updateMealMenu,
                child: Text('Update'),
              ),
              SizedBox(height: 20),

              // Display Date and Time
              Text(
                'Current Date and Time:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                _formattedDateTime,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              // Submitted Data Section
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
