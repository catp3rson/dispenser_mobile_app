import 'package:dio/dio.dart';
import 'package:dispenser_mobile_app/API.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.setAuth, required this.setUser})
      : super(key: key);
  final Function(String) setAuth;
  final Function(Map<String, dynamic>) setUser;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var token = '';
  Duration get loginTime => const Duration(milliseconds: 200);

  Future<String?> _authUser(LoginData data) {
    if (data.name == '' || data.password == '') {
      return Future.value('Please enter your username and password');
    }
    var dio = Dio();
    var url = apiURL + '/account/signin';
    return dio.post(url, data: {
      "email": data.name,
      "password": data.password,
    }).then((response) async {
      if (response.statusCode == 200) {
        setState(() {
          token = response.data['access_token'];
        });
        widget.setAuth(response.data['access_token']);
        await request(RequestType.getRequest, apiURL + '/account/about', token)
            .then((value) => widget.setUser(value.data));
        return null;
      } else {
        return '${response.statusCode}: ${response.statusMessage}';
      }
    }).catchError((e) => Future.value('${e.response.data['detail']}'));
  }

  String? _validateUser(String? user) {
    return null;
  }

  String? _validatePassword(String? pswd) {
    return null;
  }

  Future<String?> _signupUser(SignupData data) {
    return Future.value('Not implemented');
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
        Navigator.of(context).pushReplacementNamed('/home');
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}
