import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/auth_user.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  @override
  Future<AuthUser?> creatUser({
    required String email,
    required String password,
  }) =>
      provider.creatUser(
        email: email,
        password: password,
      );

  @override
  AuthUser? get currentuser => provider.currentuser;

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<AuthUser?> login({
    required String email,
    required String password,
  }) =>
      provider.login(
        email: email,
        password: password,
      );

  @override
  Future<void> sendEmailVerefication() => provider.sendEmailVerefication();
}
