import 'package:flutter/material.dart';

typedef LoadingOverlayBuilder<T> = Widget Function(BuildContext context, T Function(Future<T> action));

class LoadingOverlay extends StatefulWidget {
  static Duration defaultDuration = Duration(milliseconds: 300);
  static Widget defaultPlaceholder;
  final LoadingOverlayBuilder builder;
  final Duration fadeDuration;
  final Widget placeholder;
  final Function(Exception) onError;

  const LoadingOverlay({Key key, this.builder, this.placeholder, this.fadeDuration = Duration.zero, this.onError})
      : super(key: key);

  @override
  _LoadingOverlayState createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  bool showLoading = false;

  @override
  Widget build(BuildContext context) {
    final placeholder = widget.placeholder ?? LoadingOverlay.defaultPlaceholder ?? Offstage();
    return Stack(
      children: [
        widget.builder(context, _doAction),
        Positioned.fill(
          child: AnimatedOpacity(
            duration: widget.fadeDuration ?? Duration(milliseconds: 100),
            opacity: showLoading ? 1 : 0,
            child: placeholder,
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Future _doAction(Future action) async {
    setState(() {
      showLoading = true;
    });

    var result;
    try {
      result = await action;
    } catch (e) {
      setState(() {
        showLoading = false;
      });

      if (widget.onError != null)
        widget.onError(e);
      else {
        throw (e);
      }
    }

    setState(() {
      showLoading = false;
    });

    return result;
  }
}
