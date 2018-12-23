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
  var isLoading = false;
  FirebaseUser get currentUser {
    return _currentUser;
  }

  Future<void> register(
      String email, 
      String password, 
      Map<String, dynamic> cardInfo
  ) async {
    isLoading = true;
    notifyListeners();
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
      Map<dynamic, dynamic> stripeCustomerInfo = await _functions.call(
          functionName: "createStripeUser", parameters: stripeParams);
      String stripeCustomerId = stripeCustomerInfo['id'];
      await _createFirestoreUserWithInvoice(
          uid: newUser.uid, stripeId: stripeCustomerId);
      _currentUser = newUser;
      isLoading = false;
      notifyListeners();
    } on PlatformException catch (e) {
      isLoading = false;
      notifyListeners();
      CausedException exception = getCausedExceptionWithErrorCode(code: e.code);
      newUser.delete();
      throw exception;
    } on CausedException catch (e) {
      isLoading = false;
      notifyListeners();
      e.debugPrint();
      throw e;
    } catch (err) {
      isLoading = false;
      notifyListeners();
      print("error creating user: " + err.toString());
      newUser.delete();
      throw new CausedException(
          cause: 'Registration Function',
          code: '6',
          message: 'unknown registration error',
          userMessage: "Looks like we messed up this time, mind trying again?");
    }
  }

  Future<void> _createFirestoreUserWithInvoice(
      {String uid, String stripeId}) async {
    WriteBatch batch = _firestore.batch();
    // create document references
    DocumentReference invoiceDocRef =
        _firestore.collection("invoices").document();
    DocumentReference userDocRef = _firestore.collection("users").document(uid);

    // set initial data
    Map<String, dynamic> invoiceData = {
      "billed": false,
      "currentTotal": 0,
      "id": invoiceDocRef.documentID,
      "snuzeRefs": [],
      "userRef": userDocRef,
    };
    batch.setData(invoiceDocRef, invoiceData);
    Map<String, dynamic> userData = {
      'uid': uid,
      'stripeId': stripeId,
      'invoiceRefs': [invoiceDocRef],
      'activeInvoice': invoiceDocRef,
    };

    batch.setData(userDocRef, userData);
    try {
      await batch.commit();
    } catch (e) {
      print(e.toString());
      throw new CausedException(
          cause: "Firestore",
          message: "batched write error",
          code: "1",
          userMessage:
              "We're having issues setting up your account, please check your connection and give it another go.");
    }
  }

  // Future<DocumentReference> _createFirestoreUser({String uid, String stripeId}) async {
  //   DocumentReference userDocRef = _firestore.collection("users").document(uid);
  //   Map<String, String> userData = {"uid": uid, "stripeId": stripeId};
  //   try {
  //     await userDocRef.setData(userData);
  //     return userDocRef;
  //   } catch (err) {
  //     print(err.toString());
  //     throw new CausedException(cause: "Firestore Error", code: "1", message: "error while creating user in cloud firestore", userMessage: "Something went wrong, please check your network connection and try again!");
  //   }
  // }

  // candidate for moving to invoice scoped-model
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
      print(err.toString());
      throw new CausedException(
          cause: "Firestore Error",
          code: "2",
          message: "error while creating invoice in cloud firestore",
          userMessage:
              "Something went wrong, please check your network connection and try again!");
    }
  }

  Future<void> _updateUser(
      {DocumentReference userDocRef, Map<String, dynamic> userData}) async {
    try {
      return await userDocRef.updateData(userData);
    } catch (err) {
      print(err.toString());
      throw new CausedException(
          cause: "Firestore Error",
          code: "3",
          message: "error while updating user",
          userMessage:
              "Something went wrong, please check your network connection and try again!");
    }
  }

  Future<void> fetchUser() async {
    print('FETCHING USER');
    _currentUser = await _auth.currentUser();
    notifyListeners();
  }

  Future<void> login({String email, String password}) async {
    isLoading = true;
    notifyListeners();
    try {
      FirebaseUser user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _currentUser = user;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      throw new CausedException(
          cause: 'Firebase Auth',
          code: "4",
          message: 'login error',
          userMessage:
              "It looks like your email and password don't match, give it another shot.");
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      throw new CausedException(
          cause: 'Firebase Auth',
          code: "5",
          message: 'logout error',
          userMessage:
              "We're having issues logging you out, sorry about that.");
    }
  }

  void resetPassword(String email) {
    print("sending reset password email...");
    _auth.sendPasswordResetEmail(email: email);
  }

  void _handleTimeoutError() {
    Timer(Duration(seconds: 20), () {
      isLoading = false;
      notifyListeners();
      throw new CausedException(
          cause: "Timeout Error",
          code: "1",
          message: "timeout error while authenticating user",
          userMessage:
              "Something went wrong, please check your network connection and try again!");
    });
  }
}
