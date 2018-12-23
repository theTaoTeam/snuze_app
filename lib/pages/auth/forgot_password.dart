import 'package:flutter/material.dart';
import 'package:snuze/scoped-models/main.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgotPasswordPageState();
  }
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MainModel _model = new MainModel();
  Map<String, String> _forgotFormData = {
    'email': null,
  };

  Widget _buildTitleText(double targetWidth) {
    return Container(
        margin: EdgeInsets.only(right: 70),
        child: Text(
          "Forgot your password? Oh well, we'll send you an email.",
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            fontFamily: 'Montserrat-bold',
          ),
          textAlign: TextAlign.left,
        ));
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
        _forgotFormData['email'] = value.trim();
        print(_forgotFormData);
      },
    );
  }

  void _resetPass(Map<String, String> _forgotFormData) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    _model.resetPassword(_forgotFormData['email']);
    Navigator.pop(context, "check your email!");
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.75;
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
                  margin: EdgeInsets.only(bottom: 150),
                  width: targetWidth,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        _buildTitleText(targetWidth),
                        SizedBox(
                          height: 30,
                        ),
                        _buildForgotPassEmailField(),
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
                            splashColor: Color(0xFFFE355A),
                            highlightColor: Colors.transparent,
                            color: Colors.white,
                            child: Text(
                              'reset password',
                              style: TextStyle(fontFamily: 'Montserrat'),
                            ),
                            onPressed: () {
                              _resetPass(_forgotFormData);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }
}
