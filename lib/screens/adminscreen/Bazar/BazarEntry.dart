import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

class BazarEntry extends StatefulWidget {
  final String username; // Pass the username to the constructor

  BazarEntry({required this.username});

  @override
  _BazarEntryState createState() => _BazarEntryState();
}

class _BazarEntryState extends State<BazarEntry> {
  final TextEditingController _bazarController = TextEditingController();
  String _formattedDateTime = '';
  String _submittedBazar = ''; // Variable to hold submitted bazar amount

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

  void _submitBazar() {
    String bazarAmount = _bazarController.text;
    if (bazarAmount.isNotEmpty) {
      // Get the current date in YYYY-MM-DD format
      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Reference to the Firebase Realtime Database
      DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('bazar').child(date);

      // Write the bazar amount to the database
      databaseReference.set({
        'amount': bazarAmount,
        'submittedAt': _formattedDateTime, // Optional: Store the formatted date and time
      }).then((_) {
        setState(() {
          _submittedBazar = 'Bazar Amount: $bazarAmount'; // Store the submitted bazar amount
        });
        // Clear the text field after submission
        _bazarController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bazar amount submitted successfully!')),
        );
      }).catchError((error) {
        print('Failed to submit bazar amount: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit bazar amount')),
        );
      });
    } else {
      // Show an error message if the field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a bazar amount')),
      );
    }
  }

  void _updateBazar() {
    // Logic to update the bazar amount
    // This can be implemented later
    print('Bazar Amount Updated: ${_bazarController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bazar Entry'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and Introduction
              Text(
                'Assalamualaikum, ${widget.username}!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Welcome to the Bazar Entry page. Please enter the bazar amount below.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              // Bazar Amount Input Field
              TextField(
                controller: _bazarController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Bazar Taka',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                onPressed: _submitBazar,
                child: Text('Submit'),
              ),
              SizedBox(height: 10),

              // Update Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                onPressed: _updateBazar,
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

              // Submitted Bazar Amount Section
              Text(
                'Submitted Bazar Amount:',
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
                  _submittedBazar.isNotEmpty ? _submittedBazar : 'No bazar amount submitted yet.',
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