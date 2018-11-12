import 'dart:math';

double toPrice(double index) {
  double price = 0.0;
  double i = 0;
  while(i < index) {
    if(i < 20) {
      price += 0.25;
    } else {
      price += 1.00;
    }
    i += 1.0;
  }
  return price;
}

double decimalPrecision({int decimalPlaces = 2, double number}) {
  int fac = pow(10, decimalPlaces);
  double rounded = (number * fac).round() / fac;
  return rounded;
}