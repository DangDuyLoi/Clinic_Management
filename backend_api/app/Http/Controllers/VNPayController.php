<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\LuotKham;
use App\Models\User;
use App\Services\FCMService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class VNPayController extends Controller
{
    /**
     * Tạo URL thanh toán VNPay Sandbox
     */
    public function createPaymentUrl(Request $request)
    {
        date_default_timezone_set('Asia/Ho_Chi_Minh');

        $vnp_TmnCode = env('VNPAY_TMN_CODE', 'EMECLOTV');
        $vnp_HashSecret = env('VNPAY_HASH_SECRET', 'DDRHKNYLVCLJGUWGLYOBANHQMQZDJZQI');
        $vnp_Url = env('VNPAY_URL', 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html');
        
        // Return URL: ưu tiên dynamic host theo request hoặc cấu hình IP hợp lệ
        $envReturn = env('VNPAY_RETURN_URL');
        $dynamicReturn = $request->getSchemeAndHttpHost() . '/api/vnpay/return';
        
        if (!empty($envReturn) && !str_contains($envReturn, '192.168.1.58')) {
            $vnp_Returnurl = $envReturn;
        } else {
            $vnp_Returnurl = $dynamicReturn;
        }
        
        $maLuotKham = str_replace(',', '-', (string)$request->input('ma_luot_kham'));
        $amount = $request->input('amount', 150000);

        // Tạo TxnRef gắn mã lượt khám: LK_{ma_luot_kham}_{timestamp}
        $txnSuffix = date('YmdHis');
        $vnp_TxnRef = !empty($maLuotKham) ? "LK_{$maLuotKham}_{$txnSuffix}" : "LK_GEN_{$txnSuffix}";
        
        $vnp_OrderInfo = !empty($maLuotKham) ? "Thanh toan phi kham luot #{$maLuotKham}" : "Thanh toan phi kham HUIT Care";
        $vnp_OrderType = "billpayment";
        $vnp_Amount = $amount * 100;
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
            "vnp_ExpireDate" => date('YmdHis', strtotime('+15 minutes'))
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
        if (!empty($vnp_HashSecret)) {
            $vnpSecureHash = hash_hmac('sha512', $hashdata, $vnp_HashSecret);
            $vnp_Url .= 'vnp_SecureHash=' . $vnpSecureHash;
        }

        return response()->json([
            'status' => 'success',
            'payment_url' => $vnp_Url,
            'ma_luot_kham' => $maLuotKham,
            'txn_ref' => $vnp_TxnRef
        ], 200);
    }

    /**
     * Callback nhận kết quả thanh toán từ VNPay
     */
    public function vnpayReturn(Request $request)
    {
        $vnp_HashSecret = env('VNPAY_HASH_SECRET', 'DDRHKNYLVCLJGUWGLYOBANHQMQZDJZQI');
        $inputData = array();
        
        foreach ($request->all() as $key => $value) {
            if (substr($key, 0, 4) == "vnp_") {
                $inputData[$key] = $value;
            }
        }
        
        $vnp_SecureHash = $inputData['vnp_SecureHash'] ?? '';
        unset($inputData['vnp_SecureHash']);
        unset($inputData['vnp_SecureHashType']);
        ksort($inputData);
        
        $i = 0;
        $hashData = "";
        foreach ($inputData as $key => $value) {
            if ($i == 1) {
                $hashData = $hashData . '&' . urlencode($key) . "=" . urlencode($value);
            } else {
                $hashData = $hashData . urlencode($key) . "=" . urlencode($value);
                $i = 1;
            }
        }

        $secureHash = hash_hmac('sha512', $hashData, $vnp_HashSecret);
        
        $isValid = ($secureHash === $vnp_SecureHash);
        $responseCode = $request->input('vnp_ResponseCode');
        $txnRef = $request->input('vnp_TxnRef', '');
        
        // Trích xuất mã lượt khám từ LK_{ma_luot_kham}_{timestamp}
        $maLuotKhamStr = null;
        if (preg_match('/LK_([0-9-]+)_/', $txnRef, $matches)) {
            $maLuotKhamStr = $matches[1];
        } else {
            $parts = explode('_', $txnRef);
            if (count($parts) > 1) {
                $maLuotKhamStr = $parts[1];
            }
        }

        $listMaLK = [];
        if (!empty($maLuotKhamStr)) {
            $listMaLK = array_values(array_filter(explode('-', $maLuotKhamStr), fn($id) => is_numeric($id)));
        }

        $isSuccess = ($isValid && $responseCode === '00');
        $maLuotKham = !empty($listMaLK) ? implode('-', $listMaLK) : null;

        Log::info("VNPay Return: TxnRef={$txnRef}, Code={$responseCode}, Valid=" . ($isValid ? 'true' : 'false') . ", MaLK=" . json_encode($listMaLK));

        if ($isSuccess && !empty($listMaLK)) {
            foreach ($listMaLK as $idLK) {
                $luotKham = LuotKham::find($idLK);
                if ($luotKham) {
                    $luotKham->update(['trang_thai' => 'da_thanh_toan']);
                    Log::info("Đã cập nhật trạng thái da_thanh_toan cho lượt khám #{$idLK}");
                }
            }

            // Gửi thông báo đẩy FCM cho bệnh nhân
            try {
                $firstLK = LuotKham::find($listMaLK[0]);
                if ($firstLK) {
                    $hoSo = DB::table('ho_so_benh_an')->where('ma_ho_so', $firstLK->ma_ho_so)->first();
                    if ($hoSo) {
                        $phone = $hoSo->so_dien_thoai;
                        if (empty($phone) && !empty($hoSo->ma_benh_nhan)) {
                            $bn = DB::table('benh_nhan')->where('ma_benh_nhan', $hoSo->ma_benh_nhan)->first();
                            $phone = $bn?->so_dien_thoai;
                        }

                        if ($phone) {
                            $phone0 = str_starts_with($phone, '+84') ? '0' . substr($phone, 3) : $phone;
                            $phone84 = str_starts_with($phone, '0') ? '+84' . substr($phone, 1) : $phone;

                            $user = User::whereIn('phone_number', [$phone, $phone0, $phone84])->first();

                            if ($user && !empty($user->fcm_token)) {
                                $countLK = count($listMaLK);
                                $msgText = $countLK > 1
                                    ? "Đã thanh toán thành công cho {$countLK} chuyên khoa khám. Mã QR check-in đã sẵn sàng trên ứng dụng!"
                                    : "Lượt khám #{$listMaLK[0]} đã được thanh toán. Mã QR check-in đã sẵn sàng trên ứng dụng!";

                                FCMService::sendNotification(
                                    $user->fcm_token,
                                    '💳 Thanh toán thành công!',
                                    $msgText,
                                    [
                                        'type' => 'payment_success',
                                        'ma_luot_kham' => (string)$listMaLK[0],
                                        'trang_thai' => 'da_thanh_toan'
                                    ]
                                );
                                Log::info("Đã gửi FCM payment_success cho các lượt khám " . json_encode($listMaLK));
                            }
                        }
                    }
                }
            } catch (\Exception $e) {
                Log::error('Lỗi gửi FCM thanh toán thành công: ' . $e->getMessage());
            }
        }

        // Nếu client yêu cầu JSON (ví dụ gọi từ API / Postman)
        if ($request->wantsJson()) {
            return response()->json([
                'status' => $isSuccess ? 'success' : 'error',
                'message' => $isSuccess ? 'Thanh toán thành công' : 'Thanh toán thất bại',
                'response_code' => $responseCode,
                'ma_luot_kham' => $maLuotKham,
                'amount' => $request->input('vnp_Amount') ? ($request->input('vnp_Amount') / 100) : 0,
            ], $isSuccess ? 200 : 400);
        }

        // Trả về view HTML cho trình duyệt điện thoại
        return response()->view('vnpay_return', [
            'isSuccess' => $isSuccess,
            'responseCode' => $responseCode,
            'maLuotKham' => $maLuotKham,
            'amount' => $request->input('vnp_Amount') ? ($request->input('vnp_Amount') / 100) : 0,
            'transactionNo' => $request->input('vnp_TransactionNo', ''),
        ]);
    }
}
