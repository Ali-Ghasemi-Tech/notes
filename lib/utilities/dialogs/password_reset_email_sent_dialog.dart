import 'package:flutter/cupertino.dart';
import 'package:notes/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Password Reset',
    content: 'we sent you and email for reseting your password',
    optionsBuilder: () => {'OK': null},
  );
}
