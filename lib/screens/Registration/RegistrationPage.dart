import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationRequestPage extends StatefulWidget {
  @override
  _RegistrationRequestPageState createState() =>
      _RegistrationRequestPageState();
}

class _RegistrationRequestPageState extends State<RegistrationRequestPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _agreedToRules = false; // Checkbox state

  // Method to request registration
  Future<void> requestRegistration(BuildContext context) async {
    User? user = _auth.currentUser; // Get the currently logged-in user

    if (user != null) {
      final uid = user.uid; // Fetch user UID
      final email = user.email; // Fetch user email

      try {
        // Check if the user has already requested registration
        final docSnapshot =
        await _firestore.collection('registrations').doc(uid).get();

        if (!docSnapshot.exists) {
          // Add a registration request using the UID as the document ID
          await _firestore.collection('registrations').doc(uid).set({
            'uid': uid,
            'email': email,
            'status': 'pending', // Initial status
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration request sent successfully!')),
          );
        } else {
          // User has already requested registration
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('You have already requested registration.')),
          );
        }
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      // If the user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not logged in.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Registration'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Rules and Regulations for Staying in IIUC Hall:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '''
1. Any resident, who intentionally damages any part of the hall or its property, must pay for repair/replacement and may face disciplinary action.
2. Lock rooms when leaving, and return keys during vacations.
3. Turn off lights and fans when exiting the room.
4. Report emergencies or accidents immediately.
5. Meal responsibilities rotate among students, and payment must be made on time.
6. No objectionable posters, photos, or quotes allowed in rooms.
7. Room changes require prior permission.
8. Guests (students: BDT 200/day, guardians: BDT 500/day) must pay fees.
9. Use a drilling machine (with permission) to hang items; no nails or wall scratches.
10. Furniture cannot be moved without permission.
11. Dispose of waste in designated bins.
12. Muslim residents must perform daily prayers and observe Ramadan fasting.
13. Maintain morality, politeness, and humanity.
14. Gambling, disruptive games, and immoral activities are prohibited.
15. Avoid noise; use headphones for personal audio.
16. Smoking is prohibited.
17. TV usage is limited to educational programs, with a strict cut-off at 11:30 PM.
18. No absence after sunset or staying out after 6 PM without permission.
19. Adhere to Islamic-appropriate dress codes.
20. Grouping and political activities are not allowed.
21. Report all issues to the provost office.
22. The hall authority can cancel seats for rule violations.
23. Obtain gate passes for moving items in or out of the hall.
24. Tuition outside the hall requires permission and guardian consent.
25. Pay fees (BDT 2500/month seat rent, BDT 100 generator fee) on time.
26. Unauthorized guests result in seat cancellation.
27. Fines (BDT 500) apply for rule violations.
28. New students receive free bed allocation.
29. Electric devices like rice cookers require permission to use.
30. Adhere to all hall rules; violations may lead to expulsion.''',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _agreedToRules,
                  onChanged: (bool? value) {
                    setState(() {
                      _agreedToRules = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'I agree with the rules and regulations.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _agreedToRules
                  ? () => requestRegistration(context)
                  : null, // Disable button if not agreed
              child: Text('Request Registration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Button color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
