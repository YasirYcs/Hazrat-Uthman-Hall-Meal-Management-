import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MealRequests extends StatefulWidget {
  @override
  _MealRequestsState createState() => _MealRequestsState();
}

class _MealRequestsState extends State<MealRequests> {
  final _databaseReference = FirebaseDatabase.instance.ref();
  final _acceptedRequestsReference = FirebaseDatabase.instance.ref('accepted_requests');
  final _firestore = FirebaseFirestore.instance.collection('students');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Center(child: Text('Meal Requests')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
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
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Assalamualaikum\n'
                    '- Tap the check icon to accept a request.\n'
                    '- Tap the close icon to cancel a request.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _databaseReference.child('MealBook').onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  final userRequests = <String, dynamic>{};
                  final requests = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  requests.forEach((userId, userData) {
                    userRequests[userId] = userData;
                  });

                  if (userRequests.isEmpty) {
                    return Center(child: Text('No meal for today.'));
                  }

                  return ListView.builder(
                    itemCount: userRequests.length,
                    itemBuilder: (context, index) {
                      final userId = userRequests.keys.elementAt(index);
                      final requestData = userRequests[userId];

                      final randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

                      return StreamBuilder<DocumentSnapshot>(
                        stream: _firestore.doc(userId).snapshots(),
                        builder: (context, studentSnapshot) {
                          if (studentSnapshot.connectionState == ConnectionState.waiting) {
                            return ListTile(
                              title: Text('Loading...'),
                            );
                          }

                          if (studentSnapshot.hasError) {
                            return ListTile(
                              title: Text('Error: ${studentSnapshot.error}'),
                            );
                          }

                          if (studentSnapshot.hasData && studentSnapshot.data!.exists) {
                            final studentData = studentSnapshot.data!.data() as Map<String, dynamic>;
                            final studentName = studentData['fullName'] ?? 'Unknown';
                            final studentId = studentData['studentId'] ?? 'N/A';
                            final roomNumber = studentData['roomNumber'] ?? 'N/A';
                            final canteenSerialNumber = studentData['canteenSerialNumber'] ?? 'N/A';

                            // Now, iterate through all the dates in requestData
                            List<Widget> dateWidgets = [];
                            requestData.forEach((date, mealData) {
                              dateWidgets.add(
                                Card(
                                  margin: const EdgeInsets.all(10),
                                  elevation: 5,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: randomColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Center(
                                            child: Text(
                                              '$studentName ',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('ID: $studentId', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                              Text('Room: $roomNumber', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                              Text('Canteen Serial: $canteenSerialNumber', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        Divider(),
                                        ListTile(
                                          title: Center(child: Text('Meal Requests ⌚ $date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                                          subtitle: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Text('Breakfast: ${mealData['breakfast'] == true ? 'Yes' : 'No'}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                              Text('Lunch: ${mealData['lunch'] == true ? 'Yes' : 'No'}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                              Text('Dinner: ${mealData['dinner'] == true ? 'Yes' : 'No'}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text('Accept', style: const TextStyle(fontSize: 16)),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.check_circle),
                                                  onPressed: () {
                                                    _acceptedRequestsReference.child(date).child(userId).set({
                                                      'breakfast': mealData['breakfast'],
                                                      'lunch': mealData['lunch'],
                                                      'dinner': mealData['dinner'],
                                                    });
                                                    _databaseReference.child('MealBook').child(userId).child(date).remove();
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          title: Text('Request Accepted'),
                                                          content: Text('No more meal requests for today.'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                              child: Text('OK'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text('Reject', style: TextStyle(fontSize: 16)),
                                                IconButton(
                                                  icon: Icon(Icons.close_outlined),
                                                  onPressed: () {
                                                    _databaseReference.child('MealBook').child(userId).child(date).remove();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });

                            return Column(
                              children: dateWidgets,
                            );
                          } else {
                            return ListTile(
                              title: Text('No student data found.'),
                            );
                          }
                        },
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No meal for today.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
