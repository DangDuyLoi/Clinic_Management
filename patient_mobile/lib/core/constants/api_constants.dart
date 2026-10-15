class ApiConstants {
  // Thay đổi IP này khi mạng LAN/WiFi của máy phát triển thay đổi
  static const String serverHost = '192.168.1.143:8000';
  static const String baseUrl = 'http://$serverHost/api';
  static const String vnpayPaymentUrl = '$baseUrl/vnpay/payment-url';
}
