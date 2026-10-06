import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class VNPayService {
  static const String apiUrl = "http://192.168.1.84:8000/api/vnpay/payment-url";

  static Future<void> openPayment(double amount, String orderInfo) async {
    try {
      final uri = Uri.parse('$apiUrl?amount=$amount');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final paymentUrl = data['payment_url'];
          final paymentUri = Uri.parse(paymentUrl);
          
          try {
            bool launched = await launchUrl(paymentUri, mode: LaunchMode.externalApplication);
            if (!launched) {
              // Thử mở bằng inAppWebView nếu external thất bại
              launched = await launchUrl(paymentUri, mode: LaunchMode.inAppBrowserView);
              if (!launched) {
                throw 'Trình duyệt từ chối mở URL này';
              }
            }
          } catch (e) {
            throw 'Lỗi khi gọi launchUrl: $e';
          }
        } else {
          throw 'Lỗi từ server: ${data['message']}';
        }
      } else {
        throw 'Lỗi kết nối server: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Đã xảy ra lỗi: $e';
    }
  }
}
