import 'package:flutter/cupertino.dart';
import 'package:notes/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'are you sure you want to delete this note?',
    optionsBuilder: () => {
      'cancle': false,
      'delete': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
