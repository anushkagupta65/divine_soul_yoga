import 'package:divine_soul_yoga/api_service/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/userprovider.dart';

class FeedbackPage extends StatelessWidget {
  TextEditingController _name = TextEditingController();
  TextEditingController _description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<Userprovider>(context);

    // Get current date in format yyyy-MM-dd
    String currentDate = DateTime.now().toLocal().toString().split(' ')[0]; // yyyy-MM-dd format

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feedback',
          style: TextStyle(
            color: Color(0xffD45700),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Image
            profileProvider.profileData!["user"]["profile_image"] != null
                ? CircleAvatar(
              radius: 50.0,
              backgroundImage: (profileProvider.profileData!['user']['profile_image'] != "")
                  ? NetworkImage(profileProvider.profileData!['user']['profile_image'])
                  : AssetImage("assets/images/act1.png"),
            )
                : CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage("assets/images/act1.png"),
            ),
            SizedBox(height: 16),

            // Name Field
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                labelText: 'Your Name',
                hintText: 'Enter your name',
                labelStyle: TextStyle(color: Color(0xffD45700)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Feedback Field
            TextFormField(
              controller: _description,
              maxLines: 4,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: 'Your Feedback',
                hintText: 'Enter your feedback',
                labelStyle: TextStyle(color: Color(0xffD45700)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your feedback';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                // Form validation logic
                if (_name.text.isEmpty || _description.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in both fields')),
                  );
                  return;
                }

                // Pass the current date to the API service
                ApiService().submitFeedback(
                  name: _name.text,
                  description: _description.text,
                  date: currentDate, // Send the current date
                  status: 'draft',
                  userId: profileProvider.profileData!['user']['id'].toString(),
                );

                _description.clear();
                _name.clear();
                // Handle feedback submission
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Feedback Submitted!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffD45700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
              ),
              child: Text(
                'Submit Feedback',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
