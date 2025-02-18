import 'package:divine_soul_yoga/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
              onPressed: () {
                FocusScope.of(context).unfocus;
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                    (Route<dynamic> route) => false);
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
              FocusScope.of(context).unfocus;
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
    ).then((value) async {
      if (value == "Logout") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                textScaleFactor: 1,
                "User signed out",
                style: Theme.of(context).textTheme.titleMedium),
            backgroundColor: Colors.white,
          ),
        );
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Login()),
            (Route<dynamic> route) => false);
      }
    });
  }
}
