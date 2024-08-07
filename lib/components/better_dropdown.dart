import 'dart:math' as math;

import 'package:flutter/material.dart';

const Duration _kDropdownMenuDuration = Duration(milliseconds: 200);
const double _kMenuItemHeight = 36.0;
const double _kDenseButtonHeight = 24.0;
const EdgeInsets _kMenuItemPadding = EdgeInsets.symmetric(horizontal: 16.0);
const EdgeInsetsGeometry _kAlignedButtonPadding = EdgeInsetsDirectional.only(start: 16.0, end: 4.0);
const EdgeInsets _kUnalignedButtonPadding = EdgeInsets.zero;
const EdgeInsets _kAlignedMenuMargin = EdgeInsets.zero;
const EdgeInsetsGeometry _kUnalignedMenuMargin = EdgeInsetsDirectional.only(start: 16.0, end: 24.0);

class _DropdownMenuPainter extends CustomPainter {
  _DropdownMenuPainter({
    this.color,
    this.elevation,
    this.selectedIndex,
    this.resize,
  })  : _painter = new BoxDecoration(
                // If you add an image here, you must provide a real
                // configuration in the paint() function and you must provide some sort
                // of onChanged callback here.
                color: color,
                borderRadius: new BorderRadius.circular(2.0),
                boxShadow: kElevationToShadow[elevation!])
            .createBoxPainter(),
        super(repaint: resize);

  final Color? color;
  final int? elevation;
  final int? selectedIndex;
  final Animation<double>? resize;

  final BoxPainter _painter;

  @override
  void paint(Canvas canvas, Size size) {
    final double selectedItemOffset = selectedIndex! * _kMenuItemHeight + kMaterialListPadding.top;
    final Tween<double> top = new Tween<double>(
      begin: selectedItemOffset.clamp(0.0, size.height - _kMenuItemHeight),
      end: 0.0,
    );

    final Tween<double> bottom = new Tween<double>(
      begin: (top.begin! + _kMenuItemHeight).clamp(_kMenuItemHeight, size.height),
      end: size.height,
    );

    final Rect rect = new Rect.fromLTRB(0.0, top.evaluate(resize!), size.width, bottom.evaluate(resize!));

    _painter.paint(canvas, rect.topLeft, new ImageConfiguration(size: rect.size));
  }

  @override
  bool shouldRepaint(_DropdownMenuPainter oldPainter) {
    return oldPainter.color != color ||
        oldPainter.elevation != elevation ||
        oldPainter.selectedIndex != selectedIndex ||
        oldPainter.resize != resize;
  }
}

// Do not use the platform-specific default scroll configuration.
// Dropdown menus should never overscroll or display an overscroll indicator.
class _DropdownScrollBehavior extends ScrollBehavior {
  const _DropdownScrollBehavior();

  @override
  TargetPlatform getPlatform(BuildContext context) => Theme.of(context).platform;

  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) => child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const ClampingScrollPhysics();
}

class _DropdownMenu<T> extends StatefulWidget {
  const _DropdownMenu({
    Key? key,
    this.padding,
    this.route,
    this.color,
  }) : super(key: key);

  final _DropdownRoute<T>? route;
  final EdgeInsets? padding;
  final Color? color;

  @override
  _DropdownMenuState<T> createState() => new _DropdownMenuState<T>();
}

class _DropdownMenuState<T> extends State<_DropdownMenu<T>> {
  late CurvedAnimation _fadeOpacity;
  CurvedAnimation? _resize;

