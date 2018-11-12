import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:snuze/models/auth.dart';
import 'package:snuze/scoped-models/main.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  final MainModel _model = new MainModel();
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
  };
  var _hasForgotPass = false;
  Map<String, String> _forgotPasswordEmail = {'email': null};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'email',
        labelStyle: new TextStyle(color: Colors.white),
        filled: true,
        fillColor: Color.fromRGBO(255, 255, 255, 0.2),
        border: InputBorder.none,
      ),
      style: new TextStyle(height: .3),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Double check your email';
        }
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'password',
        labelStyle: new TextStyle(color: Colors.white),
        filled: true,
        fillColor: Color.fromRGBO(255, 255, 255, 0.2),
        border: InputBorder.none,        
      ),
      style: new TextStyle(height: .3),
      obscureText: true,
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return 'Double check your password';
        }
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  void _submitForm(Function authenticate) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    Map<String, dynamic> successInformation;
    successInformation = await authenticate(
      _formData['email'],
      _formData['password'],
      _authMode,
    );
    if (successInformation['success']) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('An Error Occurred!'),
            content: Text(successInformation['message']),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }
  }

  Widget _buildForgotPassEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'email',
        labelStyle: new TextStyle(color: Colors.white),
        filled: true,
        fillColor: Color.fromRGBO(255, 255, 255, 0.2),
        border: InputBorder.none,
      ),
      style: new TextStyle(height: .3),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Double check your email';
        }
      },
      onSaved: (String value) {
        _forgotPasswordEmail['email'] = value;
      },
    );
  }

  void _navigateToSignUpPage(AuthMode _authmode) {
    Navigator.pushNamed(context, '/signup');
  }

  void _resetPass(Map<String, String> forgotPasswordData) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    _model.resetPassword(forgotPasswordData['email']);
    setState(() {
      _hasForgotPass = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.75;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  0,
                  0.58,
                  1,
                ],
                colors: [
                  Color(0xFFFE2562),
                  Color(0xFFFE355A),
                  Color(0xFFFFB52E),
                ]),
          ),
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                  margin: new EdgeInsets.fromLTRB(0, 200, 0, 0),
                  width: targetWidth,
                  child: !_hasForgotPass
                      ? Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              _buildEmailTextField(),
                              SizedBox(
                                height: 10.0,
                              ),
                              _buildPasswordTextField(),
                              SizedBox(
                                height: 30.0,
                                child: Center(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              model.isLoading
                                  ? CircularProgressIndicator()
                                  : Column(
                                      children: <Widget>[
                                        Container(
                                          width: targetWidth,
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25)),
                                            textColor: Colors.red,
                                            color: Colors.white,
                                            child: Text('login'),
                                            onPressed: () =>
                                                _submitForm(model.authenticate),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 0.5,
                                        ),
                                        Container(
                                            color: Color.fromRGBO(
                                                255, 255, 255, 0),
                                            width: targetWidth,
                                            child: OutlineButton(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0),
                                              textColor: Colors.white,
                                              highlightedBorderColor:
                                                  Colors.transparent,
                                              child:
                                                  Text('login with facebook'),
                                              onPressed: () {
                                                setState(() {
                                                  print(
                                                      'login with facebook pressed!');
                                                  model.startFacebookLogin();
                                                });
                                              },
                                            )),
                                        SizedBox(
                                          height: 0.5,
                                        ),
                                        Container(
                                          width: targetWidth,
                                          child: OutlineButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            color: Color.fromRGBO(
                                                255, 255, 255, 0),
                                            textColor: Colors.white,
                                            highlightedBorderColor:
                                                Colors.transparent,
                                            highlightColor: Color.fromRGBO(
                                                255, 255, 255, 0.2),
                                            highlightElevation: 3,
                                            child: Text('create an account'),
                                            onPressed: () {
                                              setState(() {
                                                _navigateToSignUpPage(
                                                    _authMode);
                                              });
                                            },
                                          ),
                                        ),
                                        FlatButton(
                                          textColor: Colors.white,
                                          child: Text('forgot password?'),
                                          onPressed: () {
                                            print('Forgot Password pressed!');
                                            setState(() {
                                              _hasForgotPass = true;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                            ],
                          ))
                      : Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              _buildForgotPassEmailField(),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: targetWidth,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  textColor: Colors.red,
                                  color: Colors.white,
                                  child: Text('Reset Password'),
                                  onPressed: () {
                                    _resetPass(_forgotPasswordEmail);
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 0.5,
                              ),
                              FlatButton(
                                textColor: Colors.white,
                                child: Text('cancel'),
                                onPressed: () {
                                  setState(() {
                                    _hasForgotPass = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        )),
            ),
          ),
        ),
      );
    });
  }
}
