import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'email'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(hintText: 'password'),
          ),
          TextButton(
            onPressed: (() async {
              final email = _email.text;
              final password = _password.text;
              try {
                final UserCredential = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: email, password: password);
                print(UserCredential);
                print('logged in');
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  print('user not found');
                  print(e.code);
                } else if (e.code == 'wrong-password') {
                  print('wrong password');
                }
              }
            }),
            child: const Text('Login'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/Regestir/', (route) => false);
              },
              child: const Text("not Regestired yet? click here"))
        ],
      ),
    );
  }
}
