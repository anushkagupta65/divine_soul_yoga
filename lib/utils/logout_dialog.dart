import 'package:divine_soul_yoga/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogoutDialog {
  static void show(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          message: Text(
            "Do you really want to logout?",
            style: Theme.of(context).textTheme.headlineSmall,
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
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: Colors.red),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              FocusScope.of(context).unfocus;
              Navigator.pop(context);
            },
            isDefaultAction: true,
            child: Text(
              "Cancel",
              style: Theme.of(context).textTheme.headlineMedium,
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
