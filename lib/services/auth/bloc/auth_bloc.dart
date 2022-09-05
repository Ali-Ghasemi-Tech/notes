import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';

// it wants a provider of logic and we have that in auth provider
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUnInitialized(isLoading: true)) {
    // forgot email password
    on<AuthEventForgotPassword>(
      (event, emit) async {
        emit(const AuthStateForgotPassword(
          isLoading: false,
          exception: null,
          hasSentEmail: false,
        ));
        final email = event.email;
        // the user gets to the forgot password screen for the first time
        if (email == null) {
          return;
        }

        // user wants to send and email to forgotpassword
        emit(const AuthStateForgotPassword(
          isLoading: true,
          exception: null,
          hasSentEmail: false,
        ));
        bool didSnedEmail;
        Exception? exception;
        try {
          await provider.sendPasswordReset(toEmail: email);
          didSnedEmail = true;
          exception = null;
        } on Exception catch (e) {
          didSnedEmail = false;
          exception = e;
        }
        emit(
          AuthStateForgotPassword(
            isLoading: false,
            exception: exception,
            hasSentEmail: didSnedEmail,
          ),
        );
      },
    );
// send email verification
    on<AuthEventSentEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });
    // should register
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });
    // Register
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(
          email: email,
          password: password,
        );
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });
// there is nothing in initialize to be made so event doesn't do anything.
    // Initialize
    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;
        if (user == null) {
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
        } else if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
        }
      },
    );
    // Login
    on<AuthEventLogIn>(
      (event, emit) async {
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: true,
            loadingText: ('please wait until i log you in'),
          ),
        );

        // these requirements are for loging in a user
        final email = event.email;
        final password = event.password;
        // now we need to look for errors and exceptions
        //and then adjust our state
        try {
          final user = await provider.logIn(
            email: email,
            password: password,
          );
          if (!user.isEmailVerified) {
            emit(
              const AuthStateLoggedOut(
                exception: null,
                isLoading: false,
              ),
            );
            emit(
              const AuthStateNeedsVerification(isLoading: false),
            );
          } else {
            emit(
              const AuthStateLoggedOut(
                exception: null,
                isLoading: false,
              ),
            );
            emit(AuthStateLoggedIn(
              user: user,
              isLoading: false,
            ));
          }

          // since the errors are of type exception we need to define when we have this state
        } on Exception catch (e) {
          emit(
            AuthStateLoggedOut(
              exception: e,
              isLoading: false,
            ),
          );
        }
      },
    );
    // Logout
    on<AuthEventLogOut>(
      (event, emit) async {
        try {
          await provider.logOut();
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
        } on Exception catch (e) {
          emit(
            AuthStateLoggedOut(
              exception: e,
              isLoading: false,
            ),
          );
        }
      },
    );
  }
}
