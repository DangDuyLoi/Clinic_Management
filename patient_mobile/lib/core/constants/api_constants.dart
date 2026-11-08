class ApiConstants {
  // Tùy chọn 2: Dùng qua cáp USB với ADB reverse (khi cắm cáp USB: adb reverse tcp:8080 tcp:8080)
  static const String serverHost = '127.0.0.1:8080';

  // Tùy chọn 1: Dùng qua mạng Wi-Fi (Điện thoại và Máy tính cùng bắt chung Wi-Fi)
  // static const String serverHost = '192.168.1.7:8080';

  static const String baseUrl = 'http://$serverHost/api';
  static const String vnpayPaymentUrl = '$baseUrl/vnpay/payment-url';
}
