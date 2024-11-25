import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestAcceptPage extends StatefulWidget {
  @override
  _RequestAcceptPageState createState() => _RequestAcceptPageState();
}

class _RequestAcceptPageState extends State<RequestAcceptPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to accept a registration request
  Future<void> acceptRequest(String uid) async {
    try {
      await _firestore.collection('registrations').doc(uid).update({
        'status': 'accepted',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request accepted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Fetch detailed student data by UID
  Future<Map<String, dynamic>?> fetchStudentData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('students').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accept Requests'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          // Section for pending requests
          Positioned.fill(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('registrations')
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No pending registration requests.'),
                  );
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    String uid = doc['uid'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Card(
                        elevation: 2,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          title: Text(
                            'Room Number: Pending',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          subtitle: Text(
                            'Email: ${doc['email']}',
                            style: TextStyle(fontSize: 14),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => acceptRequest(uid),
                            child: Text('Accept'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          // Section for accepted requests, positioned above the pending requests
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5, // Adjust position as needed
            left: 0,
            right: 0,
            bottom: 0,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('registrations')
                  .where('status', isEqualTo: 'accepted')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No accepted registration requests.'),
                  );
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    String uid = doc['uid'];
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: fetchStudentData(uid),
                      builder: (context, studentSnapshot) {
                        if (studentSnapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(
                            title: Text('Loading details for UID: $uid...'),
                          );
                        }

                        if (!studentSnapshot.hasData || studentSnapshot.data == null) {
                          return ListTile(
                            title: Text('UID: $uid'),
                            subtitle: Text('Error fetching student details.'),
                          );
                        }

                        Map<String, dynamic> studentData = studentSnapshot.data!;
                        return Card(
                          color: Colors.tealAccent.shade100,
                          margin: EdgeInsets.all(8.0),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Room Number: ${studentData['roomNumber'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Name: ${studentData['fullName'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Batch: ${studentData['batch'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Program: ${studentData['program'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Faculty: ${studentData['faculty'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Student ID: ${studentData['studentId'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Phone: ${studentData['phoneNumber'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'WhatsApp: ${studentData['whatsappNumber'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
