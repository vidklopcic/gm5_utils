import 'dart:async';

class EventUtils {
  Map debounceTimeouts = {};

  void debounce(int timeoutMs, Function target, {key, List arguments}) {
    key = key ?? target;
    if (debounceTimeouts.containsKey(key)) {
      debounceTimeouts[key].cancel();
    }

    Timer timer = Timer(Duration(milliseconds: timeoutMs), () {
      Function.apply(target, arguments ?? []);
    });

    debounceTimeouts[key] = timer;
  }
}
