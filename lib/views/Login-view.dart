import 'package:flutter/material.dart';
import 'package:notes/constants/Routs.dart';
import 'package:notes/services/auth/auth_exeptions.dart';
import 'package:notes/services/auth/auth_service.dart';
import '../utilities/dialogs/error_dialog.dart';

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
    super.dispose;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
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
                await AuthService.firebase().login(
                  email: email,
                  password: password,
                );
                final user = AuthService.firebase().currentuser;
                if (user?.isEmailVerified ?? false) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verefiyRoute,
                    (route) => false,
                  );
                }
              } on UserNotFoundAuthExecption {
                await showErrorDialog(
                  context,
                  ('user not found'),
                );
              } on WrongpasswordAuthExecption {
                await showErrorDialog(
                  context,
                  ('wrong password'),
                );
              } on GenericAuthExecption {
                await showErrorDialog(
                  context,
                  'authintication Error',
                );
              } catch (e) {
                await showErrorDialog(
                  context,
                  e.toString(),
                );
              }
            }),
            child: const Text('Login'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text("not Regestired yet? click here"))
        ],
      ),
    );
  }
}
