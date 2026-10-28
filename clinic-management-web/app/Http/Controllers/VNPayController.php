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
                $hashData .= '&' . urlencode($key) . '=' . urlencode($value);
            } else {
                $hashData .= urlencode($key) . '=' . urlencode($value);
                $i = 1;
            }
            $query .= urlencode($key) . '=' . urlencode($value) . '&';
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

        // 1. Lấy mã hash VNPay gửi đến
        $vnp_SecureHash = $request->input('vnp_SecureHash');

        // 2. Lấy nguyên chuỗi query string gốc (tránh bị Laravel tự động decode)
        $queryString = $request->getQueryString();

        // 3. Cắt bỏ phần vnp_SecureHash và vnp_SecureHashType ra khỏi chuỗi gốc
        $hashData = preg_replace('/(&vnp_SecureHashType=[^&]*)/', '', $queryString);
        $hashData = preg_replace('/(&vnp_SecureHash=[^&]*)/', '', $hashData);
        $hashData = preg_replace('/(vnp_SecureHashType=[^&]*&)/', '', $hashData);
        $hashData = preg_replace('/(vnp_SecureHash=[^&]*&)/', '', $hashData);
        $hashData = str_replace('vnp_SecureHash=' . $vnp_SecureHash, '', $hashData);

        // 4. Tính hash từ chuỗi gốc
        $secureHash = hash_hmac('sha512', $hashData, $vnp_HashSecret);

        // Lấy dữ liệu mảng để xử lý logic phía dưới
        $inputData = $request->all();
        $responseCode = $inputData['vnp_ResponseCode'] ?? '';
        $txnRef = $inputData['vnp_TxnRef'] ?? '';

        Log::info('[VNPay] Return URL hit', [
            'response_code' => $responseCode,
            'txn_ref'       => $txnRef,
            'amount'        => $inputData['vnp_Amount'] ?? 'N/A',
            'signature_ok'  => ($secureHash === $vnp_SecureHash),
        ]);

        // Verify signature
        if ($secureHash !== $vnp_SecureHash) {
            // Log thêm dữ liệu để debug nếu vẫn còn sai
            Log::warning('[VNPay Return] Invalid signature', [
                'hashData_Cua_Ban' => $hashData,
                'Hash_Cua_VNPay'   => $vnp_SecureHash,
                'Hash_Ban_Tinh'    => $secureHash
            ]);
            return redirect('/views/receptionist/payments.html?status=invalid_signature');
        }

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
        $vnp_SecureHash = $_GET['vnp_SecureHash'] ?? '';
        $queryString = $_SERVER['QUERY_STRING'] ?? '';
        
        $hashData = preg_replace('/(&vnp_SecureHashType=[^&]*)/', '', $queryString);
        $hashData = preg_replace('/(&vnp_SecureHash=[^&]*)/', '', $hashData);
        $hashData = preg_replace('/(vnp_SecureHashType=[^&]*&)/', '', $hashData);
        $hashData = preg_replace('/(vnp_SecureHash=[^&]*&)/', '', $hashData);
        $hashData = str_replace('vnp_SecureHash=' . $vnp_SecureHash, '', $hashData);

        $secureHash = hash_hmac('sha512', $hashData, $vnp_HashSecret);

        if ($secureHash !== $vnp_SecureHash) {
            return response()->json(['RspCode' => '97', 'Message' => 'Invalid signature']);
        }

        $inputData = $request->all();
        $responseCode = $inputData['vnp_ResponseCode'] ?? '';
        $txnRef       = $inputData['vnp_TxnRef'] ?? '';
        $amount       = $inputData['vnp_Amount'] ?? 0;
        
        $maHoaDon = explode('_', $txnRef)[0] ?? '';
        $hoaDon = HoaDon::with('phienKham.lichKham.benhNhan')->find($maHoaDon);
        
        if (!$hoaDon) {
            return response()->json(['RspCode' => '01', 'Message' => 'Order not found']);
        }

        $expectedAmount = (int) ($hoaDon->tong_cong * 100);
        if ((int) $amount !== $expectedAmount) {
            return response()->json(['RspCode' => '04', 'Message' => 'Invalid amount']);
        }

        if ($hoaDon->trang_thai === 'DaThanhToan') {
            return response()->json(['RspCode' => '02', 'Message' => 'Order already confirmed']);
        }

        if ($responseCode === '00') {
            $hoaDon->trang_thai = 'DaThanhToan';
            $hoaDon->phuong_thuc = 'VNPay';
            $hoaDon->ngay_thanh_toan = now();
            $hoaDon->save();

            // Cập nhật Phiên khám + Lịch khám
            if ($hoaDon->phienKham) {
                $hoaDon->phienKham->trang_thai = 'HoanThanh';
                $hoaDon->phienKham->save();

                if ($hoaDon->phienKham->lichKham) {
                    $hoaDon->phienKham->lichKham->trang_thai = 'HoanThanh';
                    $hoaDon->phienKham->lichKham->save();
                }
            }

            // ⭐ BỔ SUNG: Ghi nhật ký hệ thống (Không có ma_tk vì là hệ thống tự động)
            \App\Http\Controllers\NhatKyHeThongController::ghiLog(
                null, // Hệ thống tự động
                'UPDATE',
                'HoaDon',
                json_encode(['trang_thai' => 'ChuaThanhToan']),
                json_encode(['trang_thai' => 'DaThanhToan', 'phuong_thuc' => 'VNPay'])
            );

            // ⭐ BỔ SUNG: Gửi thông báo cho Admin (Giống hệt hàm pay)
            try {
                $tenBn = $hoaDon->phienKham->lichKham->benhNhan->ho_ten ?? 'bệnh nhân';
                $soTien = number_format($hoaDon->tong_cong, 0, ',', '.') . 'đ';

                \App\Models\ThongBao::guiTheoVaiTro(
                    'QuanTri',
                    "💰 Có hóa đơn mới đã thanh toán (VNPay)",
                    "HĐ #{$hoaDon->ma_hoa_don} — {$tenBn} — {$soTien}",
                    'thanh_toan',
                    '/views/admin/dashboard.html'
                );
            } catch (\Exception $e) {
                \Log::warning('Lỗi gửi thông báo VNPay: ' . $e->getMessage());
            }
        }

        return response()->json(['RspCode' => '00', 'Message' => 'Confirm Success']);
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
        ]);

        $txnRef = $request->txn_ref;
        $responseCode = $request->input('response_code', '00');

        $mockData = cache()->get("vnpay_mock_{$txnRef}");
        if (!$mockData) {
            return response()->json(['status' => 'error', 'message' => 'Giao dịch không tồn tại hoặc đã hết hạn'], 404);
        }

        $hoaDon = HoaDon::with('phienKham.lichKham.benhNhan')->find($mockData['ma_hoa_don']);
        if (!$hoaDon) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy hóa đơn'], 404);
        }

        if ($responseCode === '00') {
            if ($hoaDon->trang_thai === 'DaThanhToan') {
                return response()->json(['status' => 'info', 'message' => 'Hóa đơn đã được thanh toán trước đó']);
            }

            $hoaDon->trang_thai      = 'DaThanhToan';
            $hoaDon->phuong_thuc     = 'VNPay';
            $hoaDon->ngay_thanh_toan = now();
            $hoaDon->save();

            // Cập nhật Phiên khám + Lịch khám
            if ($hoaDon->phienKham) {
                $hoaDon->phienKham->trang_thai = 'HoanThanh';
                $hoaDon->phienKham->save();

                if ($hoaDon->phienKham->lichKham) {
                    $hoaDon->phienKham->lichKham->trang_thai = 'HoanThanh';
                    $hoaDon->phienKham->lichKham->save();
                }
            }

            // ⭐ Ghi nhật ký hệ thống
            \App\Http\Controllers\NhatKyHeThongController::ghiLog(
                auth('api')->id(), // Có thể lấy ID lễ tân đang thao tác (nếu có)
                'UPDATE',
                'HoaDon',
                json_encode(['trang_thai' => 'ChuaThanhToan']),
                json_encode(['trang_thai' => 'DaThanhToan', 'phuong_thuc' => 'VNPay'])
            );

            // ⭐ Gửi thông báo cho Admin
            try {
                $tenBn = $hoaDon->phienKham->lichKham->benhNhan->ho_ten ?? 'bệnh nhân';
                $soTien = number_format($hoaDon->tong_cong, 0, ',', '.') . 'đ';

                \App\Models\ThongBao::guiTheoVaiTro(
                    'QuanTri',
                    "💰 Có hóa đơn mới đã thanh toán (VNPay MOCK)",
                    "HĐ #{$hoaDon->ma_hoa_don} — {$tenBenhNhan} — {$soTien}",
                    'thanh_toan',
                    '/views/admin/dashboard.html'
                );
            } catch (\Exception $e) {
                \Log::warning('Lỗi gửi thông báo VNPay MOCK: ' . $e->getMessage());
            }

            cache()->forget("vnpay_mock_{$txnRef}");

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

        return response()->json([
            'status'  => 'error',
            'message' => "Thanh toán thất bại (mã lỗi: {$responseCode})",
        ], 400);
    }
}