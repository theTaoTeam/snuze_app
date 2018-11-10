import 'dart:async';
import 'dart:convert';

import 'package:snuze/.env.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
// import 'package:firebase_auth/firebase_auth.dart';

import 'package:snuze/models/auth.dart';
import 'package:snuze/models/user.dart';

class ConnectedUserAlarmModel extends Model {
  String apiKey = FIREBASE_API_KEY;
  User _authenticatedUser;
  bool _isLoading = false;
}

mixin UserModel on ConnectedUserAlarmModel {
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
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=$apiKey',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=$apiKey',
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
          token: responseData['refreshToken']);
      _userSubject.add(true);
      final SharedPreferences prefs = await SharedPreferences
          .getInstance(); //gets required instance of device storage
      prefs.setString(
          'token', responseData['refreshToken']); //sets token in device storage
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
    print(prefs.getString('token'));
    if (token != null) {
      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      notifyListeners();
    }
  }

  Future<Null> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    print(email);
    final Map<String, String> oobRequestBody = {
      'kind': "identitytoolkit#relyingparty",
      'requestType': "PASSWORD_RESET",
      'email': email,
    };
    final http.Response getOob = await http.post(
      'https://www.googleapis.com/identitytoolkit/v3/relyingparty/getOobConfirmationCode?key=$apiKey',
      body: json.encode(oobRequestBody),
    );
    print('OOB: ${getOob.body}');
  }

  Future<Null> startFacebookLogin() async {
    _isLoading = true;
    notifyListeners();
    final FacebookLogin facebookSignIn = new FacebookLogin();
    final FacebookLoginResult result =
        await facebookSignIn.logInWithReadPermissions(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String userEmail = prefs.getString('userEmail');
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,email&access_token=${result.accessToken.token}');
        var profile = json.decode(graphResponse.body);
        print('''
         Logged in!
         device-storage: $userEmail
         accessToken: $accessToken
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         User profile: $profile
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');
        final Map<String, dynamic> authData = {
          'email': profile['email'],
          'password': profile['id'],
          'returnSecureToken': true,
        };
        http.Response response;
        response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=$apiKey',
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'},
        );
        final Map<String, dynamic> firstResponseData =
            json.decode(response.body);
        if (firstResponseData['error'] != null) {
          print('user not found. attempting to sign up ----------');
          response = await http.post(
            'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=$apiKey',
            body: json.encode(authData),
            headers: {'Content-Type': 'application/json'},
          );
        }
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('RESPONSE DATA $responseData');
        print(responseData['refreshToken']);
        if (responseData.containsKey('idToken')) {
          _userSubject.add(true);
          final SharedPreferences prefs = await SharedPreferences
              .getInstance(); //gets required instance of device storage
          prefs.setString('userEmail', responseData['email']);
          prefs.setString('userId', responseData['idToken']);
          prefs.setString('token', responseData['refreshToken']);
          _isLoading = false;
          notifyListeners();
        } else {
          print('something went wrong with the response $responseData');
          _isLoading = false;
          notifyListeners();
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('Login cancelled by the user.');
        _isLoading = false;
        notifyListeners();
        break;
      case FacebookLoginStatus.error:
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }
}

mixin UtilityModel on ConnectedUserAlarmModel {
  bool get isLoading {
    return _isLoading;
  }
}
