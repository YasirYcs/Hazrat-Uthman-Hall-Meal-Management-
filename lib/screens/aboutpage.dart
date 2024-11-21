import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:get/get.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("About Me"),
    backgroundColor: Colors.tealAccent,
    leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () {
    Get.back(); // Navigate back using GetX
    },
    ),
    ),

    body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.05),
              // Animated Avatar
              CircleAvatar(
                child: Image.asset("assets/photos/YasirYcs.jpg"),
                radius: 50,
              ),
              SizedBox(height: size.height * 0.04),
              // User Details with Animations
              Text(
                "YasirYcs",
                style: TextStyle(
                  fontSize: size.width * 0.07,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                "App Developer | Blogger | Gamer | Student",
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.04),
              Text(
                "University: International Islamic University Chittagong",
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.05),
              // Row for GitHub and Email Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onLongPress: () {
                        HapticFeedback.vibrate(); // Add haptic feedback
                        Clipboard.setData(ClipboardData(text: 'https://github.com/YasirYcs'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied GitHub link to clipboard')),
                        );
                      },
                      child: ListTile(
                        leading: Icon(Icons.code, color: Colors.tealAccent),
                        title: Text(
                          "GitHub",
                          style: TextStyle(color: Colors.white, fontSize: size.width * 0.045),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.05), // Space between the buttons
                  Expanded(
                    child: GestureDetector(
                      onLongPress: () {
                        HapticFeedback.vibrate(); // Add haptic feedback
                        Clipboard.setData(ClipboardData(text: 'yasir.sami.501@gmail.com'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied email to clipboard')),
                        );
                      },
                      child: ListTile(
                        leading: Icon(Icons.email, color: Colors.tealAccent),
                        title: Text(
                          "Email",
                          style: TextStyle(color: Colors.white, fontSize: size.width * 0.045),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.05),
              Divider(color: Colors.tealAccent),
              // Copyright Message
              Padding(
                padding: EdgeInsets.only(top: size.height * 0.02),
                child: Text(
                  "© 2024 YasirYcs. All rights reserved.",
                  style: TextStyle(
                    fontSize: size.width * 0.035,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}