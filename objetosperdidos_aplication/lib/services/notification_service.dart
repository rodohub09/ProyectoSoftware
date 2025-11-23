import 'dart:async';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  Stream<String> get stream => _controller.stream;

  void notify(String message) {
    try {
      _controller.add(message);
    } catch (_) {}
  }

  void dispose() {
    _controller.close();
  }
}
