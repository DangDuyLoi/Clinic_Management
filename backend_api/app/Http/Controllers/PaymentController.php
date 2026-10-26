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
        $vnp_Returnurl = env('VNPAY_RETURN_URL', $request->getSchemeAndHttpHost() . '/api/vnpay/return');
        if (str_contains($vnp_Returnurl, '192.168.1.58')) {
            $vnp_Returnurl = $request->getSchemeAndHttpHost() . '/api/vnpay/return';
        }

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

    /**
     * API: Lấy danh sách phiếu chờ thanh toán & lịch sử thanh toán đồng bộ từ Database
     * GET /api/payment/bills
     */
    public function getBills(Request $request)
    {
        try {
            $phone = $request->query('phone');
            $maHoSoList = $request->input('danh_sach_ma_ho_so');

            if (is_string($maHoSoList)) {
                $maHoSoList = explode(',', $maHoSoList);
            }

            // Nếu truyền phone, lấy các ma_ho_so liên quan
            if (!empty($phone) && empty($maHoSoList)) {
                $cleanPhone = preg_replace('/^\+84/', '0', $phone);
                $intlPhone = '+84' . ltrim($cleanPhone, '0');
                $phones = array_unique([$phone, $cleanPhone, $intlPhone]);
                
                $hsFromHoSo = DB::table('ho_so_benh_an')
                    ->whereIn('so_dien_thoai', $phones)
                    ->pluck('ma_ho_so')
                    ->toArray();

                $hsFromBN = DB::table('ho_so_benh_an')
                    ->join('benh_nhan', 'ho_so_benh_an.ma_benh_nhan', '=', 'benh_nhan.ma_benh_nhan')
                    ->whereIn('benh_nhan.so_dien_thoai', $phones)
                    ->pluck('ho_so_benh_an.ma_ho_so')
                    ->toArray();

                $maHoSoList = array_values(array_unique(array_merge($hsFromHoSo, $hsFromBN)));
            }

            // 1. LẤY TỪ BẢNG luot_kham (Lượt khám bệnh đặt qua app)
            $queryLK = DB::table('luot_kham')
                ->leftJoin('ho_so_benh_an', 'luot_kham.ma_ho_so', '=', 'ho_so_benh_an.ma_ho_so')
                ->leftJoin('BacSi', 'luot_kham.ma_bac_si', '=', 'BacSi.ma_bs')
                ->leftJoin('chuyenkhoa', 'BacSi.ma_chuyen_khoa', '=', 'chuyenkhoa.ma_chuyen_khoa')
                ->leftJoin('users', 'luot_kham.ma_bac_si', '=', 'users.id')
                ->select(
                    'luot_kham.ma_luot_kham',
                    'luot_kham.ma_ho_so',
                    'luot_kham.thoi_gian_den_kham',
                    'luot_kham.trang_thai',
                    'luot_kham.created_at',
                    'luot_kham.updated_at',
                    DB::raw("TRIM(CONCAT(COALESCE(ho_so_benh_an.ho_chu_lot, ''), ' ', COALESCE(ho_so_benh_an.ten, ''))) as ten_benh_nhan"),
                    'ho_so_benh_an.so_dien_thoai',
                    DB::raw("COALESCE(BacSi.ho_ten, users.name, 'Bác sĩ chuyên khoa') as ten_bac_si"),
                    DB::raw("COALESCE(chuyenkhoa.ten_chuyen_khoa, 'Khám chuyên khoa') as ten_chuyen_khoa")
                )
                ->where('luot_kham.trang_thai', '!=', 'huy');

            if (!empty($maHoSoList)) {
                $queryLK->whereIn('luot_kham.ma_ho_so', $maHoSoList);
            }

            $allVisits = $queryLK->orderBy('luot_kham.ma_luot_kham', 'desc')->get();

            $pendingBills = [];
            $paymentHistory = [];

            foreach ($allVisits as $v) {
                $dateFormatted = date('d/m/Y', strtotime($v->thoi_gian_den_kham));
                $timeFormatted = date('H:i', strtotime($v->thoi_gian_den_kham));
                $updatedFormatted = date('H:i - d/m/Y', strtotime($v->updated_at ?? $v->created_at));

                // Phiếu chờ thanh toán
                if ($v->trang_thai === 'cho_thanh_toan') {
                    $pendingBills[] = [
                        'ma_luot_kham' => (int) $v->ma_luot_kham,
                        'ngay_kham' => $dateFormatted,
                        'thoi_gian_kham' => $timeFormatted,
                        'chuyen_khoa' => $v->ten_chuyen_khoa,
                        'bac_si' => $v->ten_bac_si,
                        'ten_benh_nhan' => $v->ten_benh_nhan,
                        'tien_kham' => 150000,
                        'tien_dich_vu' => 0,
                        'tien_thuoc' => 0,
                        'tong_tien' => 150000,
                        'trang_thai' => 'Chờ thanh toán',
                        'chi_tiet_dich_vu' => [
                            ['ten' => 'Khám chuyên khoa ' . $v->ten_chuyen_khoa, 'gia' => 150000]
                        ],
                        'chi_tiet_thuoc' => []
                    ];
                } 
                // Lịch sử đã thanh toán
                else if (in_array($v->trang_thai, ['da_thanh_toan', 'cho_kham', 'dang_kham', 'hoan_thanh'])) {
                    $paymentHistory[] = [
                        'ma_giao_dich' => 'VNP_LK_' . $v->ma_luot_kham,
                        'ma_luot_kham' => (int) $v->ma_luot_kham,
                        'ngay_kham' => $dateFormatted,
                        'thoi_gian_thanh_toan' => $updatedFormatted,
                        'chuyen_khoa' => $v->ten_chuyen_khoa,
                        'bac_si' => $v->ten_bac_si,
                        'ten_benh_nhan' => $v->ten_benh_nhan,
                        'tien_kham' => 150000,
                        'tien_dich_vu' => 0,
                        'tien_thuoc' => 0,
                        'tong_tien' => 150000,
                        'phuong_thuc' => 'VNPay Gateway',
                        'trang_thai' => 'Thành công'
                    ];
                }
            }

            // 2. LẤY THÊM TỪ BẢNG hoadon (Viện phí tại bệnh viện nếu có)
            $queryHD = DB::table('hoadon')
                ->leftJoin('phienkham', 'hoadon.ma_phien_kham', '=', 'phienkham.ma_phien_kham')
                ->select('hoadon.*', 'phienkham.chan_doan_cuoi_cung')
                ->orderBy('hoadon.ma_hoa_don', 'desc');

            $hospitalInvoices = $queryHD->limit(10)->get();
            foreach ($hospitalInvoices as $hd) {
                $ngayTao = date('d/m/Y', strtotime($hd->ngay_tao));
                $ngayTT = !empty($hd->ngay_thanh_toan) ? date('H:i - d/m/Y', strtotime($hd->ngay_thanh_toan)) : $ngayTao;

                if ($hd->trang_thai === 'ChuaThanhToan') {
                    $pendingBills[] = [
                        'ma_hoa_don' => (int) $hd->ma_hoa_don,
                        'ma_luot_kham' => (int) ($hd->ma_phien_kham ?? $hd->ma_hoa_don),
                        'ngay_kham' => $ngayTao,
                        'chuyen_khoa' => 'Khám tổng quát / Cận lâm sàng',
                        'bac_si' => 'Bác sĩ điều trị',
                        'tien_kham' => (int) $hd->tien_kham_benh,
                        'tien_dich_vu' => (int) $hd->tien_dich_vu,
                        'tien_thuoc' => (int) $hd->tien_thuoc,
                        'tong_tien' => (int) $hd->tong_cong,
                        'trang_thai' => 'Chờ thanh toán',
                        'chi_tiet_dich_vu' => [
                            ['ten' => 'Chi phí khám bệnh', 'gia' => (int) $hd->tien_kham_benh],
                            ['ten' => 'Chi phí cận lâm sàng', 'gia' => (int) $hd->tien_dich_vu],
                        ],
                        'chi_tiet_thuoc' => [
                            ['ten' => 'Tiền thuốc theo đơn', 'gia' => (int) $hd->tien_thuoc],
                        ]
                    ];
                } else if ($hd->trang_thai === 'DaThanhToan') {
                    $paymentHistory[] = [
                        'ma_giao_dich' => 'HD_' . $hd->ma_hoa_don,
                        'ma_luot_kham' => (int) ($hd->ma_phien_kham ?? $hd->ma_hoa_don),
                        'ngay_kham' => $ngayTao,
                        'thoi_gian_thanh_toan' => $ngayTT,
                        'chuyen_khoa' => 'Khám tổng quát / Cận lâm sàng',
                        'bac_si' => 'Bác sĩ điều trị',
                        'tien_kham' => (int) $hd->tien_kham_benh,
                        'tien_dich_vu' => (int) $hd->tien_dich_vu,
                        'tien_thuoc' => (int) $hd->tien_thuoc,
                        'tong_tien' => (int) $hd->tong_cong,
                        'phuong_thuc' => $hd->phuong_thuc ?? 'VNPay / Tiền mặt',
                        'trang_thai' => 'Thành công'
                    ];
                }
            }

            return response()->json([
                'status' => 'success',
                'data' => [
                    'pending_bills' => $pendingBills,
                    'payment_history' => $paymentHistory,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Lỗi lấy danh sách viện phí: ' . $e->getMessage()
            ], 500);
        }
    }
}
