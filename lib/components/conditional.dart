import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
Widget Conditional({@required Widget child, @required bool condition, Widget falseWidget}) =>
    condition ? child : falseWidget;
