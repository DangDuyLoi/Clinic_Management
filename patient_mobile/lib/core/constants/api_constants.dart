class ApiConstants {
<<<<<<< HEAD
  // Thay đổi IP này khi mạng LAN/WiFi của máy phát triển thay đổi
  static const String serverHost = '192.168.1.143:8000';
  static const String baseUrl = 'http://$serverHost/api';
=======
  // Đã chuyển lên Render cloud server
  static const String serverHost = 'clinic-management-9x6x.onrender.com';
  static const String baseUrl = 'https://$serverHost/api';
>>>>>>> 4d1818d3c7987c4484aad2730197bd5334aa58e4
  static const String vnpayPaymentUrl = '$baseUrl/vnpay/payment-url';
}
