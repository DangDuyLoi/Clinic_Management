class ApiConstants {
  // Máy chủ phát triển hoặc cloud
  // static const String serverHost = '192.168.1.143:8000';
  // static const String baseUrl = 'http://$serverHost/api';

  // Máy chủ Backend Local (Port 8080)
  static const String serverHost = '127.0.0.1:8080';
  static const String baseUrl = 'http://$serverHost/api';
  static const String vnpayPaymentUrl = '$baseUrl/vnpay/payment-url';
}

