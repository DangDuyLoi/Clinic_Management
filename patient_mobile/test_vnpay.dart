import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  String vnp_HashSecret = "DDRHKNYLVCLJGUWGLYOBANHQMQZDJZQI";
  Map<String, String> vnp_Params = {
    "vnp_Version": "2.1.0",
    "vnp_Command": "pay",
    "vnp_TmnCode": "EMECLOTV",
    "vnp_Amount": "15000000",
    "vnp_CreateDate": "20261006182500",
    "vnp_CurrCode": "VND",
    "vnp_IpAddr": "127.0.0.1",
    "vnp_Locale": "vn",
    "vnp_OrderInfo": "Thanh toan vien phi",
    "vnp_OrderType": "other",
    "vnp_ReturnUrl": "clinicapp://vnpay-return",
    "vnp_TxnRef": "20261006182500",
    "vnp_ExpireDate": "20261006184000"
  };

  var sortedKeys = vnp_Params.keys.toList()..sort();
  String signData = "";
  String queryString = "";
  for (var key in sortedKeys) {
    if (vnp_Params[key] != null && vnp_Params[key]!.isNotEmpty) {
      String value = vnp_Params[key]!;
      signData += "$key=$value&";
      queryString += "$key=${Uri.encodeComponent(value)}&";
    }
  }

  signData = signData.substring(0, signData.length - 1);
  queryString = queryString.substring(0, queryString.length - 1);

  var bytes = utf8.encode(vnp_HashSecret);
  var hmacSha512 = Hmac(sha512, bytes);
  var digest = hmacSha512.convert(utf8.encode(signData));
  print("Hash from signData: " + digest.toString());

  String signData2 = "";
  for (var key in sortedKeys) {
    if (vnp_Params[key] != null && vnp_Params[key]!.isNotEmpty) {
      String value = Uri.encodeComponent(vnp_Params[key]!);
      signData2 += "$key=$value&";
    }
  }
  signData2 = signData2.substring(0, signData2.length - 1);
  var digest2 = hmacSha512.convert(utf8.encode(signData2));
  print("Hash from encoded signData: " + digest2.toString());
}
