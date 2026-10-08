<?php

namespace App\Http\Controllers;

use App\Models\HoaDon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;
class VNPayController extends Controller
{
    /* ============================================================
       TẠO URL THANH TOÁN
       ============================================================ */
    public function createPayment(Request $request, $hoaDonId)
    {
        $hoaDon = HoaDon::findOrFail($hoaDonId);

        $vnp_TmnCode    = config('services.vnpay.tmn_code');
        $vnp_HashSecret = config('services.vnpay.hash_secret');
        $vnp_Url        = config('services.vnpay.url');
        $vnp_ReturnUrl  = config('services.vnpay.return_url');

        $vnp_TxnRef    = $hoaDon->ma_hoa_don . '_' . time();
        $vnp_OrderInfo = 'Thanh toan hoa don ' . $hoaDon->ma_hoa_don;   // Không dấu #
        $vnp_OrderType = 'other';                                         // Không dùng 'billpayment'
        $vnp_Amount    = (int) ($hoaDon->tong_cong * 100);
        $vnp_Locale    = 'vn';
        $vnp_BankCode  = '';                                              // Để trống = user chọn bank
        $vnp_IpAddr    = '127.0.0.1';                                     // Fix cứng IP

        // Fix timezone
        date_default_timezone_set('Asia/Ho_Chi_Minh');
        $vnp_CreateDate = date('YmdHis');
        $vnp_ExpireDate = date('YmdHis', strtotime('+15 minutes'));

        $inputData = [
            'vnp_Version'    => '2.1.0',
            'vnp_TmnCode'    => $vnp_TmnCode,
            'vnp_Amount'     => $vnp_Amount,
            'vnp_Command'    => 'pay',
            'vnp_CreateDate' => $vnp_CreateDate,
            'vnp_CurrCode'   => 'VND',
            'vnp_IpAddr'     => $vnp_IpAddr,
            'vnp_Locale'     => $vnp_Locale,
            'vnp_OrderInfo'  => $vnp_OrderInfo,
            'vnp_OrderType'  => $vnp_OrderType,
            'vnp_ReturnUrl'  => $vnp_ReturnUrl,
            'vnp_TxnRef'     => $vnp_TxnRef,
            'vnp_ExpireDate' => $vnp_ExpireDate,
        ];

        // Chỉ thêm BankCode nếu có
        if (!empty($vnp_BankCode)) {
            $inputData['vnp_BankCode'] = $vnp_BankCode;
        }

        // ⭐ SẮP XẾP KEY ALPHABET (BẮT BUỘC)
        ksort($inputData);

        // ⭐ BUILD HASH DATA — DÙNG rawurlencode
        $hashData = '';
        $query = '';
        $i = 0;
        foreach ($inputData as $key => $value) {
            if ($i === 1) {
                $hashData .= '&' . rawurlencode($key) . '=' . rawurlencode($value);
            } else {
                $hashData .= rawurlencode($key) . '=' . rawurlencode($value);
                $i = 1;
            }
            $query .= rawurlencode($key) . '=' . rawurlencode($value) . '&';
        }

        // Tạo hash
        $vnpSecureHash = hash_hmac('sha512', $hashData, $vnp_HashSecret);

        // ⭐ LOG ĐỂ DEBUG
        \Log::info('[VNPay] createPayment', [
            'hoa_don'       => $hoaDon->ma_hoa_don,
            'hashData'      => $hashData,
            'hash_md5'      => md5($hashData),
            'hash_secret_5' => substr($vnp_HashSecret, 0, 5),
            'hash_secret_5l'=> substr($vnp_HashSecret, -5),
            'create_date'   => $vnp_CreateDate,
            'expire_date'   => $vnp_ExpireDate,
        ]);

        // URL đầy đủ
        $paymentUrl = $vnp_Url . '?' . $query . 'vnp_SecureHash=' . $vnpSecureHash;

        return response()->json([
            'status'      => 'success',
            'message'     => 'Tạo URL thanh toán thành công',
            'payment_url' => $paymentUrl,
            'txn_ref'     => $vnp_TxnRef,
            'debug'       => [
                'hash_md5'    => md5($hashData),
                'create_date' => $vnp_CreateDate,
            ],
        ]);
    }
    /* ============================================================
       RETURN URL — User quay về sau khi thanh toán
       ============================================================ */
    public function return(Request $request)
    {
        $vnp_HashSecret = config('services.vnpay.hash_secret');
        $inputData = $request->all();
        $vnp_SecureHash = $inputData['vnp_SecureHash'] ?? '';

        // Xóa hash khỏi data để verify
        unset($inputData['vnp_SecureHash']);
        unset($inputData['vnp_SecureHashType']);

        ksort($inputData);

        // Tạo hash để so sánh
        $hashData = '';
        $i = 0;
        foreach ($inputData as $key => $value) {
            if ($i === 1) {
                $hashData .= '&' . urlencode($key) . '=' . urlencode($value);
            } else {
                $hashData .= urlencode($key) . '=' . urlencode($value);
                $i = 1;
            }
        }

        $secureHash = hash_hmac('sha512', $hashData, $vnp_HashSecret);

        Log::info('[VNPay] Return URL hit', [
            'response_code' => $inputData['vnp_ResponseCode'] ?? 'N/A',
            'txn_ref'       => $inputData['vnp_TxnRef'] ?? 'N/A',
            'amount'        => $inputData['vnp_Amount'] ?? 'N/A',
            'signature_ok'  => ($secureHash === $vnp_SecureHash),
        ]);

        // Verify signature
        if ($secureHash !== $vnp_SecureHash) {
            return redirect('/views/receptionist/payments.html?status=invalid_signature');
        }

        $responseCode = $inputData['vnp_ResponseCode'] ?? '';
        $txnRef = $inputData['vnp_TxnRef'] ?? '';

        // Lấy mã hóa đơn từ txn_ref (format: HDxxx_timestamp)
        $maHoaDon = explode('_', $txnRef)[0] ?? '';

        if ($responseCode === '00') {
            // Thanh toán thành công
            return redirect("/views/receptionist/payments.html?status=success&hoa_don={$maHoaDon}");
        } else {
            // Thanh toán thất bại / hủy
            return redirect("/views/receptionist/payments.html?status=failed&code={$responseCode}");
        }
    }

