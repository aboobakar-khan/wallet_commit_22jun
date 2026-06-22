/// A single source of "now" so the lock rule and the ambient sky agree, and so
/// time can be controlled in tests/dev without touching widgets.
abstract interface class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();
  @override
  DateTime now() => DateTime.now();
}
