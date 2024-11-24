import 'dart:ui'; // Required for ImageFilter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Notice extends StatelessWidget {
  static const routeName = '/receiving';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Notices'),
        centerTitle: true,
        backgroundColor: const Color(0xFF5A4A75), // Theme color for the AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notices')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notices = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final noticeData = notices[index];
              final noticeText = noticeData['text'];
              final timestamp = noticeData['timestamp'];

              // Format the timestamp
              String formattedTimestamp = "Unknown time";
              if (timestamp != null && timestamp is Timestamp) {
                final dateTime = timestamp.toDate();
                formattedTimestamp =
                "${dateTime.hour}:${dateTime.minute} ${dateTime.day}/${dateTime.month}/${dateTime.year}";
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 0, // No shadow for glassy effect
                color: Colors.transparent, // Transparent background for glassy effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF5A4A75).withOpacity(0.2), // Themed color with transparency
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2), // Subtle border
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              noticeText,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87, // Text color for readability
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formattedTimestamp,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.deepPurple, // Light color for timestamp
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
