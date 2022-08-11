import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';

@immutable
class AuthUser {
  final bool isEmailVerefied;
  const AuthUser(this.isEmailVerefied);

  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}
