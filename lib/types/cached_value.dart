class CachedValue<T> {
  T _val;
  T Function() _generate;

  T get val {
    _val ??= _generate();
    return _val;
  }

  void invalidate() => _val = null;

  CachedValue(this._generate);
}