    /* ============================================================
       IPN URL — VNPay gọi server-to-server để xác nhận
       (POST, không redirect user)
       ============================================================ */
    public function ipn(Request $request)
    {
        $vnp_HashSecret = config('services.vnpay.hash_secret');
        $inputData = $request->all();
        $vnp_SecureHash = $inputData['vnp_SecureHash'] ?? '';

        unset($inputData['vnp_SecureHash']);
        unset($inputData['vnp_SecureHashType']);

        ksort($inputData);

        $hashData = '';
        $i = 0;
        foreach ($inputData as $key => $value) {
            if ($i === 1) {
                $hashData .= '&' . urlencode($key) . '=' . urlencode($value);
            } else {
                $hashData .= urlencode($key) . '=' . urlencode($value);
                $i = 1;
            }
        }

        $secureHash = hash_hmac('sha512', $hashData, $vnp_HashSecret);

        // Verify signature
        if ($secureHash !== $vnp_SecureHash) {
            Log::warning('[VNPay IPN] Invalid signature');
            return response()->json([
                'RspCode' => '97',
                'Message' => 'Invalid signature',
            ]);
        }

        $responseCode = $inputData['vnp_ResponseCode'] ?? '';
        $txnRef       = $inputData['vnp_TxnRef'] ?? '';
        $amount       = $inputData['vnp_Amount'] ?? 0;
        $transactionNo = $inputData['vnp_TransactionNo'] ?? '';

        // Parse mã hóa đơn
        $maHoaDon = explode('_', $txnRef)[0] ?? '';

        Log::info('[VNPay IPN] Received', [
            'txn_ref'         => $txnRef,
            'response_code'   => $responseCode,
            'amount'          => $amount,
            'transaction_no'  => $transactionNo,
        ]);

        // Tìm hóa đơn
        $hoaDon = HoaDon::find($maHoaDon);
        if (!$hoaDon) {
            return response()->json([
                'RspCode' => '01',
                'Message' => 'Order not found',
            ]);
        }

        // Kiểm tra số tiền
        $expectedAmount = (int) ($hoaDon->tong_cong * 100);
        if ((int) $amount !== $expectedAmount) {
            return response()->json([
                'RspCode' => '04',
                'Message' => 'Invalid amount',
            ]);
        }

        // Nếu đã thanh toán rồi
        if ($hoaDon->trang_thai === 'DaThanhToan') {
            return response()->json([
                'RspCode' => '02',
                'Message' => 'Order already confirmed',
            ]);
        }

        // Thanh toán thành công
        if ($responseCode === '00') {
            $hoaDon->trang_thai = 'DaThanhToan';
            $hoaDon->phuong_thuc = 'VNPay';
            $hoaDon->ngay_thanh_toan = now();
            $hoaDon->save();

            Log::info('[VNPay IPN] HoaDon #' . $maHoaDon . ' marked as paid');
        }

        return response()->json([
            'RspCode' => '00',
            'Message' => 'Confirm Success',
        ]);
    }
        /* ============================================================
       MOCK — Tạo QR thanh toán VNPay giả lập
       Endpoint: POST /api/vnpay/mock-payment/{hoaDonId}
       ============================================================ */
    public function createMockPayment(Request $request, $hoaDonId)
    {
        $hoaDon = HoaDon::find($hoaDonId);

        if (!$hoaDon) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy hóa đơn',
            ], 404);
        }

        if ($hoaDon->trang_thai === 'DaThanhToan') {
            return response()->json([
                'status'  => 'error',
                'message' => 'Hóa đơn đã được thanh toán',
            ], 400);
        }

        // Sinh mã giao dịch giả lập
        $txnRef = $hoaDon->ma_hoa_don . '_' . time() . '_MOCK';
        $transactionNo = rand(10000000, 99999999);

        // Lưu txn_ref vào session/cache để simulate sau này
        cache()->put("vnpay_mock_{$txnRef}", [
            'ma_hoa_don' => $hoaDon->ma_hoa_don,
            'amount'     => $hoaDon->tong_cong,
            'created_at' => now(),
        ], now()->addMinutes(30));

        // Nội dung QR (giống format VNPay thật)
        $qrData = [
            'bank'          => 'VNPAY_SANDBOX_MOCK',
            'txn_ref'       => $txnRef,
            'transaction_no'=> $transactionNo,
            'invoice'       => 'HD' . str_pad($hoaDon->ma_hoa_don, 6, '0', STR_PAD_LEFT),
            'amount'        => $hoaDon->tong_cong,
            'content'       => 'Thanh toan hoa don ' . $hoaDon->ma_hoa_don,
            'timestamp'     => time(),
            'mock'          => true,
        ];

        $qrContent = json_encode($qrData);

        // Sinh QR qua API public
        $qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=' . urlencode($qrContent);

        return response()->json([
            'status'  => 'success',
            'message' => 'Tạo QR VNPay giả lập thành công',
            'data'    => [
                'ma_hoa_don'      => $hoaDon->ma_hoa_don,
                'txn_ref'         => $txnRef,
                'transaction_no'  => $transactionNo,
                'amount'          => $hoaDon->tong_cong,
                'qr_content'      => $qrContent,
                'qr_url'          => $qrUrl,
                'expired_at'      => now()->addMinutes(30)->format('H:i:s'),
            ],
        ]);
    }

    /* ============================================================
       MOCK — Giả lập VNPay callback thành công
       Endpoint: POST /api/vnpay/simulate-callback
       Body: { txn_ref, response_code }
       ============================================================ */
    public function simulateCallback(Request $request)
    {
        $request->validate([
            'txn_ref'       => 'required|string',
            'response_code' => 'nullable|string|in:00,24,51,99',
        ], [
            'txn_ref.required' => 'Thiếu mã giao dịch',
        ]);

        $txnRef = $request->txn_ref;
        $responseCode = $request->input('response_code', '00');

        // Lấy thông tin từ cache
        $mockData = cache()->get("vnpay_mock_{$txnRef}");

        if (!$mockData) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Giao dịch không tồn tại hoặc đã hết hạn',
            ], 404);
        }

        $hoaDon = HoaDon::find($mockData['ma_hoa_don']);

        if (!$hoaDon) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy hóa đơn',
            ], 404);
        }

        // Nếu thành công (response_code = 00)
        if ($responseCode === '00') {
            if ($hoaDon->trang_thai === 'DaThanhToan') {
                return response()->json([
                    'status'  => 'info',
                    'message' => 'Hóa đơn đã được thanh toán trước đó',
                ]);
            }

            $hoaDon->trang_thai      = 'DaThanhToan';
            $hoaDon->phuong_thuc     = 'VNPay';
            $hoaDon->ngay_thanh_toan = now();
            $hoaDon->save();

            // Cập nhật lịch khám + phiên khám
            if ($hoaDon->phienKham) {
                $hoaDon->phienKham->trang_thai = 'HoanThanh';
                $hoaDon->phienKham->save();

                if ($hoaDon->phienKham->lichKham) {
                    $hoaDon->phienKham->lichKham->trang_thai = 'HoanThanh';
                    $hoaDon->phienKham->lichKham->save();
                }
            }

            // Xóa cache
            cache()->forget("vnpay_mock_{$txnRef}");

            Log::info('[VNPay MOCK] Payment success', [
                'hoa_don' => $hoaDon->ma_hoa_don,
                'txn_ref' => $txnRef,
                'amount'  => $hoaDon->tong_cong,
            ]);

            return response()->json([
                'status'  => 'success',
                'message' => 'Thanh toán thành công (giả lập)',
                'data'    => [
                    'ma_hoa_don' => $hoaDon->ma_hoa_don,
                    'trang_thai' => $hoaDon->trang_thai,
                    'phuong_thuc'=> $hoaDon->phuong_thuc,
                ],
            ]);
        }

        // Thanh toán thất bại
        return response()->json([
            'status'  => 'error',
            'message' => "Thanh toán thất bại (mã lỗi: {$responseCode})",
        ], 400);
    }
}