import 'package:notes/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialize();
  AuthUser? get currentuser;
  Future<AuthUser?> login({
    required String email,
    required String password,
  });
  Future<AuthUser?> creatUser({
    required String email,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendEmailVerefication();
}
