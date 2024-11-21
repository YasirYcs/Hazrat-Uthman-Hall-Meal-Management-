import 'package:flutter/material.dart';
import 'FacultyDetails.dart'; // Import the FacultyDetails class
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfile extends StatefulWidget {
  final String studentId; // Pass the student ID to fetch the correct profile

  StudentProfile({required this.studentId});

  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfile> {
  Map<String, dynamic>? studentData;
  bool isLoading = true; // Track loading state
  bool hasError = false; // Track if there was an error fetching data

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .get();

      if (snapshot.exists) {
        setState(() {
          studentData = snapshot.data() as Map<String, dynamic>;
          isLoading = false; // Data fetched successfully
        });
      } else {
        _setDummyData(); // Set dummy data if no document exists
      }
    } catch (e) {
      print('Error fetching student data: $e');
      _setDummyData(); // Set dummy data in case of an error
    }
  }

  void _setDummyData() {
    setState(() {
      studentData = {
        'fullName': 'John Doe',
        'roomNumber': '101',
        'studentId': 'S123456',
        'canteenSerialNumber': 'C123',
        'faculty': 'Computer Science',
        'program': 'BSc in Computer Science',
        'batch': '2023',
        'whatsappNumber': '01234567890',
        'phoneNumber': '09876543210',
      };
      isLoading = false; // Stop loading
      hasError = true; // Indicate that there was an error
    });
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileEditPage(studentId: widget.studentId),
      ),
    ).then((_) {
      // Refresh the profile data after returning from the edit page
      _fetchStudentData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection('Personal Information', [
                _buildProfileDetail('Full Name', studentData!['fullName']),
                _buildProfileDetail('Room Number', studentData!['roomNumber']),
                _buildProfileDetail('Student ID', studentData!['studentId']),
                _buildProfileDetail('Canteen Serial Number', studentData!['canteenSerialNumber']),
              ]),
              _buildProfileSection('Academic Information', [
                _buildProfileDetail('Faculty', studentData!['faculty']),
                _buildProfileDetail('Program', studentData!['program']),
                _buildProfileDetail('Batch', studentData!['batch']),
              ]),
              _buildProfileSection('Contact Information', [
                _buildProfileDetail('WhatsApp Number', studentData!['whatsappNumber']),
                _buildProfileDetail('Phone Number', studentData!['phoneNumber']),
              ]),
              if (hasError) // Show error message if there was an error
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'Unable to load data. Showing dummy data instead.',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
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
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value ?? 'N/A', style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }
}

class StudentProfileEditPage extends StatefulWidget {
  final String studentId;

  StudentProfileEditPage({required this.studentId});

  @override
  _StudentProfileEditPageState createState() => _StudentProfileEditPageState();
}

class _StudentProfileEditPageState extends State<StudentProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  String? fullName;
  String? roomNumber;
  String? studentId;
  String? canteenSerialNumber;
  String? selectedFaculty;
  String? selectedProgram;
  String? selectedBatch;
  String? whatsappNumber;
  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .get();

      if (snapshot.exists) {
        setState(() {
          fullName = snapshot['fullName'];
          roomNumber = snapshot['roomNumber'];
          studentId = snapshot['studentId'];
          canteenSerialNumber = snapshot['canteenSerialNumber'];
          selectedFaculty = snapshot['faculty'];
          selectedProgram = snapshot['program'];
          selectedBatch = snapshot['batch'];
          whatsappNumber = snapshot['whatsappNumber'];
          phoneNumber = snapshot['phoneNumber'];
        });
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(
                  label: 'Full Name',
                  initialValue: fullName,
                  onSaved: (value) => fullName = value,
                ),
                _buildTextField(
                  label: 'Room Number',
                  initialValue: roomNumber,
                  onSaved: (value) => roomNumber = value,
                ),
                _buildTextField(
                  label: 'Student ID',
                  initialValue: studentId,
                  onSaved: (value) => studentId = value,
                ),
                _buildTextField(
                  label: 'Canteen Serial Number',
                  initialValue: canteenSerialNumber,
                  onSaved: (value) => canteenSerialNumber = value,
                ),
                _buildDropdownField(
                  label: 'Faculty',
                  items: FacultyDetails.getAllFaculties(),
                  initialValue: selectedFaculty,
                  onChanged: (value) {
                    setState(() {
                      selectedFaculty = value;
                    });
                  },
                ),
                _buildDropdownField(
                  label: 'Program',
                  items: selectedFaculty != null
                      ? FacultyDetails.getPrograms(selectedFaculty!)
                      : [],
                  initialValue: selectedProgram,
                  onChanged: (value) {
                    setState(() {
                      selectedProgram = value;
                    });
                  },
                ),
                _buildDropdownField(
                  label: 'Batch',
                  items: List.generate(60, (index) => (index + 1).toString()),
                  initialValue: selectedBatch,
                  onChanged: (value) {
                    setState(() {
                      selectedBatch = value;
                    });
                  },
                ),
                _buildTextField(
                  label: 'WhatsApp Number',
                  initialValue: whatsappNumber,
                  onSaved: (value) => whatsappNumber = value,
                ),
                _buildTextField(
                  label: 'Phone Number',
                  initialValue: phoneNumber,
                  onSaved: (value) => phoneNumber = value,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    required FormFieldSetter<String> onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      initialValue: initialValue,
      onSaved: onSaved,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    String? initialValue,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: initialValue,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Map<String, dynamic> studentData = {
        'fullName': fullName,
        'roomNumber': roomNumber,
        'studentId': studentId,
        'canteenSerialNumber': canteenSerialNumber,
        'faculty': selectedFaculty,
        'program': selectedProgram,
        'batch': selectedBatch,
        'whatsappNumber': whatsappNumber,
        'phoneNumber': phoneNumber,
      };

      try {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(widget.studentId)
            .update(studentData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context); // Navigate back after saving
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }
}