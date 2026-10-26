class ApiConstants {
  // Tùy chọn 1: Dùng qua cáp USB với ADB reverse (Đã kích hoạt: adb reverse tcp:8080 tcp:8080)
  static const String serverHost = '127.0.0.1:8080';

  // Tùy chọn 2: Dùng qua mạng Wi-Fi cùng lớp mạng với PC (IP máy tính: 192.168.1.184)
  // static const String serverHost = '192.168.1.184:8080';

  static const String baseUrl = 'http://$serverHost/api';
  static const String vnpayPaymentUrl = '$baseUrl/vnpay/payment-url';
}
