import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../models/auth.dart';
import '../../scoped-models/main.dart';

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
  var hasForgotPass = false;
  Map<String, String> _forgotPasswordEmail = {'email': null};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _newPasswordTextController =
      TextEditingController();
  AuthMode _authMode = AuthMode.Login;

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'E-Mail', filled: true, fillColor: Colors.white),
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
        labelText: 'Password',
        filled: true,
        fillColor: Colors.white,
      ),
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

  Widget _buildPasswordConfirmTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Confirm Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      validator: (String value) {
        if (_passwordTextController.text != value) {
          return 'Passwords do not match.';
        }
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
        _formData['email'], _formData['password'], _authMode);
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
          labelText: 'E-Mail', filled: true, fillColor: Colors.white),
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

  void _resetPass(Map<String, String> forgotPasswordData) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    _model.resetPassword(forgotPasswordData['email']);
    setState(() {
      hasForgotPass = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        body: Container(
          // decoration: BoxDecoration(
          //   image: _buildBackgroundImage(),
          // ),
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                  width: targetWidth,
                  child: !hasForgotPass
                      ? Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              // SizedBox(height: 150.0),
                              _buildEmailTextField(),
                              SizedBox(
                                height: 10.0,
                              ),
                              _buildPasswordTextField(),
                              SizedBox(
                                height: 10.0,
                              ),
                              _authMode == AuthMode.Signup
                                  ? _buildPasswordConfirmTextField()
                                  : Container(),
                              SizedBox(
                                height: 10.0,
                              ),
                              model.isLoading
                                  ? CircularProgressIndicator()
                                  : Column(
                                      children: <Widget>[
                                        RaisedButton(
                                          textColor: Colors.red,
                                          color: Colors.white,
                                          child: Text(
                                              _authMode == AuthMode.Login
                                                  ? 'LOGIN'
                                                  : 'SIGNUP'),
                                          onPressed: () =>
                                              _submitForm(model.authenticate),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        RaisedButton(
                                          color: Colors.red,
                                          textColor: Colors.white,
                                          child: Text('login with facebook'),
                                          onPressed: () {
                                            setState(() {
                                              print(
                                                  'login with facebook pressed!');
                                              model.startFacebookLogin();
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        RaisedButton(
                                          color: Colors.red,
                                          textColor: Colors.white,
                                          child: Text(
                                              _authMode == AuthMode.Login
                                                  ? 'create an account'
                                                  : 'back to login'),
                                          onPressed: () {
                                            setState(() {
                                              _authMode =
                                                  _authMode == AuthMode.Login
                                                      ? AuthMode.Signup
                                                      : AuthMode.Login;
                                            });
                                          },
                                        ),
                                        FlatButton(
                                          child: Text('forgot password?'),
                                          onPressed: () {
                                            print('Forgot Password pressed!');
                                            setState(() {
                                              hasForgotPass = true;
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
                              SizedBox(),
                              RaisedButton(
                                textColor: Colors.red,
                                color: Colors.white,
                                child: Text('Reset Password'),
                                onPressed: () {
                                  _resetPass(_forgotPasswordEmail);
                                },
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              RaisedButton(
                                color: Colors.red,
                                textColor: Colors.white,
                                child: Text('back to login'),
                                onPressed: () {
                                  setState(() {
                                    hasForgotPass = false;
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
