import 'package:flutter/cupertino.dart';
import 'package:notes/utilities/dialogs/generic_dialog.dart';

// we are now building our error dialog
Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error occurred',
    content: text,
    // our optionsBuilder is a function which returns a map
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
