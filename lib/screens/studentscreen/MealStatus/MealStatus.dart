import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:intl/intl.dart'; // For date formatting
import 'package:get/get.dart';  // Import GetX
import 'package:hallmeal/screens/adminscreen/Meal/MealRate.dart';
import 'package:hallmeal/screens/adminscreen/Meal/MealData.dart';
import 'package:hallmeal/screens/adminscreen/Bazar/BazarData.dart';

class MealStatus extends StatefulWidget {
  @override
  _MealStatusState createState() => _MealStatusState();
}

class _MealStatusState extends State<MealStatus> {
  List<Map<String, dynamic>> _mealData = [];
  User? user;
  int totalMeals = 0;
  double mealRate = 0.0;
  String fullName = "";  // Variable to hold the student's full name
  String currentMonth = ""; // Variable to hold current month name

  @override
  void initState() {
    super.initState();
    _getUser();
    _fetchMealRate();
  }

  Future<void> _getUser() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _fetchStudentFullName();  // Fetch full name after user is authenticated
      _fetchMealData();
    } else {
      print('User is not authenticated');
    }
  }

  Future<void> _fetchStudentFullName() async {
    if (user != null) {
      final uid = user!.uid;
      final studentDoc = FirebaseFirestore.instance.collection('students').doc(uid);

      // Fetch student data from Firestore
      final snapshot = await studentDoc.get();
      if (snapshot.exists) {
        setState(() {
          fullName = snapshot['fullName'] ?? "No name available";  // Set full name
        });
      } else {
        print('Student document not found');
      }
    }
  }

  Future<void> _fetchMealRate() async {
    final dataFetcher = BazarDataFetcher();
    final mealSummaryFetcher = MealSummaryFetcher();
    final mealRateCalculator = MealRateCalculator(
      dataFetcher: dataFetcher,
      mealSummaryFetcher: mealSummaryFetcher,
    );
    final currentDate = DateTime.now();
    final month = currentDate.month;
    final year = currentDate.year;

    double calculatedRate = await mealRateCalculator.calculateMealRateForCurrentMonth(month, year);

    setState(() {
      mealRate = calculatedRate;
    });
  }

  Future<void> _fetchMealData() async {
    final databaseReference = FirebaseDatabase.instance.ref('accepted_requests');
    final snapshot = await databaseReference.once();
    final data = snapshot.snapshot.value as Map<dynamic, dynamic>;

    if (data != null) {
      final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
      totalMeals = 0;

      data.forEach((date, users) {
        final mealDate = DateTime.parse(date);
        final formattedDate = DateFormat('yyyy-MM').format(mealDate);

        if (formattedDate == currentMonth && users.containsKey(user!.uid)) {
          final userMeals = users[user!.uid] as Map<dynamic, dynamic>;
          final mealData = {
            'date': date,
            'breakfast': userMeals['breakfast'],
            'lunch': userMeals['lunch'],
            'dinner': userMeals['dinner'],
          };
          _mealData.add(mealData);

          if (userMeals['breakfast'] == true) totalMeals++;
          if (userMeals['lunch'] == true) totalMeals++;
          if (userMeals['dinner'] == true) totalMeals++;
        }
      });
    } else {
      print('No meal data found');
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Status'),
        backgroundColor: Color(0xFF5A4A75), // Use the deep purple color
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Get.back(),  // Use GetX to navigate back
          ),
        ],
      ),
      body: _mealData.isEmpty
          ? Center(child: Text('No meal data found for this month.'))
          : SingleChildScrollView(
        child: Column(
          children: [
            // First Block: Card for meal summary
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Color(0xFFF3E5F5), // Lighter accent color
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome $fullName!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A4A75),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Your total meal status for the month of ${DateFormat('MMMM yyyy').format(DateTime.now())} is below:',
                        style: TextStyle(fontSize: 16, color: Color(0xFF5A4A75)),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Total Meals: $totalMeals',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Meal Rate: \$${mealRate.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Total Cost: \$${(mealRate * totalMeals).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Second Block: Scrollable table for meal details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Color(0xFFF3E5F5), // Lighter accent color
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20.0,
                    columns: [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Breakfast')),
                      DataColumn(label: Text('Lunch')),
                      DataColumn(label: Text('Dinner')),
                    ],
                    rows: _mealData.map((meal) {
                      return DataRow(
                        cells: [
                          DataCell(Text(meal['date'])),
                          DataCell(Text(meal['breakfast'] ? 'Yes' : 'No')),
                          DataCell(Text(meal['lunch'] ? 'Yes' : 'No')),
                          DataCell(Text(meal['dinner'] ? 'Yes' : 'No')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
