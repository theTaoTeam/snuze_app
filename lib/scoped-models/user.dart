import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:snuze/helpers/stripe.dart';
import 'package:snuze/helpers/exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

mixin UserModel on Model {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudFunctions _functions = CloudFunctions.instance;
  final Firestore _firestore = Firestore.instance;
  FirebaseUser _currentUser;
  FirebaseUser get currentUser {
    return _currentUser;
  }

  Future<void> register(String email, String password, Map<String, dynamic> cardInfo) async {
    FirebaseUser newUser;
    try {
      String stripeToken = await requestStripeToken(cardInfo);
      newUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      print("UID: " + newUser.uid);
      Map<String, String> stripeParams = {
        'email': email,
        'source': stripeToken,
      };
      Map<dynamic,dynamic> stripeCustomerInfo = await _functions.call(
          functionName: "createStripeUser", parameters: stripeParams);
      String stripeCustomerId = stripeCustomerInfo['id'];
      DocumentReference userDocRef = await _createFirestoreUser(
          uid: newUser.uid, stripeId: stripeCustomerId);
      DocumentReference invoiceDocRef =
          await _createInvoice(userDocRef: userDocRef);
      Map<String, dynamic> invoiceData = {
        "invoiceRefs": [invoiceDocRef],
        "activeInvoice": invoiceDocRef
      };
      await _updateUser(userData: invoiceData, userDocRef: userDocRef);
      _currentUser = newUser;
      notifyListeners();
    } on PlatformException catch (e) {
      Exception exception = getFirebaseAuthExceptionWithErrorCode(code: e.code);
      newUser.delete();
      throw exception;
    } catch (err) {
      print("error creating user: " + err.toString());
      newUser.delete();
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
      print("Err creating firestore user: " + err.toString());
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
      print("Err creating invoice: " + err.toString());
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

  Future<void> fetchUser() async {
    print('FETCHING USER');
    _currentUser = await _auth.currentUser();
    notifyListeners();
  }

  Future<void> login({String email, String password}) async {
    try {
      FirebaseUser user = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _currentUser = user;
      notifyListeners();
    } catch(e) {
      throw new LoginException(cause: 'Incorrect username or password');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      print("LOGGING OUT");
      _currentUser = null;
      print(_currentUser);
      notifyListeners();
    } catch(e) {
      print('ERROR LOGGING OUT');
    }
  }
}
