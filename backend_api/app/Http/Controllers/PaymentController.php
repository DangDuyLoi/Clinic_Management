<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http; // Dùng để gọi API của MoMo

class PaymentController extends Controller
{
    /* =========================================================
       PHẦN 1: TÍCH HỢP VNPAY
       ========================================================= */
    public function taoLinkVNPay(Request $request, $id)
    {
        $hoaDon = DB::table('hoa_don')->where('ma_hoa_don', $id)->first();
        if (!$hoaDon) return response()->json(['message' => 'Không tìm thấy hóa đơn'], 404);
        if ($hoaDon->trang_thai === 'DaThanhToan') return response()->json(['message' => 'Hóa đơn này đã được thanh toán'], 400);

        $vnp_TmnCode = env('VNPAY_TMN_CODE');
        $vnp_HashSecret = env('VNPAY_HASH_SECRET');
        $vnp_Url = env('VNPAY_URL');
        $vnp_Returnurl = env('VNPAY_RETURN_URL');

        $vnp_TxnRef = $hoaDon->ma_hoa_don . '_' . time(); 
        $vnp_OrderInfo = "Thanh toan hoa don y te ma " . $hoaDon->ma_hoa_don;
        $vnp_Amount = $hoaDon->tong_cong * 100;

        $inputData = array(
            "vnp_Version" => "2.1.0",
            "vnp_TmnCode" => $vnp_TmnCode,
            "vnp_Amount" => $vnp_Amount,
            "vnp_Command" => "pay",
            "vnp_CreateDate" => date('YmdHis'),
            "vnp_CurrCode" => "VND",
            "vnp_IpAddr" => $request->ip(),
            "vnp_Locale" => 'vn',
            "vnp_OrderInfo" => $vnp_OrderInfo,
            "vnp_OrderType" => 'billpayment',
            "vnp_ReturnUrl" => $vnp_Returnurl,
            "vnp_TxnRef" => $vnp_TxnRef,
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
            $vnpSecureHash = hash_hmac('sha512', $hashdata, $vnp_HashSecret);
            $vnp_Url .= 'vnp_SecureHash=' . $vnpSecureHash;
        }

        return response()->json(['message' => 'Tạo link VNPay thành công', 'payment_url' => $vnp_Url], 200);
    }

    public function vnpayReturn(Request $request)
    {
        $vnp_HashSecret = env('VNPAY_HASH_SECRET');
        $inputData = array();
        
        foreach ($request->all() as $key => $value) {
            if (substr($key, 0, 4) == "vnp_") $inputData[$key] = $value;
        }
        
        $vnp_SecureHash = $inputData['vnp_SecureHash'];
        unset($inputData['vnp_SecureHash']);
        unset($inputData['vnp_SecureHashType']);
        ksort($inputData);
        
        $i = 0; $hashData = "";
        foreach ($inputData as $key => $value) {
            if ($i == 1) {
                $hashData = $hashData . '&' . urlencode($key) . "=" . urlencode($value);
            } else {
                $hashData = $hashData . urlencode($key) . "=" . urlencode($value);
                $i = 1;
            }
        }

        $secureHash = hash_hmac('sha512', $hashData, $vnp_HashSecret);
        
        if ($secureHash == $vnp_SecureHash) {
            if ($request->vnp_ResponseCode == '00') {
                $maHoaDon = explode('_', $request->vnp_TxnRef)[0];
                DB::table('hoa_don')->where('ma_hoa_don', $maHoaDon)->update(['trang_thai' => 'DaThanhToan', 'updated_at' => now()]);
                return response()->json(['message' => 'Xác nhận thanh toán VNPay thành công', 'RspCode' => '00'], 200);
            }
            return response()->json(['message' => 'Giao dịch bị lỗi', 'RspCode' => $request->vnp_ResponseCode], 400);
        }
        return response()->json(['message' => 'Chữ ký không hợp lệ', 'RspCode' => '97'], 400);
    }

