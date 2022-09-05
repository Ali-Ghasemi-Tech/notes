import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/utilities/dialogs/error_dialog.dart';
import 'package:notes/utilities/dialogs/password_reset_email_sent_dialog.dart';

import '../services/auth/bloc/auth_bloc.dart';
import '../services/auth/bloc/auth_state.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            await showErrorDialog(context, 'could not process you request');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Reset Password')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'if you forgot your password just enter your email for furture instrucions'),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                controller: _controller,
                decoration: const InputDecoration(hintText: 'enter your email'),
              ),
              TextButton(
                  onPressed: () {
                    final email = _controller.text;
                    context
                        .read<AuthBloc>()
                        .add(AuthEventForgotPassword(email: email));
                  },
                  child: const Text('send me password reset link')),
              TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  child: const Text('back to loging page'))
            ],
          ),
        ),
      ),
    );
  }
}
