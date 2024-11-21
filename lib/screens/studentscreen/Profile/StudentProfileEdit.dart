import 'package:flutter/material.dart';
import 'FacultyDetails.dart'; // Import the FacultyDetails class
import 'package:cloud_firestore/cloud_firestore.dart';
class StudentProfileEdit extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<StudentProfileEdit> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context); // Navigate back when the back button is pressed
          },
        ),
        title: Center(
          child: Text('Edit Profile'),
        ),
        backgroundColor: Colors.purple, // Purple theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              verticalDirection: VerticalDirection.down,
              children: [
                _buildSectionTitle('Personal Information'),
                _buildTextField(
                  label: 'Full Name',
                  onSaved: (value) => fullName = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'Room Number',
                  onSaved: (value) => roomNumber = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your room number';
                    }
                    // Check if the room number is an integer
                    if (int.tryParse(value) == null) {
                      return 'Room number must be an integer';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'Student ID',
                  onSaved: (value) => studentId = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your student ID';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'Canteen Serial Number',
                  onSaved: (value) => canteenSerialNumber = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your canteen serial number';
                    }
                    return null;
                  },
                ),
                _buildSectionTitle('Academic Information'),
                GestureDetector(
                  onTap: () {
                    // Reset program and batch when faculty dropdown is tapped
                    setState(() {
                      selectedProgram = null;  // Reset selected program
                      selectedBatch = null;    // Reset selected batch
                    });
                  },
                  child: _buildDropdownField(
                    label: 'Faculty',
                    items: FacultyDetails.getAllFaculties(),
                    onChanged: (value) {
                      setState(() {
                        selectedFaculty = value;  // Update selected faculty
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a faculty';
                      }
                      return null;
                    },
                  ),
                ),
                _buildDropdownField(
                  label: 'Program',
                  items: selectedFaculty != null
                      ? FacultyDetails.getPrograms(selectedFaculty!)  // Programs related to selected faculty
                      : [],
                  onChanged: (value) {
                    setState(() {
                      selectedProgram = value;  // Update selected program
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a program';
                    }
                    return null;
                  },
                ),
                _buildDropdownField(
                  label: 'Batch',
                  items: List.generate(60, (index) => (index + 1).toString()),  // Batch options 1 to 60
                  onChanged: (value) {
                    setState(() {
                      selectedBatch = value;  // Update selected batch
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a batch';
                    }
                    return null;
                  },
                ),
                _buildSectionTitle('Contact Information'),
                _buildTextField(
                  label: 'WhatsApp Number',
                  onSaved: (value) => whatsappNumber = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your WhatsApp number';
                    }
                    // Check if the phone number contains only digits and is 11 digits long
                    if (!RegExp(r'^\d{11}$').hasMatch(value)) {
                      return 'Phone number must be 11 digits and contain no letters';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'Phone Number',
                  onSaved: (value) => phoneNumber = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    // Check if the phone number contains only digits and is 11 digits long
                    if (!RegExp(r'^\d{11}$').hasMatch(value)) {
                      return 'Phone number must be 11 digits and contain no letters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16, // Adjust the font size as needed
                        fontWeight: FontWeight.bold, // Bold text
                        color: Colors.black, // Black text for contrast
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // White button background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Rounded corners
                        side: BorderSide(color: Colors.black), // Black border around the button
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24), // Padding for better spacing
                      elevation: 5, // Adds a shadow for depth
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required FormFieldValidator<String?> validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          borderRadius: BorderRadius.circular(20),
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 18, horizontal: 20),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create a map of the data to send to Fire store
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
        // Send data to Firestore
        await FirebaseFirestore.instance.collection('students').add(studentData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        // Handle any errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }
}