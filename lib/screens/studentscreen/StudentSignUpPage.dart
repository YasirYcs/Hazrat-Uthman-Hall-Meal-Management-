import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String studentId = '';
  String roomNumber = '';
  String phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    username = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'User  ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your user ID';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    studentId = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Room Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your room number';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    roomNumber = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    phoneNumber = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process the data
                    print('Username: $username');
                    print('Student  ID: $studentId');
                    print('Room Number: $roomNumber');
                    print('Phone Number: $phoneNumber');
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}