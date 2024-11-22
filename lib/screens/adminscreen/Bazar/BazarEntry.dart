import 'package:cloud_firestore/cloud_firestore.dart';
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
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    Future.delayed(Duration(seconds: 1), _updateDateTime);
    _fetchUid();
  }

  Future<void> _fetchUid() async {
    User? user = FirebaseAuth.instance.currentUser ; // Get the current user
    if (user != null) {
      setState(() {
        _uid = user.uid; // Set the UID if the user is logged in
      });
    } else {
      // Handle the case where the user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User  not logged in. Please log in.')),
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
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              TextField(
                controller: _bazarController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Bazar Taka',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                onPressed: _submitBazar,
                child: Text('Submit'),
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