  @override
  void initState() {
    super.initState();
    // We need to hold these animations as state because of their curve
    // direction. When the route's animation reverses, if we were to recreate
    // the CurvedAnimation objects in build, we'd lose
    // CurvedAnimation._curveDirection.
    _fadeOpacity = new CurvedAnimation(
      parent: widget.route!.animation!,
      curve: const Interval(0.0, 1),
    );
    _resize = new CurvedAnimation(
      parent: widget.route!.animation!,
      curve: const Interval(0.25, 0.5),
      reverseCurve: const Threshold(0.0),
    );
    widget.route!.updateItems = () => WidgetsBinding.instance!.addPostFrameCallback((timeStamp) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    // The menu is shown in three stages (unit timing in brackets):
    // [0s - 0.25s] - Fade in a rect-sized menu container with the selected item.
    // [0.25s - 0.5s] - Grow the otherwise empty menu container from the center
    //   until it's big enough for as many items as we're going to show.
    // [0.5s - 1.0s] Fade in the remaining visible items from top to bottom.
    //
    // When the menu is dismissed we just fade the entire thing out
    // in the first 0.25s.
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final _DropdownRoute<T> route = widget.route!;
    final double unit = 0.5 / (route.items!.length + 1.5);
    final List<Widget> children = <Widget>[];
    for (int itemIndex = 0; itemIndex < route.items!.length; ++itemIndex) {
      CurvedAnimation opacity;
      if (itemIndex == route.selectedIndex) {
        opacity = new CurvedAnimation(parent: route.animation!, curve: const Threshold(0.0));
      } else {
        final double start = (0.5 + (itemIndex + 1) * unit).clamp(0.0, 1.0);
        final double end = (start + 1.5 * unit).clamp(0.0, 1.0);
        opacity = new CurvedAnimation(parent: route.animation!, curve: new Interval(start, end));
      }
      children.add(Material(
        color: widget.color,
        child: route.items![itemIndex],
      ));
    }

    return new FadeTransition(
      opacity: _fadeOpacity,
      child: new Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: localizations.popupMenuLabel,
        child: new Material(
          type: MaterialType.transparency,
          textStyle: route.style,
          child: new ScrollConfiguration(
            behavior: const _DropdownScrollBehavior(),
            child: new Scrollbar(
              child: new MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                removeLeft: true,
                removeRight: true,
                child: Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(color: Colors.black38, offset: Offset(1, 1), blurRadius: 5, spreadRadius: 1)
                  ]),
                  child: new ListView(
                    controller: widget.route!.scrollController,
                    padding: EdgeInsets.zero,
                    itemExtent: _kMenuItemHeight,
                    shrinkWrap: true,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownMenuRouteLayout<T> extends SingleChildLayoutDelegate {
  _DropdownMenuRouteLayout({
    required this.buttonRect,
    required this.menuTop,
    required this.menuHeight,
    required this.textDirection,
    this.width,
    this.offset,
  });

  final Rect? buttonRect;
  final double menuTop;
  final double menuHeight;
  final TextDirection textDirection;
  final double? width;
  final Offset? offset;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The maximum height of a simple menu should be one or more rows less than
    // the view height. This ensures a tappable area outside of the simple menu
    // with which to dismiss the menu.
    //   -- https://material.google.com/components/menus.html#menus-simple-menus
    final double maxHeight = math.max(0.0, constraints.maxHeight - 2 * _kMenuItemHeight);
    // The width of a menu should be at most the view width. This ensures that
    // the menu does not extend past the left and right edges of the screen.
    return new BoxConstraints(
      minWidth: width!,
      maxWidth: width!,
      minHeight: 0.0,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    assert(() {
      final Rect container = Offset.zero & size;
      if (container.intersect(buttonRect!) == buttonRect) {
        // If the button was entirely on-screen, then verify
        // that the menu is also on-screen.
        // If the button was a bit off-screen, then, oh well.
        assert(menuTop >= 0.0);
        assert(menuTop + menuHeight <= size.height);
      }
      return true;
    }());
    assert(textDirection != null);
    late double left;
    switch (textDirection) {
      case TextDirection.rtl:
        left = buttonRect!.right.clamp(0.0, size.width) - childSize.width;
        break;
      case TextDirection.ltr:
        left = buttonRect!.left.clamp(0.0, size.width - childSize.width);
        break;
    }
    return new Offset(left + offset!.dx, menuTop + offset!.dy);
  }

  @override
  bool shouldRelayout(_DropdownMenuRouteLayout<T> oldDelegate) {
    return buttonRect != oldDelegate.buttonRect ||
        menuTop != oldDelegate.menuTop ||
        menuHeight != oldDelegate.menuHeight ||
        textDirection != oldDelegate.textDirection;
  }
}

class _DropdownRouteResult<T> {
  const _DropdownRouteResult(this.result);

  final T result;

  @override
  bool operator ==(dynamic other) {
    if (other is! _DropdownRouteResult<T>) return false;
    final _DropdownRouteResult<T> typedOther = other;
    return result == typedOther.result;
  }

  @override
  int get hashCode => result.hashCode;
}

class _DropdownRoute<T> extends PopupRoute<_DropdownRouteResult<T>> {
  _DropdownRoute({
    this.items,
    this.padding,
    this.buttonRect,
    this.selectedIndex,
    this.elevation = 8,
    this.width,
    this.offset,
    this.theme,
    this.backgroundColor,
    this.dialogBarrierColor,
    this.dialogBarrierDismissible,
    required this.style,
    this.barrierLabel,
  }) : assert(style != null);

  List<BetterDropdownMenuItem<T>>? items;
  final EdgeInsetsGeometry? padding;
  final Rect? buttonRect;
  final int? selectedIndex;
  final int elevation;
  final ThemeData? theme;
  final TextStyle style;
  final double? width;
  final Offset? offset;
  final Color? backgroundColor;
  final Color? dialogBarrierColor;
  final bool? dialogBarrierDismissible;

  ScrollController? scrollController;

  @override
  Duration get transitionDuration => _kDropdownMenuDuration;

  @override
  bool get barrierDismissible => dialogBarrierDismissible!;

  @override
  Color? get barrierColor => dialogBarrierColor;

  @override
  final String? barrierLabel;

  void setItems(List<BetterDropdownMenuItem<T>> newItems) {
    items = newItems;
    updateItems();
  }

  late VoidCallback updateItems;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    assert(debugCheckHasDirectionality(context));
    final double screenHeight = MediaQuery.of(context).size.height;
    final double maxMenuHeight = screenHeight - 2.0 * _kMenuItemHeight;
    final double preferredMenuHeight = (items!.length * _kMenuItemHeight) + kMaterialListPadding.vertical;
    final double menuHeight = math.min(maxMenuHeight, preferredMenuHeight);

    final double buttonTop = buttonRect!.top;
    final double selectedItemOffset = selectedIndex! * _kMenuItemHeight + kMaterialListPadding.top;
    double menuTop = (buttonTop - selectedItemOffset) - (_kMenuItemHeight - buttonRect!.height) / 2.0;
    const double topPreferredLimit = _kMenuItemHeight;
    if (menuTop < topPreferredLimit) menuTop = math.min(buttonTop, topPreferredLimit);
    double bottom = menuTop + menuHeight;
    final double bottomPreferredLimit = screenHeight - _kMenuItemHeight;
    if (bottom > bottomPreferredLimit) {
      bottom = math.max(buttonTop + _kMenuItemHeight, bottomPreferredLimit);
      menuTop = bottom - menuHeight;
    }

    if (scrollController == null) {
      double scrollOffset = 0.0;
      if (preferredMenuHeight > maxMenuHeight) scrollOffset = selectedItemOffset - (buttonTop - menuTop);
      scrollController = new ScrollController(initialScrollOffset: scrollOffset);
    }

    final TextDirection textDirection = Directionality.of(context);
    Widget menu = new _DropdownMenu<T>(route: this, padding: padding!.resolve(textDirection), color: backgroundColor);

    if (theme != null) menu = new Theme(data: theme!, child: menu);

    return new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: new Builder(
        builder: (BuildContext context) {
          return new CustomSingleChildLayout(
            delegate: new _DropdownMenuRouteLayout<T>(
                buttonRect: buttonRect,
                menuTop: menuTop,
                menuHeight: menuHeight,
                textDirection: textDirection,
                width: width,
                offset: offset),
            child: menu,
          );
        },
      ),
    );
  }

  void _dismiss() {
    navigator?.removeRoute(this);
  }
}

class BetterDropdownButton<T> extends StatefulWidget {
  /// Creates a dropdown button.
  ///
  /// The [items] must have distinct values and if [value] isn't null it must be among them.
  ///
  /// The [elevation] and [iconSize] arguments must not be null (they both have
  /// defaults, so do not need to be specified).
  BetterDropdownButton({
    Key? key,
    required this.items,
    this.value,
    this.hint,
    this.elevation = 8,
    this.style,
    this.width = 300,
    this.offset = const Offset(0, 0),
    this.backgroundColor,
    this.barrierColor,
    this.barrierDismissible = true,
    this.buttonColor,
    this.iconSize = 24.0,
    this.isDense = false,
    this.childAlignment = Alignment.center,
    this.child,
    this.openChild,
  })  : assert(items != null),
        assert(value == null || items.where((BetterDropdownMenuItem<T> item) => item.value == value).length == 1),
        super(key: key);

  /// The list of possible items to select among.
  final List<BetterDropdownMenuItem<T>> items;

  final Widget? child;
  final Widget? openChild;

  /// The currently selected item, or null if no item has been selected. If
  /// value is null then the menu is popped up as if the first item was
  /// selected.
  final T? value;

  /// Displayed if [value] is null.
  final Widget? hint;

  final double width;

  final Offset offset;
  final Color? backgroundColor;
  final Color? barrierColor;
  final bool barrierDismissible;
  final Color? buttonColor;

  /// The z-coordinate at which to place the menu when open.
  ///
  /// The following elevations have defined shadows: 1, 2, 3, 4, 6, 8, 9, 12, 16, 24
  ///
  /// Defaults to 8, the appropriate elevation for dropdown buttons.
  final int elevation;

  /// The text style to use for text in the dropdown button and the dropdown
  /// menu that appears when you tap the button.
  ///
  /// Defaults to the [TextTheme.subhead] value of the current
  /// [ThemeData.textTheme] of the current [Theme].
  final TextStyle? style;

  /// The size to use for the drop-down button's down arrow icon button.
  ///
  /// Defaults to 24.0.
  final double iconSize;

  /// Reduce the button's height.
  ///
  /// By default this button's height is the same as its menu items' heights.
  /// If isDense is true, the button's height is reduced by about half. This
  /// can be useful when the button is embedded in a container that adds
  /// its own decorations, like [InputDecorator].
  final bool isDense;
  final Alignment childAlignment;

  @override
  _DropdownButtonState<T> createState() => new _DropdownButtonState<T>();
}

class _DropdownButtonState<T> extends State<BetterDropdownButton<T>> with WidgetsBindingObserver {
  int? _selectedIndex;
  _DropdownRoute<T>? _dropdownRoute;

  @override
  void initState() {
    super.initState();
//    _updateSelectedIndex();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _removeDropdownRoute();
    super.dispose();
  }

  // Typically called because the device's orientation has changed.
  // Defined by WidgetsBindingObserver
  @override
  void didChangeMetrics() {
    _removeDropdownRoute();
  }

  void _removeDropdownRoute() {
    _dropdownRoute?._dismiss();
    _dropdownRoute = null;
  }

  @override
  void didUpdateWidget(BetterDropdownButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectedIndex();
    _dropdownRoute?.setItems(widget.items);
  }

  void _updateSelectedIndex() {
    assert(widget.value == null ||
        widget.items.where((BetterDropdownMenuItem<T> item) => item.value == widget.value).length == 1);
    _selectedIndex = null;
    for (int itemIndex = 0; itemIndex < widget.items.length; itemIndex++) {
      if (widget.items[itemIndex].value == widget.value) {
        _selectedIndex = itemIndex;
        return;
      }
    }
  }

  TextStyle? get _textStyle => widget.style ?? Theme.of(context).textTheme.titleMedium;

  void _handleTap() {
    final RenderBox itemBox = context.findRenderObject() as RenderBox;
    final Rect itemRect = itemBox.localToGlobal(Offset.zero) & itemBox.size;
    final TextDirection textDirection = Directionality.of(context);
    final EdgeInsetsGeometry menuMargin =
        ButtonTheme.of(context).alignedDropdown ? _kAlignedMenuMargin : _kUnalignedMenuMargin;

    assert(_dropdownRoute == null);
    setState(() {
      _dropdownRoute = new _DropdownRoute<T>(
          items: widget.items,
          width: widget.width,
          offset: widget.offset,
          backgroundColor: widget.backgroundColor,
          buttonRect: menuMargin.resolve(textDirection).inflateRect(itemRect),
          padding: _kMenuItemPadding.resolve(textDirection),
          selectedIndex: -1,
          elevation: widget.elevation,
          theme: Theme.of(context),
          style: _textStyle!,
          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
          dialogBarrierColor: widget.barrierColor,
          dialogBarrierDismissible: widget.barrierDismissible);
    });

    Navigator.push(context, _dropdownRoute!).then<void>((_DropdownRouteResult<T>? newValue) {
      setState(() {
        _dropdownRoute = null;
      });
      if (!mounted || newValue == null) return;
    });
  }

  // When isDense is true, reduce the height of this button from _kMenuItemHeight to
  // _kDenseButtonHeight, but don't make it smaller than the text that it contains.
  // Similarly, we don't reduce the height of the button so much that its icon
  // would be clipped.
  double get _denseButtonHeight {
    return math.max(_textStyle!.fontSize!, math.max(widget.iconSize, _kDenseButtonHeight));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));

    // The width of the button and the menu are defined by the widest
    // item and the width of the hint.
    final List<Widget> items = new List<Widget>.from(widget.items);
    int hintIndex;
    if (widget.hint != null) {
      hintIndex = items.length;
      items.add(new DefaultTextStyle(
        style: _textStyle!.copyWith(color: Theme.of(context).hintColor),
        child: new IgnorePointer(
          child: widget.hint,
          ignoringSemantics: false,
        ),
      ));
    }

    final EdgeInsetsGeometry padding =
        ButtonTheme.of(context).alignedDropdown ? _kAlignedButtonPadding : _kUnalignedButtonPadding;

    Widget result = new DefaultTextStyle(
      style: _textStyle!,
      child: Container(
        alignment: widget.childAlignment,
        child: _dropdownRoute == null ? widget.child : widget.openChild ?? widget.child,
      ),
    );

    return new Semantics(
      button: true,
      child: Material(
        color: widget.buttonColor,
        child: new InkWell(
          onTap: _handleTap,
          child: result,
        ),
      ),
    );
  }
}

class BetterDropdownMenuItem<T> extends StatelessWidget {
  final Widget child;
  final T? value;

  const BetterDropdownMenuItem({Key? key, required this.child, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
