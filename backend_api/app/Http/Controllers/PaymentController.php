<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PaymentController extends Controller
{
    // 1. API Tạo URL thanh toán VNPay
    public function taoLinkVNPay(Request $request, $id)
    {
        // Tìm hóa đơn trong Database dựa vào mã hóa đơn ($id)
        $hoaDon = DB::table('hoa_don')->where('ma_hoa_don', $id)->first();
        
        if (!$hoaDon) {
            return response()->json(['message' => 'Không tìm thấy hóa đơn'], 404);
        }

        if ($hoaDon->trang_thai === 'DaThanhToan') {
            return response()->json(['message' => 'Hóa đơn này đã được thanh toán'], 400);
        }

        // Lấy cấu hình từ file .env
        $vnp_TmnCode = env('VNPAY_TMN_CODE');
        $vnp_HashSecret = env('VNPAY_HASH_SECRET');
        $vnp_Url = env('VNPAY_URL');
        $vnp_Returnurl = env('VNPAY_RETURN_URL');

        // Tạo mã giao dịch (Thêm time() để đảm bảo mã là duy nhất khi test nhiều lần)
        $vnp_TxnRef = $hoaDon->ma_hoa_don . '_' . time(); 
        $vnp_OrderInfo = "Thanh toan hoa don y te ma " . $hoaDon->ma_hoa_don;
        $vnp_OrderType = 'billpayment';
        $vnp_Amount = $hoaDon->tong_cong * 100; // VNPay yêu cầu số tiền nhân với 100
        $vnp_Locale = 'vn';
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
        );

        // Sắp xếp dữ liệu theo thứ tự a-z trước khi tạo chữ ký bảo mật
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
            $vnpSecureHash = hash_hmac('sha512', $hashdata, $vnp_HashSecret);
            $vnp_Url .= 'vnp_SecureHash=' . $vnpSecureHash;
        }

        // Trả về link để Frontend/Mobile mở trang thanh toán
        return response()->json([
            'message' => 'Tạo link thanh toán thành công',
            'payment_url' => $vnp_Url
        ], 200);
    }
}
