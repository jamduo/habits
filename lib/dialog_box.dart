import 'dart:async';

import 'package:flutter/material.dart';

Future<String?> showAlertDialog(BuildContext context, String title, String message, List<String> actions) {
  // Create the buttons
  var buttons = actions.map<Widget>((text) => 
    TextButton(
      child: Text(text),
      onPressed: () {
        Navigator.pop(context, text);
      },
    )
  );

  // Create the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: buttons.toList(),
  );

  // show the dialog
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
    useRootNavigator: false,
  );
}