    /* =========================================================
       PHẦN 2: TÍCH HỢP MOMO
       ========================================================= */
    public function taoLinkMoMo(Request $request, $id)
    {
        $hoaDon = DB::table('hoa_don')->where('ma_hoa_don', $id)->first();
        if (!$hoaDon) return response()->json(['message' => 'Không tìm thấy hóa đơn'], 404);
        if ($hoaDon->trang_thai === 'DaThanhToan') return response()->json(['message' => 'Hóa đơn này đã được thanh toán'], 400);

        $endpoint = env('MOMO_ENDPOINT');
        $partnerCode = env('MOMO_PARTNER_CODE');
        $accessKey = env('MOMO_ACCESS_KEY');
        $secretKey = env('MOMO_SECRET_KEY');
        
        $orderInfo = "Thanh toan hoa don y te ma " . $hoaDon->ma_hoa_don;
        $amount = (string) $hoaDon->tong_cong;
        $orderId = $hoaDon->ma_hoa_don . '_' . time();
        $redirectUrl = env('MOMO_RETURN_URL');
        $ipnUrl = env('MOMO_NOTIFY_URL');
        $extraData = "";
        $requestId = time() . "";
        $requestType = "captureWallet"; 

        $rawHash = "accessKey=" . $accessKey . "&amount=" . $amount . "&extraData=" . $extraData . "&ipnUrl=" . $ipnUrl . "&orderId=" . $orderId . "&orderInfo=" . $orderInfo . "&partnerCode=" . $partnerCode . "&redirectUrl=" . $redirectUrl . "&requestId=" . $requestId . "&requestType=" . $requestType;
        $signature = hash_hmac("sha256", $rawHash, $secretKey);

        $data = array(
            'partnerCode' => $partnerCode,
            'partnerName' => "Phong Kham Tai Phu",
            "storeId" => "MomoTestStore",
            'requestId' => $requestId,
            'amount' => $amount,
            'orderId' => $orderId,
            'orderInfo' => $orderInfo,
            'redirectUrl' => $redirectUrl,
            'ipnUrl' => $ipnUrl,
            'lang' => 'vi',
            'extraData' => $extraData,
            'requestType' => $requestType,
            'signature' => $signature
        );

        $response = Http::post($endpoint, $data);
        $jsonResult = $response->json();

        if (isset($jsonResult['payUrl'])) {
            return response()->json([
                'message' => 'Tạo link MoMo thành công',
                'payment_url' => $jsonResult['payUrl']
            ], 200);
        }

        return response()->json(['message' => 'Lỗi kết nối MoMo', 'error' => $jsonResult], 400);
    }

    public function momoNotify(Request $request)
    {
        $secretKey = env('MOMO_SECRET_KEY');
        
        $partnerCode = $request->partnerCode;
        $orderId = $request->orderId;
        $requestId = $request->requestId;
        $amount = $request->amount;
        $orderInfo = $request->orderInfo;
        $orderType = $request->orderType;
        $transId = $request->transId;
        $resultCode = $request->resultCode;
        $message = $request->message;
        $payType = $request->payType;
        $responseTime = $request->responseTime;
        $extraData = $request->extraData;
        $signature = $request->signature;

        $rawHash = "accessKey=" . env('MOMO_ACCESS_KEY') . "&amount=" . $amount . "&extraData=" . $extraData . "&message=" . $message . "&orderId=" . $orderId . "&orderInfo=" . $orderInfo . "&orderType=" . $orderType . "&partnerCode=" . $partnerCode . "&payType=" . $payType . "&requestId=" . $requestId . "&responseTime=" . $responseTime . "&resultCode=" . $resultCode . "&transId=" . $transId;
        $checkSignature = hash_hmac("sha256", $rawHash, $secretKey);

        if ($signature == $checkSignature) {
            if ($resultCode == 0) { 
                $maHoaDon = explode('_', $orderId)[0];
                
                DB::table('hoa_don')->where('ma_hoa_don', $maHoaDon)->update([
                    'trang_thai' => 'DaThanhToan',
                    'updated_at' => now()
                ]);

                return response()->json(['message' => 'Thành công'], 204); 
            }
        }
        return response()->json(['message' => 'Thất bại hoặc chữ ký sai'], 400);
    }
}
