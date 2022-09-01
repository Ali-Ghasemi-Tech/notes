import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart' show immutable;
import 'package:notes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateUnInitialized extends AuthState {
  const AuthStateUnInitialized();
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;

  const AuthStateRegistering(this.exception);
}

// why we making the exceptions in here?
// becuase if the user cant login then the state remains loggedout but with exceptions
class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  final bool isLoading;
  const AuthStateLoggedOut({
    required this.exception,
    required this.isLoading,
  });

  @override
  List<Object?> get props => [exception, isLoading];
}
