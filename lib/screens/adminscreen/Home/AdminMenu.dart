import 'package:flutter/material.dart';
import 'package:hallmeal/screens/Registration/RegistrationAccept.dart';
import 'package:hallmeal/screens/adminscreen/AdminLoginPage.dart';
import 'package:hallmeal/screens/adminscreen/Bazar/BazarEntry.dart';
import 'package:hallmeal/screens/adminscreen/Meal/MealRequests.dart';
import 'package:hallmeal/screens/adminscreen/Meal/MealSheet.dart';
import 'package:hallmeal/screens/adminscreen/Meal/MelaMenu.dart';
import 'package:hallmeal/screens/adminscreen/Noticeboard/SendNotice.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Meal/MealData.dart';
import '../Bazar/BazarData.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'InfoCard.dart';

class AdminMenu extends StatefulWidget {
  @override
  _AdminMenuState createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu> {
  String _formattedDateTime = '';
  String? _fullName;
  String? _studentId;
  final MealSummaryFetcher _mealSummaryFetcher = MealSummaryFetcher();
  Map<String, Map<String, int>> _totalMealsByDate = {};
  Map<String, Map<String, int>> _totalMealsByMonth = {};
  final BazarDataFetcher _dataFetcher = BazarDataFetcher();
  int? _totalBazarAmount;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _startDateTimeUpdates();
    _fetchStudentFullName();
    _fetchMealData();
    final currentDateTime = DateTime.now();
    _fetchDataForMonth(currentDateTime.month, currentDateTime.year);
  }

  void _onRefresh() async {
    await _fetchStudentFullName();
    await _fetchMealData();
    final currentDateTime = DateTime.now();
    await _fetchDataForMonth(currentDateTime.month, currentDateTime.year);
    _refreshController.refreshCompleted();
  }

  void _startDateTimeUpdates() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _formattedDateTime = DateFormat('dd/MM/yyyy - hh:mm:ss a').format(DateTime.now());
      });
    });
  }

  Future<void> _fetchDataForMonth(int month, int year) async {
    final total = await _dataFetcher.totalBazar(month, year);
    setState(() {
      _totalBazarAmount = total;
    });
  }

  Future<void> _fetchMealData() async {
    try {
      final currentDateTime = DateTime.now();
      await _mealSummaryFetcher.fetchMealsByMonth(currentDateTime.month);
      setState(() {
        _totalMealsByDate = _mealSummaryFetcher.getTotalMealsByDate();
        _totalMealsByMonth = _mealSummaryFetcher.getTotalMealsByMonth();
      });
    } catch (e) {
      print('Error fetching meal data: $e');
    }
  }

  Future<void> _fetchStudentFullName() async {
    try {
      User? currentUser  = FirebaseAuth.instance.currentUser ;
      if (currentUser  == null) {
        throw Exception('No user is logged in.');
      }

      String uid = currentUser .uid;
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance.collection('students').doc(uid).get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data();
        setState(() {
          _fullName = data?['fullName'] ?? 'Unknown User';
          _studentId = data?['studentId'] ?? 'Unknown ID';
        });
      } else {
        throw Exception('No document found for UID: $uid');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      setState(() {
        _fullName = 'Unknown User';
        _studentId = 'Unknown ID';
      });
    }
  }

  Future<void> adminlogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.off(AdminloginPage());
    } catch (e) {
      Get.snackbar(
        'Logout Error',
        'An error occurred while logging out. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedToday = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final meals = _totalMealsByDate[formattedToday] ?? {};
    final totalMealsToday = (meals['breakfast'] ?? 0) + (meals['lunch'] ?? 0) + (meals['dinner'] ?? 0);
    final totalMealsThisMonth = _totalMealsByMonth.values.fold(0, (sum, meal) => sum + (meal['breakfast'] ?? 0) + (meal['lunch'] ?? 0) + (meal['dinner'] ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hazrat Uthman Hall'),
        backgroundColor: Colors.teal,  // Updated color
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/photos/HazratUthman.png', height: 40),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),  // Updated color
              child: Column(
                children: [
                  Text(
                    'Admin Menu',
                    style: TextStyle(color: Colors.black87, fontSize: 24),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CircleAvatar(backgroundImage: AssetImage("assets/photos/HazaratUthman2.png"),
                      radius: 40,),
                      Text(
                        'HUH!',
                        style: TextStyle(color: Color(0xFF5A4A75), fontSize: 54),
                      ),
                    ],
                  )
                ],
              ),
            ),

            _buildDrawerItem(Icons.fastfood, 'Set Meal Menu', () {
              Get.to(MealMenu());
            }),

            const Divider(),
            _buildDrawerItem(Icons.request_page_outlined, 'Meal Requests', () {
              Get.to(MealRequests());
            }),
            const Divider(),

            _buildDrawerItem(Icons.newspaper_rounded, 'Meal Sheet', () {
              Get.to(MealSheet());
            }),
            const Divider(),
            _buildDrawerItem(Icons.list, 'Bazars Entry ', () {
              Get.to(BazarEntry(username: _fullName ?? 'User '));
            }),

            const Divider(),
            _buildDrawerItem(Icons.notifications, 'Send Notice', () {
              Get.to(SendNotice());
            }),
            const Divider(),
            _buildDrawerItem(Icons.people_alt, 'Registered Students', () {
              Get.to(RequestAcceptPage());
            }),
            const Divider(),
            _buildDrawerItem(Icons.logout, 'Logout', () => adminlogout(context)),
          ],
        ),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: Column(
          children: [
            _buildHeader(),
            InfoCard(totalMealsToday: totalMealsToday, totalMealsThisMonth: totalMealsThisMonth, formattedDateTime: _formattedDateTime, totalBazarAmount: _totalBazarAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 150,
      color: Colors.teal,  // Updated color
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: const AssetImage('assets/photos/HazratUthman.png'),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _fullName ?? 'Unknown User',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _studentId ?? 'Unknown ID',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
