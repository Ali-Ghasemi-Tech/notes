// since we are using the error dioalog is
//more tahn three times we make a new file
//so it will be eazier to edit and modify
//in the future (OOP)
// all the buttons in our generic dialog will have the same data type of boolian and we call it "T"
// the whole point of having this generic file is that we can use diffrent dialogs with only one set of code
// so it could  be updated with new dialogs at any point in future

import 'package:flutter/material.dart';

// for each botton we need a text and a value so we map them
// this map is connected with a function which could return values
// and it will put them in DioalogOptionBuilder
typedef DialogOptionsBuilder<T> = Map<String, T?> Function();

// the reason we have an optional T? is that in android the user could
// just press anywhereon the screen other than the two options we give them to
Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionsBuilder optionsBuilder,
}) {
  // this optio builder makes a map
  final options = optionsBuilder();
  // in this part we show a dialog to the user
  return showDialog<T>(
      context: context,
      builder: (context) {
        // this function brings a simple small page for the dialog and buttons
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          // this will derermine an action in the alert dialog
          // in here we have options with thier keys which are maped to each other
          actions: options.keys.map((optionTitle) {
            final value = options[optionTitle];
            return TextButton(
              // this button that was generaited hs the could be yes no or ok
              // in case of ok it has an error dialog and its not raelly needs a value
              // so we seperated our button to ones with value and the ones without it
              // and one will be disissed with a value and the other will be dissmissed in the
              // absence of a value
              // but only a button can determine this thing
              onPressed: () {
                if (value != null) {
                  Navigator.of(context).pop(value);
                } else {
                  Navigator.of(context).pop();
                }
              },
              // this will give whatever title we want to the button
              child: Text(optionTitle),
            );
          }).toList(),
        );
      });

  // we will define the maps and the titles individually with other files
  // but it makes the job so much eseaier and we can add other dialogs in future
}
