import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class UpdatePaymentForm extends StatelessWidget {
  final Function onCardChange;

  UpdatePaymentForm({this.onCardChange});

  Widget _buildCCNumberField(BuildContext context) {
    return Container(
        child: TextFormField(
      decoration: InputDecoration(
        labelText: 'XXXXXXXXXXXXXXXX',
        labelStyle: new TextStyle(color: Theme.of(context).disabledColor),
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

  Widget _buildExpMonthField(BuildContext context) {
    return Container(
        width: 52,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'MM',
            labelStyle: new TextStyle(color: Theme.of(context).disabledColor),
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

  Widget _buildExpYearField(BuildContext context) {
    return Container(
        width: 70,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'YYYY',
            labelStyle: new TextStyle(color: Theme.of(context).disabledColor),
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

  Widget _buildCvcField(BuildContext context) {
    return Container(
        width: 113,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'CVC',
            labelStyle: new TextStyle(color: Theme.of(context).disabledColor),
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

  Widget _buildDivider(double targetWidth, bool isFullWidth, BuildContext context) {
    return SizedBox(
      width: targetWidth,
      height: 20.0,
      child: Center(
        child: Container(
          margin: isFullWidth ? EdgeInsets.all(0) : EdgeInsets.only(left: 80),
          height: 1,
          color: Theme.of(context).dividerColor,
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
        _buildCCNumberField(context),
        _buildDivider(targetWidth, true, context),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(child: _buildCvcField(context),),
            SizedBox(height: 10.0),
            Row(children: <Widget>[_buildExpMonthField(context),_buildExpYearField(context),],),
            SizedBox(height: 10.0),
          ],
        ),
      ],
    );
  }
}
