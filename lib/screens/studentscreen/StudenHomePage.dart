import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hallmeal/screens/studentscreen/MealBook/MealBook.dart';
import 'package:hallmeal/screens/studentscreen/Profile/StudentProfile.dart';
import 'package:hallmeal/services/AuthService.dart';
import 'package:get/get.dart';
import '../aboutpage.dart';

class StudentHomePage extends StatefulWidget {
  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  DateTime? selectedDate;
  String totalBazar = "0.0 \$";
  String todaysMenu = "N/A";

  // Fetch Meal Menu Data
  Future<void> fetchMealData(String date) async {
    try {
      DatabaseReference mealRef = FirebaseDatabase.instance.ref().child('meal_menu').child(date);
      DataSnapshot snapshot = await mealRef.get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          todaysMenu = "Breakfast: ${data['breakfast']}, Lunch: ${data['lunch']}, Dinner: ${data['dinner']}";
        });
      } else {
        setState(() {
          todaysMenu = "No menu available";
        });
      }
    } catch (e) {
      print('Error fetching meal data: $e');
      setState(() {
        todaysMenu = "Error loading menu";
      });
    }
  }

  // Fetch Bazar Data
  Future<void> fetchBazarData(String date) async {
    try {
      DatabaseReference bazarRef = FirebaseDatabase.instance.ref().child('bazar').child(date);
      DataSnapshot snapshot = await bazarRef.get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          totalBazar = "${data['amount']} \$";
        });
      } else {
        setState(() {
          totalBazar = "No bazar data";
        });
      }
    } catch (e) {
      print('Error fetching bazar data: $e');
      setState(() {
        totalBazar = "Error loading bazar";
      });
    }
  }

  // Handle Date Selection
  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });

      // Format date as `YYYY-MM-DD` for Firebase lookup
      String formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

      // Fetch data for the selected date
      fetchMealData(formattedDate);
      fetchBazarData(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hall Meal Management System IIUC'),
              Icon(Icons.restaurant),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            _buildDrawerItem(Icons.house, "House", () {}),
            _buildDrawerItem(Icons.food_bank, "Book Meals", () { Get.to(MealBook());}),
            _buildDrawerItem(Icons.person, "Profile", () { Get.to(StudentProfile(studentId: "C223025"));}),
            _buildDrawerItem(Icons.tips_and_updates, "Notice", () {}),
            _buildDrawerItem(Icons.share, "Prayer", () {}),
            _buildDrawerItem(Icons.info, "About Us", () {
              Get.to(AboutPage());
            }),
            _buildDrawerItem(Icons.logout, "Logout", () => logout(context)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.purple.shade100,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/profile_placeholder.png'), // Replace with actual image
                ),
                SizedBox(width: 16),
                Text(
                  "Username",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Overall Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow("House Stats:", "Current Month"),
                _buildTableRow(
                  "Please Select",
                  GestureDetector(
                    onTap: _selectDate,
                    child: Text(
                      selectedDate != null
                          ? "${selectedDate!.toLocal()}".split(' ')[0]
                          : "Select Date",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                _buildTableRow("Total Meals", "0.0"),
                _buildTableRow("Total Bazar", totalBazar),
                _buildTableRow("Cost Per Meal", "0.00 \$"),
                _buildTableRow("Remaining Money on Manager", "0.0 \$"),
              ],
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Today\'s Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow("Today's Meals", "0"),
                _buildTableRow("Today's Menu", todaysMenu),
                _buildTableRow("My Meals", "0.0 \$"),
                _buildTableRow("My Meal Costs", "0.0 \$"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String first, dynamic second) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(first),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: second is Widget
              ? second
              : Text(
            second,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(title),
      onTap: onTap,
    );
  }
}
