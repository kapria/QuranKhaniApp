import 'package:flutter/foundation.dart';

class AppConfig {
  static const String apiBaseUrl = kDebugMode
      ? 'http://localhost:3000/api'
      : 'https://your-backend-url.com/api';
}
