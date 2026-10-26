import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/api_constants.dart';

class VNPayService {
  static const String apiUrl = ApiConstants.vnpayPaymentUrl;

  /// Mở giao diện thanh toán VNPay trên trình duyệt
  static Future<String> openPayment({
    required dynamic maLuotKham,
    double amount = 150000,
    String? orderInfo,
  }) async {
    try {
      final queryParams = {
        'amount': amount.toString(),
        'ma_luot_kham': maLuotKham.toString(),
      };
      if (orderInfo != null && orderInfo.isNotEmpty) {
        queryParams['order_info'] = orderInfo;
      }

      final uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final paymentUrl = data['payment_url'];
          final paymentUri = Uri.parse(paymentUrl);

          try {
            bool launched = await launchUrl(
              paymentUri,
              mode: LaunchMode.externalApplication,
            );
            if (!launched) {
              // Thử mở bằng inAppBrowserView nếu external thất bại
              launched = await launchUrl(
                paymentUri,
                mode: LaunchMode.inAppBrowserView,
              );
              if (!launched) {
                throw 'Trình duyệt từ chối mở liên kết VNPay';
              }
            }
          } catch (e) {
            throw 'Lỗi khi mở trình duyệt: $e';
          }

          return paymentUrl;
        } else {
          throw 'Lỗi từ máy chủ: ${data['message']}';
        }
      } else {
        throw 'Lỗi kết nối máy chủ (${response.statusCode})';
      }
    } catch (e) {
      throw 'Không thể khởi tạo thanh toán VNPay: $e';
    }
  }
}
