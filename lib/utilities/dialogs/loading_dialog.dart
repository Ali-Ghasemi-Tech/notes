import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// this file here is trying to show a loading dialog to the user
// and pervent the user to toach other buttons
typedef CloseDialog = void Function();

// we are showing our user the loading screen with this method

CloseDialog showLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 10),
        Text(text)
      ],
    ),
  );
  // barrier dismissible is for when the user taps outside the dialog and we want to allow the dismiss of this dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => dialog,
  );
  return () => Navigator.of(context).pop();
}
