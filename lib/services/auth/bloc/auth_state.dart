import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart' show immutable;
import 'package:notes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    this.loadingText = 'please wait a moment',
    required this.isLoading,
  });
}

class AuthStateUnInitialized extends AuthState {
  const AuthStateUnInitialized({required bool isLoading})
      : super(
          isLoading: isLoading,
        );
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({required this.user, required bool isLoading})
      : super(
          isLoading: isLoading,
        );
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required bool isLoading})
      : super(
          isLoading: isLoading,
        );
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;

  const AuthStateRegistering({required this.exception, required isLoading})
      : super(
          isLoading: isLoading,
        );
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;

  const AuthStateForgotPassword({
    required bool isLoading,
    required this.exception,
    required this.hasSentEmail,
  }) : super(isLoading: isLoading);
}

// why we making the exceptions in here?
// becuase if the user cant login then the state remains loggedout but with exceptions
class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut({
    required this.exception,
    required bool isLoading,
    String? loadingText,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}
