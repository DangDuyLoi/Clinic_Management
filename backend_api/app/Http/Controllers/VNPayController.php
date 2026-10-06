<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class VNPayController extends Controller
{
    public function createPaymentUrl(Request $request)
    {
        date_default_timezone_set('Asia/Ho_Chi_Minh');
        $vnp_TmnCode = "EMECLOTV"; // Thay bằng mã của bạn
        $vnp_HashSecret = "DDRHKNYLVCLJGUWGLYOBANHQMQZDJZQI"; // Thay bằng mã của bạn
        $vnp_Url = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
        $vnp_Returnurl = "http://localhost:8080/";
        
        $vnp_TxnRef = date('YmdHis'); // Mã đơn hàng
        $vnp_OrderInfo = "ThanhToan";
        $vnp_OrderType = "other";
        $vnp_Amount = $request->input('amount', 150000) * 100;
        $vnp_Locale = "vn";
        $vnp_IpAddr = $request->ip();

        $inputData = array(
            "vnp_Version" => "2.1.0",
            "vnp_TmnCode" => $vnp_TmnCode,
            "vnp_Amount" => $vnp_Amount,
            "vnp_Command" => "pay",
            "vnp_CreateDate" => date('YmdHis'),
            "vnp_CurrCode" => "VND",
            "vnp_IpAddr" => $vnp_IpAddr,
            "vnp_Locale" => $vnp_Locale,
            "vnp_OrderInfo" => $vnp_OrderInfo,
            "vnp_OrderType" => $vnp_OrderType,
            "vnp_ReturnUrl" => $vnp_Returnurl,
            "vnp_TxnRef" => $vnp_TxnRef,
            "vnp_ExpireDate"=> date('YmdHis', strtotime('+15 minutes'))
        );

        ksort($inputData);
        $query = "";
        $i = 0;
        $hashdata = "";
        foreach ($inputData as $key => $value) {
            if ($i == 1) {
                $hashdata .= '&' . urlencode($key) . "=" . urlencode($value);
            } else {
                $hashdata .= urlencode($key) . "=" . urlencode($value);
                $i = 1;
            }
            $query .= urlencode($key) . "=" . urlencode($value) . '&';
        }

        $vnp_Url = $vnp_Url . "?" . $query;
        if (isset($vnp_HashSecret)) {
            $vnpSecureHash =   hash_hmac('sha512', $hashdata, $vnp_HashSecret);
            $vnp_Url .= 'vnp_SecureHash=' . $vnpSecureHash;
        }

        return response()->json([
            'status' => 'success',
            'payment_url' => $vnp_Url
        ]);
    }
}
