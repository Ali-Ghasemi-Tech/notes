import 'package:flutter/material.dart';
import 'package:notes/constants/Routs.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/views/Login-view.dart';
import 'package:notes/views/Notes/new_notes_view.dart';
import 'package:notes/views/Register-view.dart';
import 'package:notes/views/Verefiy-email-view.dart';
import 'package:notes/views/Notes/notes_view.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'flutter demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Homepage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const Notesview(),
        verefiyRoute: (context) => const VerifyEmailView(),
        newNotesRoute: (context) => const NewNoteView()
      },
    ),
  );
}

class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentuser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const Notesview();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
