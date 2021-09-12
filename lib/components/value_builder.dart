import 'package:flutter/material.dart';

typedef _ValueBuilder<T> = Widget Function(BuildContext context, T Function(T value), T value);

class ValueBuilder<T> extends StatefulWidget {
  final T initialValue;
  final _ValueBuilder<T> builder;

  const ValueBuilder({
    Key key,
    this.builder,
    this.initialValue,
  }) : super(key: key);

  @override
  _ValueBuilderState createState() => _ValueBuilderState<T>();
}

class _ValueBuilderState<T> extends State<ValueBuilder<T>> {
  T _value;

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _setValue, _value);
  }

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant ValueBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _value = widget.initialValue;
    }
  }

  T _setValue(T value) {
    if (_value != value) {
      setState(() {
        _value = value;
      });
    }
    return value;
  }
}
