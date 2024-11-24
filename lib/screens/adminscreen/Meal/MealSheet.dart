import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'MealSheetEdit.dart';

class MealSheet extends StatefulWidget {
  @override
  _MealSheetState createState() => _MealSheetState();
}

class _MealSheetState extends State<MealSheet> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref('accepted_requests');
  final CollectionReference studentsCollection = FirebaseFirestore.instance.collection('students');

  String selectedDate = ''; // Current date will be set automatically

  String getFormattedDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    // Set the current date automatically
    selectedDate = getFormattedDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Meal Sheet')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Get.to(MealSheetEdit()); // Navigate to MealSheetEdit
            },
          ),
        ],
        backgroundColor: Colors.teal, // Teal accent color
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    spreadRadius: 2.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Current Date: $selectedDate',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: dbRef.child(selectedDate).onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("An error occurred."));
                  }

                  if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                    return const Center(child: Text("No Attendance Data Found"));
                  }

                  final rawData = snapshot.data!.snapshot.value;

                  // Debugging: Print the raw data fetched
                  print('Raw data for $selectedDate: $rawData');

                  final Map<String, Map<String, dynamic>> flattenedData = {};

                  if (rawData is Map) {
                    rawData.forEach((key, value) {
                      if (value is Map) {
                        flattenedData[key] = Map<String, dynamic>.from(value);
                      }
                    });
                  }

                  if (flattenedData.isEmpty) {
                    return const Center(child: Text("No Attendance Data Found"));
                  }

                  return FutureBuilder<Map<String, StudentDetails>>(
                    future: fetchStudentDetails(flattenedData.keys),
                    builder: (context, studentSnapshot) {
                      if (studentSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (studentSnapshot.hasError) {
                        return const Center(child: Text("Error fetching student names."));
                      }

                      final studentDetails = studentSnapshot.data ?? {};

                      // Sorting students based on their canteenSerialNumber
                      final sortedStudentDetails = studentDetails.entries.toList()
                        ..sort((a, b) => a.value.canteenSerialNumber.compareTo(b.value.canteenSerialNumber));

                      return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                      columns: const [
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Breakfast")),
                      DataColumn(label: Text("Lunch")),
                      DataColumn(label: Text("Dinner")),
                      ],
                      rows: sortedStudentDetails.map((entry) {
                      final String uid = entry.key;
                      final StudentDetails details = entry.value;
                      final Map<String, dynamic> requestData = flattenedData[uid] ?? {};

                      return DataRow(
                      cells: [
                      DataCell(
                      SingleChildScrollView(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(details.fullName, style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Canteen Serial: ${details.canteenSerialNumber}"),
                        Text("ID: ${details.studentId}"),
                        Text("Room: ${details.roomNumber}"),
                        ],
                        ),
                      ),
                      ),
                      DataCell(
                      buildMealWidget(
                      selectedDate,
                      uid,
                      "breakfast",
                      requestData['breakfast'] ?? false,
                      ),
                      ),
                      DataCell(
                      buildMealWidget(
                      selectedDate,
                      uid,
                      "lunch",
                      requestData['lunch'] ?? false,
                      ),
                      ),
                      DataCell(
                      buildMealWidget(
                      selectedDate,
                      uid,
                      "dinner",
                      requestData['dinner'] ?? false,
                      ),
                      ),
                      ],
                      );
                      }).toList(),
                      ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMealWidget(String date, String uid, String mealType, bool currentValue) {
    return Center(
      child: GestureDetector(
        onTap: () {
          final updatedValue = !currentValue;
          dbRef.child("$date/$uid/$mealType").set(updatedValue);
        },
        child: currentValue
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.cancel, color: Colors.red),
      ),
    );
  }

  Future<Map<String, StudentDetails>> fetchStudentDetails(Iterable<String> uids) async {
    final Map<String, StudentDetails> studentDetails = {};

    for (String uid in uids) {
      try {
        final doc = await studentsCollection.doc(uid).get();
        if (doc.exists) {
          studentDetails[uid] = StudentDetails.fromFirestore(doc);
        } else {
          studentDetails[uid] = StudentDetails();
        }
      } catch (e) {
        studentDetails[uid] = StudentDetails();
      }
    }

    return studentDetails;
  }
}

class StudentDetails {
  final String fullName;
  final String studentId;
  final String roomNumber;
  final String canteenSerialNumber;

  StudentDetails({
    this.fullName = 'Unknown Student',
    this.studentId = 'N/A',
    this.roomNumber = 'N/A',
    this.canteenSerialNumber = 'N/A',
  });

  factory StudentDetails.fromFirestore(DocumentSnapshot doc) {
    return StudentDetails(
      fullName: doc['fullName'] ?? 'Unknown Student',
      studentId: doc['studentId'] ?? 'N/A',
      roomNumber: doc['roomNumber'] ?? 'N/A',
      canteenSerialNumber: doc['canteenSerialNumber'] ?? 'N/A',
    );
  }
}