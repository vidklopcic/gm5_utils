import 'dart:async';

class SubscriptionsMixin {
  List<StreamSubscription> _subscriptions = [];

  void listen<T>(Stream<T> stream, void Function(T) callback, {Function onError}) {
    _subscriptions.add(stream.listen(callback, onError: onError));
  }

  void cancelSubscriptions() {
    for (StreamSubscription subscription in _subscriptions) {
      subscription?.cancel();
    }
  }
}