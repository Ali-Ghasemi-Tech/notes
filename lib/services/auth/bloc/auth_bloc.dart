import 'dart:html';

import 'package:bloc/bloc.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';

// it wants a provider of logic and we have that in auth provider
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
// there is nothing in initialize to be made so event doesn't do anything.
    // Initialize
    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;
        if (user == null) {
          emit(const AuthStateLoggedOut());
        } else if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerification());
        } else {
          emit(AuthStateLoggedIn(user));
        }
      },
    );
    // Login
    on<AuthEventLogIn>(
      (event, emit) async {
        // we are loading while waiting for the login
        emit(const AuthStateLoading());
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
          emit(AuthStateLoggedIn(user));
          // since the errors are of type exception we need to define when we have this state
        } on Exception catch (e) {
          emit(AuthStateLoginFailure(e));
        }
      },
    );
    // Logout
    on<AuthEventLogOut>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut());
      } on Exception catch (e) {
        emit(AuthStateLogoutFailure(e));
      }
    });
  }
}
