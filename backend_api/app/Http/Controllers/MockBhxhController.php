<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class MockBhxhController extends Controller
{
    /**
     * API Giả lập Cổng BHXH - Tra cứu thẻ Bảo hiểm Y tế
     * GET /api/bhxh/tra-cuu-the?ma_the=...
     *
     * Quy tắc giả lập dựa trên mã thẻ:
     * - Bắt đầu bằng "DN" → Doanh nghiệp, hưởng 80%
     * - Bắt đầu bằng "TE" → Trẻ em dưới 6 tuổi, hưởng 100%
     * - Bắt đầu bằng "HN" → Hộ nghèo, hưởng 100%
     * - Bắt đầu bằng "CN" → Cận nghèo, hưởng 95%
     * - Bắt đầu bằng "CC" → Người có công, hưởng 100%
     * - Bắt đầu bằng "HT" → Hết hạn, thẻ hết hạn
     * - Còn lại → Mặc định hưởng 80%
     */
    /**
     * API Giả lập Cổng BHXH - Tra cứu thẻ Bảo hiểm Y tế & Giám định BHYT Quốc gia
     * GET/POST /api/bhxh/tra-cuu-the?ma_the=...&ma_ho_so=...
     * POST /api/bhxh/kiem-tra-giam-dinh
     *
     * Quy tắc giả lập dựa trên mã thẻ & Chống trục lợi BHYT:
     * - Thẻ trong danh sách đen / phát hiện trục lợi gom thuốc liên tục:
     *   + Bắt đầu bằng "CB" (Cảnh báo), "TL" (Trục lợi), "BL" (Blacklist)
     *   + Hoặc mã test cố định: "DN4010123456789", "DN4019999999999", "GD4019999999999"
     *   + Hoặc có 4 số cuối "9999"
     *   + Hoặc bệnh nhân khám liên tục nhiều ngày trong DB
     *   -> Trả về cảnh báo đen, từ chối thanh toán BHYT!
     * - Bắt đầu bằng "DN" → Doanh nghiệp, hưởng 80%
     * - Bắt đầu bằng "TE" → Trẻ em dưới 6 tuổi, hưởng 100%
     * - Bắt đầu bằng "HN" → Hộ nghèo, hưởng 100%
     * - Bắt đầu bằng "CN" → Cận nghèo, hưởng 95%
     * - Bắt đầu bằng "CC" → Người có công, hưởng 100%
     * - Bắt đầu bằng "HT" → Hết hạn, thẻ hết hạn
     * - Còn lại → Mặc định hưởng 80%
     */
    public function traCuuThe(Request $request)
    {
        $maThe = $request->input('ma_the') ?? $request->query('ma_the');
        $maHoSo = $request->input('ma_ho_so') ?? $request->query('ma_ho_so');

        if (empty($maThe)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Vui lòng cung cấp mã thẻ BHYT (tham số ma_the).'
            ], 422);
        }

        // Chuẩn hóa mã thẻ
        $maThe = strtoupper(trim($maThe));
        $prefix = substr($maThe, 0, 2);

        // 1. Kiểm tra dấu hiệu trục lợi gom thuốc qua Hệ thống Giám định BHYT Quốc gia
        $fraudWarning = $this->kiemTraTrucLoiGomThuoc($maThe, $maHoSo);
        if ($fraudWarning !== null) {
            return response()->json([
                'status' => 'warning',
                'is_blacklisted' => true,
                'canh_bao_truc_loi' => true,
                'message' => 'Hệ thống Giám định BHYT Quốc gia phát hiện dấu hiệu trục lợi!',
                'data' => $fraudWarning
            ], 200);
        }

        // 2. Dữ liệu giả lập theo prefix thông thường
        $mockData = $this->getMockDataByPrefix($prefix, $maThe);

        return response()->json([
            'status' => 'success',
            'is_blacklisted' => false,
            'canh_bao_truc_loi' => false,
            'data' => $mockData
        ], 200);
    }

    /**
     * API chuyên dụng kiểm tra giám định phòng chống trục lợi BHYT
     */
    public function kiemTraGiamDinh(Request $request)
    {
        return $this->traCuuThe($request);
    }

    /**
     * Phát hiện dấu hiệu trục lợi: đi khám liên tục nhiều ngày tại nhiều cơ sở để gom thuốc
     */
    private function kiemTraTrucLoiGomThuoc(string $maThe, $maHoSo = null): ?array
    {
        $prefix = substr($maThe, 0, 2);
        $tail4 = substr($maThe, -4);

        // Danh sách mã thẻ đen test trục lợi
        $blacklistedCodes = [
            'DN4010123456789',
            'DN4019999999999',
            'GD4019999999999',
            'TE1019999999999',
            'HN2019999999999',
        ];

        $isBlacklistedPrefix = in_array($prefix, ['CB', 'TL', 'BL']);
        $isBlacklistedCode = in_array($maThe, $blacklistedCodes) || $tail4 === '9999' || str_contains($maThe, 'TRUCLOI');

        // Kiểm tra trong DB nếu có mã hồ sơ: có khám liên tục >= 3 ngày gần đây không
        $recentVisitsCount = 0;
        if (!empty($maHoSo) && is_numeric($maHoSo)) {
            try {
                $recentVisitsCount = \Illuminate\Support\Facades\DB::table('luot_kham')
                    ->where('ma_ho_so', $maHoSo)
                    ->where('created_at', '>=', now()->subDays(7))
                    ->where('trang_thai', '!=', 'huy')
                    ->count();
            } catch (\Exception $e) {
                $recentVisitsCount = 0;
            }
        }

        if ($isBlacklistedPrefix || $isBlacklistedCode || $recentVisitsCount >= 4) {
            return [
                'ma_the' => $maThe,
                'ho_ten' => 'Bệnh nhân có cảnh báo BHYT',
                'tinh_trang' => 'Cảnh báo đen - Từ chối thanh toán',
                'muc_huong' => '0%',
                'canh_bao_truc_loi' => true,
                'is_blacklisted' => true,
                'muc_do_canh_bao' => 'Mức độ 3 (Nghiêm trọng)',
                'ly_do_tu_choi' => 'Hệ thống Giám định BHYT Quốc gia phát hiện bệnh nhân đi khám liên tục nhiều ngày tại nhiều cơ sở để gom thuốc. Thẻ BHYT bị đưa vào danh sách cảnh báo đen và từ chối thanh toán.',
                'chi_tiet_canh_bao' => [
                    'hanh_vi' => 'Đi khám liên tục nhiều ngày tại nhiều cơ sở y tế trùng lặp đơn thuốc trong 7 ngày gần nhất.',
                    'so_co_so_da_kham' => max(3, $recentVisitsCount),
                    'so_luot_kham_7_ngay' => max(4, $recentVisitsCount),
                    'danh_sach_co_so_ghi_nhan' => [
                        'Bệnh viện Quận Bình Thạnh (Ngày ' . date('d/m', strtotime('-3 days')) . ')',
                        'Phòng khám Đa khoa Hoàn Mỹ (Ngày ' . date('d/m', strtotime('-2 days')) . ')',
                        'Bệnh viện Đa khoa Quốc tế (Ngày ' . date('d/m', strtotime('-1 days')) . ')',
                    ],
                    'nhom_thuoc_nguy_co' => ['Thuốc kháng sinh Cefixim 200mg', 'Thuốc tim mạch Amlodipine 5mg', 'Paracetamol 500mg'],
                    'xu_ly' => 'Khóa quyền lợi BHYT. Từ chối thanh toán BHYT, bắt buộc chuyển sang Khám Dịch Vụ (Giá nội bộ).'
                ],
                'khuyen_nghi' => 'Vui lòng chuyển sang Khám Dịch Vụ hoặc liên hệ cơ quan BHXH địa phương để làm rõ dữ liệu khám chữa bệnh.'
            ];
        }

        return null;
    }

    /**
     * Trả về dữ liệu giả lập dựa trên 2 ký tự đầu của mã thẻ
     */
    private function getMockDataByPrefix(string $prefix, string $maThe): array
    {
        $baseData = [
            'ma_the' => $maThe,
            'ngay_cap' => '2025-01-01',
        ];

        return match ($prefix) {
            'TE' => array_merge($baseData, [
                'ho_ten' => 'Nguyễn Văn An (Trẻ em)',
                'ngay_sinh' => '2022-05-15',
                'tinh_trang' => 'Hợp lệ',
                'muc_huong' => '100%',
                'loai_the' => 'Trẻ em dưới 6 tuổi',
                'han_su_dung' => '2028-05-15',
                'noi_dang_ky_kcb' => 'Phòng khám Đa khoa Quận 1 - TP.HCM',
                'ghi_chu' => 'Trẻ em dưới 6 tuổi, hưởng 100% chi phí KCB',
            ]),
            'HN' => array_merge($baseData, [
                'ho_ten' => 'Trần Thị Bình (Hộ nghèo)',
                'ngay_sinh' => '1985-03-20',
                'tinh_trang' => 'Hợp lệ',
                'muc_huong' => '100%',
                'loai_the' => 'Hộ nghèo',
                'han_su_dung' => '2027-12-31',
                'noi_dang_ky_kcb' => 'Trung tâm Y tế Huyện Bình Chánh',
                'ghi_chu' => 'Hộ nghèo, hưởng 100% chi phí KCB',
            ]),
            'CN' => array_merge($baseData, [
                'ho_ten' => 'Lê Văn Cường (Cận nghèo)',
                'ngay_sinh' => '1990-08-12',
                'tinh_trang' => 'Hợp lệ',
                'muc_huong' => '95%',
                'loai_the' => 'Hộ cận nghèo',
                'han_su_dung' => '2027-12-31',
                'noi_dang_ky_kcb' => 'Bệnh viện Đa khoa Tỉnh Long An',
                'ghi_chu' => 'Hộ cận nghèo, hưởng 95% chi phí KCB',
            ]),
            'CC' => array_merge($baseData, [
                'ho_ten' => 'Phạm Văn Đức (Người có công)',
                'ngay_sinh' => '1955-01-10',
                'tinh_trang' => 'Hợp lệ',
                'muc_huong' => '100%',
                'loai_the' => 'Người có công với cách mạng',
                'han_su_dung' => '2028-12-31',
                'noi_dang_ky_kcb' => 'Bệnh viện Quân Y 175 - TP.HCM',
                'ghi_chu' => 'Người có công, hưởng 100% chi phí KCB',
            ]),
            'DN' => array_merge($baseData, [
                'ho_ten' => 'Nguyễn Thị Hoa (Doanh nghiệp)',
                'ngay_sinh' => '1992-11-30',
                'tinh_trang' => 'Hợp lệ',
                'muc_huong' => '80%',
                'loai_the' => 'Người lao động',
                'han_su_dung' => '2027-06-30',
                'noi_dang_ky_kcb' => 'Bệnh viện Đa khoa Quốc tế Thu Cúc',
                'ghi_chu' => 'BHYT doanh nghiệp, hưởng 80% chi phí KCB',
            ]),
            'HT' => array_merge($baseData, [
                'ho_ten' => 'Võ Văn Hùng (Hết hạn)',
                'ngay_sinh' => '1988-04-25',
                'tinh_trang' => 'Hết hạn',
                'muc_huong' => '0%',
                'loai_the' => 'Người lao động',
                'han_su_dung' => '2024-12-31',
                'noi_dang_ky_kcb' => 'Bệnh viện Nhân dân 115',
                'ghi_chu' => 'Thẻ BHYT đã hết hạn sử dụng. Vui lòng gia hạn.',
            ]),
            default => array_merge($baseData, [
                'ho_ten' => 'Đặng Văn Minh',
                'ngay_sinh' => '1995-07-20',
                'tinh_trang' => 'Hợp lệ',
                'muc_huong' => '80%',
                'loai_the' => 'Người lao động',
                'han_su_dung' => '2027-12-31',
                'noi_dang_ky_kcb' => 'Phòng khám Đa khoa Quận Bình Thạnh',
                'ghi_chu' => 'BHYT thông thường, hưởng 80% chi phí KCB',
            ]),
        };
    }
}

