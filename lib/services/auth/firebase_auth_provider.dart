import 'package:notes/services/auth/auth_user.dart';
import 'package:notes/services/auth/auth_exeptions.dart';
import 'package:notes/services/auth/auth_provider.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser?> creatUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentuser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthExecption();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        throw WeakPasswordAuthExecption();
      } else if (e.code == "email-already-in-use") {
        throw EmailAlredyInUseAuthExecption();
      } else if (e.code == "invalid-email") {
        throw InvalidEmailAuthExecption();
      } else {
        throw GenericAuthExecption();
      }
    } catch (e) {
      throw GenericAuthExecption();
    }
  }

  @override
  AuthUser? get currentuser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<void> logOut() async {
    FirebaseAuth.instance.currentUser;
    final user = currentuser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthExecption();
    }
  }

  @override
  Future<AuthUser?> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentuser;
      if (user != null) {
        return user;
      } else {
        throw UserNotFoundAuthExecption();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthExecption();
      } else if (e.code == 'wrong-password') {
        throw WrongpasswordAuthExecption();
      } else {
        throw GenericAuthExecption();
      }
    } catch (e) {
      throw GenericAuthExecption();
    }
  }

  @override
  Future<void> sendEmailVerefication() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return sendEmailVerefication();
    } else {
      throw UserNotLoggedInAuthExecption();
    }
  }
}
