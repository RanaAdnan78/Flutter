// lib/config/api_config.dart

class ApiConfig {
  static const String baseUrl = 'http://10.76.26.157/velox';
  static const String apiUrl  = '$baseUrl/api/api.php';
  static const String imgUrl  = '$baseUrl/uploads/products/';
}

class AppColors {
  static const int primary   = 0xFF1a1a2e;
  static const int accent    = 0xFFe94560;
  static const int gold      = 0xFFf5a623;
  static const int surface   = 0xFF16213e;
  static const int textLight = 0xFFf0f0f0;
  static const int textMuted = 0xFF888899;
  static const int success   = 0xFF27ae60;
  static const int error     = 0xFFe74c3c;
}

class AppStrings {
  static const appName  = 'VELOX';
  static const tagline  = 'Walk the Future';
  static const currency = 'Rs.';
  static const freeShip = 5000.0;
  static const shipping = 200.0;
}
