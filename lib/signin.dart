import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);
  Duration get loginTime => const Duration(milliseconds: 200);

  Future<String?> _authUser(LoginData data) {
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  String? _validateUser(String? user) {
    return null;
  }

  String? _validatePassword(String? pswd) {
    return null;
  }

  Future<String?> _signupUser(SignupData data) {
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String?> _recoverPassword(String name) {
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'DaaS',
      logo: const AssetImage('images/logo.png'),
      userType: LoginUserType.name,
      userValidator: _validateUser,
      passwordValidator: _validatePassword,
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacementNamed('/');
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}
