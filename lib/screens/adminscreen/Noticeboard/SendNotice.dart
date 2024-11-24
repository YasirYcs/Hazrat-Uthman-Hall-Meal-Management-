import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SendNotice extends StatefulWidget {
  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<SendNotice> {
  final TextEditingController _noticeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSending = false; // To track sending state

  void _sendNotice() async {
    if (_noticeController.text.isNotEmpty) {
      setState(() {
        _isSending = true; // Start sending
      });

      try {
        await _firestore.collection('notices').add({
          'text': _noticeController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _noticeController.clear(); // Clear the input field
        Fluttertoast.showToast(msg: "Notice sent successfully!");
      } catch (e) {
        Fluttertoast.showToast(msg: "Error sending notice: $e");
      } finally {
        setState(() {
          _isSending = false; // Stop sending
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notice Section', style: TextStyle(fontSize: 20)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.teal, // Set AppBar color to teal
      ),
      body: Container(
        child: Stack(
          children: [
            // Display sent messages in a separate container
            Positioned.fill(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('notices')
                    .orderBy('timestamp', descending: true) // Sort by timestamp
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final notices = snapshot.data!.docs;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: ListView.builder(
                      reverse: true, // To show the latest notice at the top
                      itemCount: notices.length,
                      itemBuilder: (context, index) {
                        final noticeData = notices[index];
                        final noticeText = noticeData['text'];
                        final timestamp = noticeData['timestamp'];

                        // Check if timestamp is null
                        String formattedTimestamp = "Unknown time";
                        if (timestamp != null && timestamp is Timestamp) {
                          final dateTime = timestamp.toDate();
                          formattedTimestamp =
                          "${dateTime.hour}:${dateTime.minute} ${dateTime.day}/${dateTime.month}/${dateTime.year}";
                        }

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.teal, // Set a consistent teal color for notices
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  noticeText,
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  formattedTimestamp,
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Message input container at the bottom
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(50),
                    bottomLeft: Radius.circular(50),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _noticeController,
                          maxLines: 4, // Allows for a bigger text field with multiple lines
                          decoration: InputDecoration(
                            hintText : 'Type your notice...',
                            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12), // Increased padding
                            border: InputBorder.none, // Remove the border
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton(
                          onPressed: _isSending ? null : _sendNotice,
                          child: _isSending
                              ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.0,
                          )
                              : Icon(Icons.send),
                        ),
                      ),
                    ],
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