import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BazarEntry extends StatefulWidget {
  final String username; // Add username as a parameter

  BazarEntry({required this.username}); // Constructor to accept username

  @override
  _BazarEntryState createState() => _BazarEntryState();
}

class _BazarEntryState extends State<BazarEntry> {
  final TextEditingController _bazarController = TextEditingController();
  String _formattedDateTime = '';
  String _submittedBazar = '';
  String _uid = ''; // Store the user ID retrieved from Firebase Auth

  final _databaseReference = FirebaseDatabase.instance.ref().child('bazar');

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    Future.delayed(Duration(seconds: 1), _updateDateTime);
    _fetchUid();
  }

  Future<void> _fetchUid() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      setState(() {
        _uid = user.uid; // Set the UID if the user is logged in
      });
    } else {
      // Handle the case where the user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in. Please log in.')),
      );
    }
  }

  void _updateDateTime() {
    setState(() {
      _formattedDateTime = DateFormat('dd/MM/yyyy - hh:mm:ss a').format(DateTime.now());
    });
    Future.delayed(Duration(seconds: 1), _updateDateTime);
  }

  void _submitBazar() {
    String bazarAmount = _bazarController.text;
    if (bazarAmount.isNotEmpty && _uid.isNotEmpty) { // Check if UID is available
      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      _databaseReference.child(_uid).child(date).set({
        'amount': bazarAmount,
        'submittedAt': _formattedDateTime,
      }).then((_) {
        setState(() {
          _submittedBazar = 'Bazar Amount: $bazarAmount';
        });
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a bazar amount')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bazar Entry'),
        backgroundColor: Colors.teal, // Changed to Teal
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Assalamualaikum Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Assalamualaikum, ${widget.username}!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ),
              SizedBox(height: 20),

              // Instructions Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Welcome to the Bazar Entry page. Please enter the bazar amount below.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),

              // Bazar Entry Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _bazarController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Bazar Taka',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Update Button Section
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Changed to Teal
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _submitBazar,
                  child: Text('Update'), // Changed to "Update"
                ),
              ),
              SizedBox(height: 20),

              // Date and Time Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(15),
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
                      'Current Date and Time:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _formattedDateTime,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Submitted Bazar Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(15),
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
                      'Submitted Bazar Amount:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _submittedBazar.isNotEmpty ? _submittedBazar : 'No bazar amount submitted yet.',
                      style: TextStyle(fontSize: 16),
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
}
