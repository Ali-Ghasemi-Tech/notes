import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/views/Login-view.dart';
import 'package:notes/views/Register-view.dart';
import 'package:notes/views/Verefiy-email-view.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'flutter demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Homepage(),
      routes: {
        '/Login/': (context) => const LoginView(),
        '/Regestir/': (context) => const RegisterView()
      },
    ),
  );
}

class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
                print("you are verefied");
              } else {
                const VerifyEmailView();
              }
            } else {
              const LoginView();
            }
            return const Text("Done");
          default:
            return const CircularProgressIndicator.adaptive();
        }
      },
    );
  }
}
