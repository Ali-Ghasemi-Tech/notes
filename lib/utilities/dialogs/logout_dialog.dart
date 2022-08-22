import 'package:flutter/cupertino.dart';
import 'package:notes/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogoutDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Logout',
    content: 'are you sure you want to logout?',
    optionsBuilder: () => {
      'cancle': false,
      'Logout': true,
    },
  ).then((value) => value ?? false);
}
