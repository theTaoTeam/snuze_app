import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';

class UpdatePaymentForm extends StatelessWidget {
  final Function onCardChange;

  UpdatePaymentForm({this.onCardChange});

  Widget _buildCCNumberField() {
    return Container(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'XXXXXXXXXXXXXXXX',
            labelStyle: new TextStyle(color: Color(0xFFDFDFDF)),
            filled: true,
            fillColor: Color.fromRGBO(255, 255, 255, 0.2),
            border: InputBorder.none,
          ),
          style: new TextStyle(height: .3),
          keyboardType: TextInputType.number,
          validator: (String value) {
            if (value.isEmpty || value.length != 16) {
              return 'please enter a valid credit card number';
            }
          },
          onSaved: (String value) {
            onCardChange(<String, String>{'number': value});
          },
        ));
  }

  Widget _buildExpMonthField() {
    return Container(
        margin: EdgeInsets.only(left: 55),
        width: 52,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'MM',
            labelStyle: new TextStyle(color: Color(0xFFDFDFDF)),
            filled: true,
            fillColor: Color.fromRGBO(255, 255, 255, 0.2),
            border: InputBorder.none,
          ),
          style: new TextStyle(height: .3),
          keyboardType: TextInputType.number,
          validator: (String value) {
            if (value.isEmpty || value.length != 2) {
              return 'please enter a valid exp month';
            }
          },
          onSaved: (String value) {
            var val = int.tryParse(value);
            if (val == null) {
              print('Error parsing expMonth');
            }
            onCardChange(<String, int>{'expMonth': val});
          },
        ));
  }

  Widget _buildExpYearField() {
    return Container(
        margin: new EdgeInsets.fromLTRB(5, 0, 20, 0),
        width: 63,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'YYYY',
            labelStyle: new TextStyle(color: Color(0xFFDFDFDF)),
            filled: true,
            fillColor: Color.fromRGBO(255, 255, 255, 0.2),
            border: InputBorder.none,
          ),
          style: new TextStyle(
            height: .3,
          ),
          keyboardType: TextInputType.number,
          validator: (String value) {
            if (value.isEmpty || value.length != 4) {
              return 'please enter a valid exp year';
            }
          },
          onSaved: (String value) {
            var val = int.tryParse(value);
            if (val == null) {
              print('Error parsing expMonth');
            }
            onCardChange(<String, int>{'expYear': val});
          },
        ));
  }

  Widget _buildCvcField() {
    return Container(
        width: 113,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'CVC',
            labelStyle: new TextStyle(color: Color(0xFFDFDFDF)),
            filled: true,
            fillColor: Color.fromRGBO(255, 255, 255, 0.2),
            border: InputBorder.none,
          ),
          style: new TextStyle(height: .3),
          keyboardType: TextInputType.number,
          validator: (String value) {
            if (value.isEmpty || value.length != 3) {
              return 'please enter a valid cvc';
            }
          },
          onSaved: (String value) {
            onCardChange(<String, String>{'cvc': value});
          },
        ));
  }

  Widget _buildDivider(double targetWidth, bool isFullWidth) {
    return SizedBox(
      width: targetWidth,
      height: 20.0,
      child: Center(
        child: Container(
          margin: isFullWidth ? EdgeInsets.all(0) : EdgeInsets.only(left: 80),
          height: 1,
          color: Color(0xFFA1A1A1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.75;
    return Column(
      children: <Widget>[
        SizedBox(height: 5),
        _buildCCNumberField(),
        _buildDivider(targetWidth, true),
        Row(
          children: <Widget>[
            _buildCvcField(),
            SizedBox(height: 10.0),
            _buildExpMonthField(),
            SizedBox(height: 10.0),
            _buildExpYearField(),
          ],
        ),
      ],
    );
  }
}
