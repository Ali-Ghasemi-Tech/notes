import 'package:flutter/material.dart';
import 'package:notes/constants/Routs.dart';
import 'package:notes/services/auth/auth_exeptions.dart';
import 'package:notes/services/auth/auth_service.dart';
import '../utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
    super.dispose;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Regestir")),
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
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                final userCredential = await AuthService.firebase().creatUser(
                  email: email,
                  password: password,
                );
                await AuthService.firebase().sendEmailVerefication();
                Navigator.of(context).pushNamed(verefiyRoute);
              } on WeakPasswordAuthExecption {
                await showErrorDialog(
                  context,
                  ('weak password'),
                );
              } on EmailAlredyInUseAuthExecption {
                await showErrorDialog(
                  context,
                  ('email already in use'),
                );
              } on InvalidEmailAuthExecption {
                await showErrorDialog(
                  context,
                  ('invalid email'),
                );
              } on GenericAuthExecption {
                await showErrorDialog(
                  context,
                  ' failed to register',
                );
              } catch (e) {
                await showErrorDialog(
                  context,
                  e.toString(),
                );
              }
            },
            child: const Text('Rigester'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text("if you are already logged in press here"))
        ],
      ),
    );
  }
}
