import 'package:divine_soul_yoga/src/presentation/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutDialog {
  static void show(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          message: const Text(
            "Do you really want to logout?",
            style: TextStyle(
              fontSize: 22,
              color: Colors.black87,
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                // Clear SharedPreferences data
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove("user_id");
                await prefs.remove("name");

                // Unfocus any active input fields
                FocusScope.of(context).unfocus();

                // Navigate to Login screen and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text(
                "Logout",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.red[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
            isDefaultAction: true,
            child: const Text(
              "Cancel",
              style: TextStyle(
                fontSize: 22,
                color: Colors.black54,
              ),
            ),
          ),
        );
      },
    ).then((value) {
      // This part is optional since navigation is handled above
      if (value == "Logout") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "User signed out",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            backgroundColor: Colors.white,
          ),
        );
      }
    });
  }
}
