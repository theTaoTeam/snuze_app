import 'dart:async';
import 'dart:convert';

import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/auth.dart';
import '../models/user.dart';

class ConnectedUserAlarmModel extends Model {
  User _authenticatedUser;
  bool _isLoading = false;
}

class UserModel extends ConnectedUserAlarmModel {
  PublishSubject<bool> _userSubject = PublishSubject();
  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyC47HhW4oK9NHk7Yng6iDjs2AYvoB02LWk',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyC47HhW4oK9NHk7Yng6iDjs2AYvoB02LWk',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong.';
    print(responseData);
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication succeeded!';
      _authenticatedUser = User(
          id: responseData['localId'],
          email: email,
          token: responseData['idToken']);
      _userSubject.add(true);
      final SharedPreferences prefs = await SharedPreferences
          .getInstance(); //gets required instance of device storage
      prefs.setString(
          'token', responseData['idToken']); //sets token in device storage
      prefs.setString('userEmail', email);
      prefs.setString('userId', responseData['localId']);
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists.';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found.';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'The password is invalid.';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    if (token != null) {
      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      notifyListeners();
    }
  }

  void startFacebookLogin() async {
    var facebookLogin = new FacebookLogin();
    var result = await facebookLogin.logInWithReadPermissions(['email']);
    print(result);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        FirebaseAuth.instance
            .signInWithFacebook(accessToken: result.accessToken.token);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("Facebook sign in cancelled by user");
        break;
      case FacebookLoginStatus.error:
        print("Facebook sign in failed");
        break;
    }
  }
}

class UtilityModel extends ConnectedUserAlarmModel {
  bool get isLoading {
    return _isLoading;
  }
}
