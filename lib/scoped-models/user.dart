import 'dart:async';
import 'dart:convert';

import 'package:snuze/.env.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:snuze/helpers/stripe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:snuze/models/auth.dart';
import 'package:snuze/models/user.dart';

mixin UserModel on Model {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudFunctions _functions = CloudFunctions.instance;
  final Firestore _firestore = Firestore.instance;
  String apiKey = FIREBASE_API_KEY;
  FirebaseUser _user;
  bool _isLoading = false;
  PublishSubject<bool> _userSubject = PublishSubject();
  PublishSubject<bool> _themeSubject = PublishSubject();
  FirebaseUser get user {
    return _user;
  }

  Future<FirebaseUser> register(
      String email, String password, Map<String, dynamic> cardInfo) async {
    FirebaseUser newUser;
    try {
      String stripeToken = await requestStripeToken(cardInfo);
      newUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Map<String, String> stripeParams = {
        'email': email,
        'source': stripeToken,
      };
      String stripeCustomerId = await _functions.call(
          functionName: "createStripeUser", parameters: stripeParams);
      DocumentReference userDocRef = await _createFirestoreUser(
          uid: newUser.uid, stripeId: stripeCustomerId);
      DocumentReference invoiceDocRef =
          await _createInvoice(userDocRef: userDocRef);
      Map<String, dynamic> invoiceData = {
        "invoiceRefs": [invoiceDocRef],
        "activeInvoice": invoiceDocRef
      };
      await _updateUser(userData: invoiceData, userDocRef: userDocRef);
      return newUser;
    } catch (err) {
      print("error creating user: " + err);
      throw (new Error());
    }
  }

  Future<DocumentReference> _createFirestoreUser(
      {String uid, String stripeId}) async {
    DocumentReference userDocRef = _firestore.collection("users").document(uid);
    Map<String, String> userData = {"uid": uid, "stripeId": stripeId};
    try {
      await userDocRef.setData(userData);
      return userDocRef;
    } catch (err) {
      print("Err creating firestore user: " + err);
      throw (new Error());
    }
  }

  Future<DocumentReference> _createInvoice(
      {DocumentReference userDocRef}) async {
    DocumentReference invoiceDocRef =
        _firestore.collection("invoices").document();
    Map<String, dynamic> invoiceData = {
      "billed": false,
      "currentTotal": 0,
      "id": invoiceDocRef,
      "snuzeRefs": [],
      "userRef": userDocRef,
    };
    try {
      await invoiceDocRef.setData(invoiceData);
      return invoiceDocRef;
    } catch (err) {
      print("Err creating invoice: " + err);
      throw (new Error());
    }
  }

  Future<void> _updateUser(
      {DocumentReference userDocRef, Map<String, dynamic> userData}) async {
    try {
      return await userDocRef.updateData(userData);
    } catch (err) {
      print("Err updating user: " + err);
      throw (new Error());
    }
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

  void logout() async {
    _isLoading = true;
    notifyListeners();
    _userSubject.add(false);
    // _authenticatedUser = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
    prefs.remove('darkTheme');
    _isLoading = false;
    notifyListeners();
  }

  Future<Null> fetchUserSettings() async {
    _isLoading = true;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');
    final theme = prefs.getBool('darkTheme');
    // print("USER IN FETCHSETTINGS $_authenticatedUser");
    // _authenticatedUser = new User(
    //   id: _authenticatedUser.id,
    //   email: email,
    //   token: _authenticatedUser.token,
    //   darkTheme: theme,
    // );
    _isLoading = false;
    notifyListeners();
    return;
  }

  Future<Null> saveUserSettings(Map<String, dynamic> settings) async {
    _isLoading = true;
    _themeSubject.add(settings['darkTheme']);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userEmail', settings['email']);
    prefs.setBool('darkTheme', settings['darkTheme']);
    // print(_authenticatedUser);
    // _authenticatedUser = User(
    //   id: _authenticatedUser.id,
    //   email: settings['email'],
    //   token: _authenticatedUser.token,
    //   darkTheme: settings['darkTheme'],
    // );
    _isLoading = false;
    notifyListeners();
  }

  void getUserTheme(bool darkTheme) {
    _isLoading = true;
    notifyListeners();
    print('theme subject: $_themeSubject');
    _themeSubject.add(darkTheme);

    _isLoading = false;
    notifyListeners();
  }

  Future<Null> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    print('About to send email to: $email');

    final Map<String, String> oobRequestBody = {
      'kind': "identitytoolkit#relyingparty",
      'requestType': "PASSWORD_RESET",
      'email': email,
    };
    http.Response getOob;
    try {
      getOob = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/getOobConfirmationCode?key=$apiKey',
        body: json.encode(oobRequestBody),
      );
    } catch (error) {
      print('OOB error: $error');
    }

    _isLoading = false;
    notifyListeners();

  }
}
