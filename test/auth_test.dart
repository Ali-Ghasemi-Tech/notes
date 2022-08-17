import 'package:notes/services/auth/auth_exeptions.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('mock authintication', () {
    final provider = MockAuthProvider();
    test("sholdn't be initialized in the first place", () {
      expect(provider.isInitialized, false);
    });
    test('logout should not be initialized', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    test('should be initialized now', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });
    test('want user to be null', () {
      expect(provider.currentuser, null);
    });
    test(
      'time out after 2 sec of not initializing',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 5)),
    );
    test('create user should connect with login', () async {
      final badEmailUser = provider.creatUser(
        email: "pog@gers.com",
        password: "anypassword",
      );
      expect(
        badEmailUser,
        throwsA(const TypeMatcher<UserNotFoundAuthExecption>()),
      );

      final badPassword = provider.creatUser(
        email: 'someone@gers.com',
        password: 'pog',
      );
      expect(badPassword,
          throwsA(const TypeMatcher<WrongpasswordAuthExecption>()));

      final user = await provider.creatUser(
        email: 'mewo',
        password: 'mewo',
      );
      expect(provider.currentuser, user);
      expect(user.isEmailVerified, false);
    });
    test('login user should be able to verifiy', () {
      provider.sendEmailVerefication();
      final user = provider.currentuser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test("should be able to login and logout", () {
      provider.logOut();
      provider.login(email: 'email', password: 'password');
      final user = provider.currentuser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> creatUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return login(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentuser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthExecption();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'pog@gers.com') throw UserNotFoundAuthExecption();
    if (password == 'pog') throw WrongpasswordAuthExecption();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> sendEmailVerefication() {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthExecption();
    const newuser = AuthUser(isEmailVerified: true);
    _user = newuser;
    throw UnimplementedError();
  }
}
