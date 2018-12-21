import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:snuze/scoped-models/main.dart';
import 'package:snuze/pages/auth/credit_card_form.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignUpPageState();
  }
}

class _SignUpPageState extends State<SignUpPage> {
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'number': '',
    'expMonth': null,
    'expYear': null,
    'cvc': '',
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();

  Widget _buildTitleText(double targetWidth) {
    return Container(
        width: targetWidth,
        margin: EdgeInsets.only(right: 30),
        child: Text(
          "We're going to need a few things...",
          style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              fontFamily: 'Montserrat-bold'),
          textAlign: TextAlign.left,
        ));
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'email',
        labelStyle: new TextStyle(color: Colors.white),
        filled: true,
        fillColor: Color.fromRGBO(255, 255, 255, 0.2),
        errorStyle: TextStyle(color: Colors.white),
      ),
      style: new TextStyle(height: .3, fontFamily: 'Montserrat'),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value.trim())) {
          return 'Double check your email';
        }
      },
      onSaved: (String value) {
        _formData['email'] = value.trim();
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
        errorStyle: TextStyle(color: Colors.white),
      ),
      style: new TextStyle(height: .3, fontFamily: 'Montserrat'),
      obscureText: true,
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty || value.trim().length < 6) {
          return 'Double check your password';
        }
      },
      onSaved: (String value) {
        _formData['password'] = value.trim();
      },
    );
  }

  void _submitForm(Function register) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    Map<String, dynamic> cardInfo = {
      "number": _formData['number'],
      "expMonth": _formData['expMonth'],
      "expYear": _formData['expYear'],
      "cvc": _formData['cvc'],
    };

    try {
      await register(_formData['email'], _formData['password'], cardInfo);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print(e.toString());
      try {
        print(e.cause);
      } catch(e) {
        print("couldn't print cause");
      }
      print("Register Error on SignUp Page");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Aw Geeze!'),
            content: Text("Error"),
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

  void updateCardInfo(Map<String, dynamic> ccInfo) {
    ccInfo.forEach((key, value) {
      setState(() {
        _formData[key] = value;
      });
    });
    print(_formData);
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.75;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Color(0xFFFE2562),
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
        ),
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
          child: Center(
            child: SingleChildScrollView(
              reverse: true,
              child: Container(
                margin: EdgeInsets.only(bottom: 75),
                width: targetWidth,
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        _buildTitleText(targetWidth),
                        SizedBox(
                          height: 35,
                        ),
                        _buildEmailTextField(),
                        SizedBox(
                          height: 10.0,
                        ),
                        _buildPasswordTextField(),
                        SizedBox(
                          height: 10.0,
                        ),
                        CreditCardForm(onCardChange: updateCardInfo),
                        // Column(children: <Widget>[
                        //         CircularProgressIndicator(
                        //             valueColor: AlwaysStoppedAnimation<Color>(
                        //                 Colors.white)),
                        //         SizedBox(
                        //           height: 15,
                        //         )
                        //       ])
                        Column(
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: targetWidth,
                              height: 40,
                              child: RaisedButton(
                                highlightElevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                textColor: Colors.red,
                                color: Colors.white,
                                splashColor: Color(0xFFFE2562),
                                child: Text(
                                  'get snuzing',
                                  style: TextStyle(
                                      fontSize: 20, fontFamily: 'Montserrat'),
                                ),
                                onPressed: () => _submitForm(model.register),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ),
      );
    });
  }
}
