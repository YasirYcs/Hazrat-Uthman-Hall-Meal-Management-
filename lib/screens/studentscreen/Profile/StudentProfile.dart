import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'StudentProfileEdit.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentProfile extends StatefulWidget {
  final String studentId;

  const StudentProfile({super.key, required this.studentId});

  @override
  _StudentDetailShowState createState() => _StudentDetailShowState();
}

class _StudentDetailShowState extends State<StudentProfile> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  Future<Map<String, dynamic>?>? _studentData;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }
  final user = FirebaseAuth.instance.currentUser;
  Future<void> _fetchStudentData() async {
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(user?.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          _studentData = Future.value(snapshot.data() as Map<String, dynamic>);
        });
      } else {
        setState(() {
          _studentData = null;
        });
      }
    } catch (e) {
      print('Error fetching student: $e');
      setState(() {
        _studentData = null;
      });
    }
  }

  void _onRefresh() async {
    await _fetchStudentData();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.to(() => StudentProfileEdit());
            },
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _studentData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text("Student not found."));
              } else {
                final student = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      _buildProfileSection('Personal Information', [
                        _buildProfileDetail('Full Name', student['fullName']),
                        _buildProfileDetail('Room Number', student['roomNumber']),
                        _buildProfileDetail('Student ID', student['studentId']),
                        _buildProfileDetail('Canteen Serial Number', student['canteenSerialNumber']),
                      ]),
                      SizedBox(height: 16),
                      _buildProfileSection('Academic Information', [
                        _buildProfileDetail('Faculty', student['faculty']),
                        _buildProfileDetail('Program', student['program']),
                        _buildProfileDetail('Batch', student['batch']),
                      ]),
                      SizedBox(height: 16),
                      _buildProfileSection('Contact Information', [
                        _buildProfileDetail('WhatsApp Number', student['whatsappNumber']),
                        _buildProfileDetail('Phone Number', student['phoneNumber']),
                      ]),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> details) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
          SizedBox(height: 8),
          ...details,
        ],
      ),
    );
  }

  Widget _buildProfileDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 10),
          Expanded(
            child: Text(value ?? 'N/A', style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}