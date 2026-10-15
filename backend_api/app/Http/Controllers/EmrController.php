<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\User;

class EmrController extends Controller
{
    /**
     * Lấy danh sách ID bệnh nhân từ request (SĐT, user token, profile ID)
     */
    private function resolvePatientIds(Request $request): array
    {
        $phone = $request->query('phone');
        
        // Nếu không có param phone, thử lấy từ token hoặc user
        if (!$phone) {
            $user = $request->user();
            if ($user) {
                $phone = $user->phone_number;
            }
        }

        // Nếu vẫn không có, lấy số mặc định đang đăng nhập hiện tại
        if (!$phone) {
            $phone = '0374244315';
        }

        $cleanPhone = preg_replace('/^\+84/', '0', $phone);
        $intlPhone = '+84' . ltrim($cleanPhone, '0');

        $bnIds = DB::table('benhnhan')
            ->where('so_dien_thoai', $cleanPhone)
            ->orWhere('so_dien_thoai', $intlPhone)
            ->pluck('ma_bn')
            ->toArray();

        // Nếu chưa có trong benhnhan, thử kiểm tra benh_nhan
        if (empty($bnIds)) {
            $bnIds = DB::table('benh_nhan')
                ->where('so_dien_thoai', $cleanPhone)
                ->orWhere('so_dien_thoai', $intlPhone)
                ->pluck('ma_benh_nhan')
                ->toArray();
        }

        return $bnIds;
    }

    /**
     * API: Lấy lịch sử khám bệnh (Hồ sơ bệnh án)
     * GET /api/emr/lich-su-kham
     */
    public function getVisitHistory(Request $request)
    {
        try {
            $bnIds = $this->resolvePatientIds($request);

            if (empty($bnIds)) {
                return response()->json([
                    'status' => 'success',
                    'data' => []
                ]);
            }

            $pks = DB::table('phienkham')
                ->join('lichkham', 'phienkham.ma_lich_dat', '=', 'lichkham.ma_lich_dat')
                ->leftJoin('bacsi', 'lichkham.ma_bs', '=', 'bacsi.ma_bs')
                ->leftJoin('chuyenkhoa', 'bacsi.ma_chuyen_khoa', '=', 'chuyenkhoa.ma_chuyen_khoa')
                ->whereIn('lichkham.ma_bn', $bnIds)
                ->select(
                    'phienkham.ma_phien_kham',
                    'phienkham.chan_doan_so_bo',
                    'phienkham.chan_doan_cuoi_cung',
                    'phienkham.ghi_chu_y_te',
                    'lichkham.ngay_kham',
                    'bacsi.ho_ten as ten_bac_si',
                    'bacsi.phong_kham',
                    'chuyenkhoa.ten_chuyen_khoa'
                )
                ->orderBy('lichkham.ngay_kham', 'desc')
                ->get();

            $visits = [];
            foreach ($pks as $pk) {
                // Đơn thuốc kèm theo phiên khám
                $meds = DB::table('chitietdonthuoc')
                    ->join('donthuoc', 'chitietdonthuoc.ma_don_thuoc', '=', 'donthuoc.ma_don_thuoc')
                    ->join('thuoc', 'chitietdonthuoc.ma_thuoc', '=', 'thuoc.ma_thuoc')
                    ->where('donthuoc.ma_phien_kham', $pk->ma_phien_kham)
                    ->select('thuoc.ten_thuoc', 'thuoc.don_vi_tinh', 'chitietdonthuoc.so_luong', 'chitietdonthuoc.lieu_luong')
                    ->get();

                $medications = [];
                foreach ($meds as $m) {
                    $medications[] = [
                        'name' => $m->ten_thuoc,
                        'quantity' => "{$m->so_luong} {$m->don_vi_tinh}",
                        'dosage' => $m->lieu_luong ?? 'Theo chỉ định của bác sĩ',
                    ];
                }

                $dateFormatted = date('d/m/Y', strtotime($pk->ngay_kham));
                $visits[] = [
                    'id' => $pk->ma_phien_kham,
                    'date' => $dateFormatted,
                    'department' => $pk->ten_chuyen_khoa ?? 'Khám Tổng Quát',
                    'doctor' => $pk->ten_bac_si ?? 'Bác sĩ chuyên khoa',
                    'room' => $pk->phong_kham ?? 'Phòng Khám',
                    'diagnosis' => $pk->chan_doan_cuoi_cung ?: ($pk->chan_doan_so_bo ?: 'Chưa có chẩn đoán'),
                    'note' => $pk->ghi_chu_y_te,
                    'medications' => $medications,
                ];
            }

            return response()->json([
                'status' => 'success',
                'data' => $visits
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * API: Lấy kết quả cận lâm sàng (CLS)
     * GET /api/emr/ket-qua-cls
     */
    public function getTestResults(Request $request)
    {
        try {
            $bnIds = $this->resolvePatientIds($request);

            if (empty($bnIds)) {
                return response()->json([
                    'status' => 'success',
                    'data' => []
                ]);
            }

            $clsList = DB::table('chidinhdichvu')
                ->join('phienkham', 'chidinhdichvu.ma_phien_kham', '=', 'phienkham.ma_phien_kham')
                ->join('lichkham', 'phienkham.ma_lich_dat', '=', 'lichkham.ma_lich_dat')
                ->join('dichvu', 'chidinhdichvu.ma_dich_vu', '=', 'dichvu.ma_dich_vu')
                ->leftJoin('bacsi', 'lichkham.ma_bs', '=', 'bacsi.ma_bs')
                ->leftJoin('chuyenkhoa', 'bacsi.ma_chuyen_khoa', '=', 'chuyenkhoa.ma_chuyen_khoa')
                ->whereIn('lichkham.ma_bn', $bnIds)
                ->select(
                    'chidinhdichvu.ma_chi_dinh',
                    'chidinhdichvu.ket_qua_chi_tiet',
                    'chidinhdichvu.trang_thai',
                    'dichvu.ten_dich_vu',
                    'dichvu.don_gia',
                    'lichkham.ngay_kham',
                    'bacsi.ho_ten as ten_bac_si',
                    'chuyenkhoa.ten_chuyen_khoa'
                )
                ->orderBy('lichkham.ngay_kham', 'desc')
                ->get();

            $clsResults = [];
            foreach ($clsList as $cls) {
                $dateFormatted = date('d/m/Y', strtotime($cls->ngay_kham));
                $clsResults[] = [
                    'id' => $cls->ma_chi_dinh,
                    'date' => $dateFormatted,
                    'test_name' => $cls->ten_dich_vu,
                    'department' => $cls->ten_chuyen_khoa ?? 'Khoa Xét Nghiệm & CĐHA',
                    'doctor' => $cls->ten_bac_si ?? 'Bác sĩ chỉ định',
                    'result' => $cls->ket_qua_chi_tiet ?? 'Chưa có kết quả',
                    'status' => $cls->trang_thai == 'DaCoKetQua' ? 'Đã có kết quả' : 'Đang xử lý',
                    'price' => number_format($cls->don_gia, 0, ',', '.') . 'đ',
                ];
            }

            return response()->json([
                'status' => 'success',
                'data' => $clsResults
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
