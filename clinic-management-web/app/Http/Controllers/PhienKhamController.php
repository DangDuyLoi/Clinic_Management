<?php

namespace App\Http\Controllers;

use App\Models\PhienKham;
use App\Models\LichKham;
use App\Models\HoaDon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PhienKhamController extends Controller
{
    /* ============================================================
       GET /api/phien-kham
       ============================================================ */
    public function index(Request $request)
    {
        $query = PhienKham::with(['lichKham.hoSo.benhNhan', 'lichKham.bacSi', 'chiDinh.dichVu']);

        if ($ngay = $request->query('ngay')) {
            $query->whereHas('lichKham', function ($q) use ($ngay) {
                $q->whereDate('thoi_gian_den_kham', $ngay);
            });
        }

        if ($maBs = $request->query('ma_bs')) {
            $query->whereHas('lichKham', function ($q) use ($maBs) {
                $q->where('ma_bac_si', $maBs);
            });
        }

        return response()->json([
            'status' => 'success',
            'data'   => $query->orderBy('ma_phien_kham', 'desc')->paginate(20),
        ]);
    }

    /* ============================================================
       GET /api/phien-kham/by-lich/{maLich}
       ============================================================ */
    public function getByLichKham($maLich)
    {
        $lich = LichKham::with(['hoSo.benhNhan', 'bacSi.chuyenKhoa'])->find($maLich);

        if (!$lich) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy lịch khám',
            ], 404);
        }

        $phienKham = PhienKham::with([
            'chiDinh.dichVu',
            'donThuoc.chiTiet.thuoc',
            'hoaDon',
        ])->where('ma_lich_dat', $maLich)->first();

        // Nếu chưa có phiên khám → tạo mới + đổi trạng thái lịch thành 'dang_kham'
        if (!$phienKham) {
            $phienKham = PhienKham::create([
                'ma_lich_dat' => $maLich,
                'trang_thai'  => 'ChoCanLamSang',
            ]);
        }
        if ($lich->trang_thai !== 'hoan_thanh') {
            $lich->trang_thai = 'dang_kham';
            $lich->save();
        }

        return response()->json([
            'status' => 'success',
            'data'   => [
                'lich_kham'  => $lich,
                'phien_kham' => $phienKham->fresh()->load(['chiDinh.dichVu', 'donThuoc.chiTiet.thuoc']),
            ],
        ]);
    }

    /* ============================================================
       GET /api/phien-kham/{id}
       ============================================================ */
    public function show($id)
    {
        $pk = PhienKham::with([
            'lichKham.hoSo.benhNhan',
            'lichKham.bacSi.chuyenKhoa',
            'chiDinh.dichVu',
            'donThuoc.chiTiet.thuoc',
            'hoaDon',
        ])->find($id);

        if (!$pk) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy phiên khám',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $pk,
        ]);
    }

    /* ============================================================
       PUT /api/phien-kham/{id}
       Cập nhật chẩn đoán
       ============================================================ */
    public function update(Request $request, $id)
    {
        $pk = PhienKham::find($id);

        if (!$pk) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy phiên khám',
            ], 404);
        }

        $data = $request->validate([
            'chan_doan_so_bo'     => 'nullable|string|max:2000',
            'chan_doan_cuoi_cung' => 'nullable|string|max:2000',
            'ghi_chu_y_te'        => 'nullable|string|max:2000',
            'trang_thai'          => 'nullable|in:ChoCanLamSang,ChoKetLuan,ChoThanhToan,HoanThanh',
        ]);

        $pk->update($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Cập nhật chẩn đoán thành công',
            'data'    => $pk->fresh(),
        ]);
    }

    /* ============================================================
       POST /api/phien-kham/{id}/finish
       Hoàn thành phiên khám — Tính tiền & Tạo hóa đơn
       ============================================================ */
            public function finish($id)
    {
        $pk = PhienKham::with(['lichKham.hoSo.benhNhan', 'chiDinh.dichVu', 'donThuoc.chiTiet'])->find($id);
        if (!$pk) return response()->json(['status' => 'error', 'message' => 'Không tìm thấy phiên khám'], 404);
        if (in_array($pk->trang_thai, ['HoanThanh', 'ChoThanhToan'])) return response()->json(['status' => 'error', 'message' => 'Đã hoàn thành trước đó'], 400);

        try {
            $result = DB::transaction(function () use ($pk) {
                $pk->trang_thai = 'ChoThanhToan';
                $pk->save();

                $lich = $pk->lichKham;
                $hinhThuc = $lich->hinh_thuc_kham ?? 'DichVu';
                
                if ($lich) {
                    $lich->trang_thai = 'hoan_tat_hoa_don'; 
                    $lich->save();
                }

                // 1. Tính tiền dịch vụ & thuốc
                $tienDichVuGoc = 0;
                foreach ($pk->chiDinh as $cd) { if ($cd->dichVu) $tienDichVuGoc += (float) $cd->dichVu->don_gia; }
                
                $tienThuocGoc = 0;
                if ($pk->donThuoc) $tienThuocGoc = (float) $pk->donThuoc->tong_tien;

                // TỔNG CỘNG = Dịch vụ + Thuốc
                $tongCong = $tienDichVuGoc + $tienThuocGoc;

                // 2. Tính BHYT (nếu có)
                $tienBhytTra = 0;
                if ($hinhThuc === 'BHYT') {
                    $benhNhan = $lich->hoSo->benhNhan ?? null;
                    if ($benhNhan && $benhNhan->ma_bhyt && strlen($benhNhan->ma_bhyt) === 15) {
                        
                        $maDoiTuong = substr($benhNhan->ma_bhyt, 0, 2);
                        $kyTu3 = substr($benhNhan->ma_bhyt, 2, 1);
                        
                        // Tìm thông tin trong bảng danh mục
                        $loaiDoiTuong = \DB::table('LoaiDoiTuongBHYT')->where('ma_doi_tuong', $maDoiTuong)->first();
                        
                        // Nếu không tìm thấy, báo lỗi ngay, không tự đoán mức hưởng
                        if (!$loaiDoiTuong) {
                            throw new \Exception("Lỗi dữ liệu BHYT: Mã đối tượng '{$maDoiTuong}' không có trong danh mục quy định. Vui lòng kiểm tra lại thẻ BHYT của bệnh nhân.");
                        }

                        $mucHuong = $loaiDoiTuong->ty_le_huong;

                        // QUY TẮC ĐỒNG CHI TRẢ: Tổng tiền < 379.500đ thì BHYT trả 100%
                        if ($tongCong < 379500) {
                            $mucHuong = 100;
                        }

                        $tienBhytTra = $tongCong * ($mucHuong / 100);
                    }
                }

                // 3. Tính tiền bệnh nhân thực trả
                $tienBenhNhanTra = $tongCong - $tienBhytTra;
                
                \Log::info("Finish Exam PK#{$pk->ma_phien_kham} - DichVu: {$tienDichVuGoc}, Thuoc: {$tienThuocGoc}, Tong: {$tongCong}");
                // 4. LƯU HÓA ĐƠN
                return HoaDon::updateOrCreate(
                    ['ma_phien_kham' => $pk->ma_phien_kham],
                    [
                        'tien_kham_benh' => 0,
                        'tien_dich_vu'   => $tienDichVuGoc, 
                        'tien_thuoc'     => $tienThuocGoc,  
                        'tong_cong'      => $tongCong,
                        'tien_bhyt_tra'  => $tienBhytTra,
                        'tien_benh_nhan_tra' => $tienBenhNhanTra,
                        'trang_thai'     => 'ChuaThanhToan',
                        'ngay_tao'       => now(),
                    ]
                );
            });

            return response()->json(['status' => 'success', 'message' => 'Đã hoàn thành khám.', 'data' => $result]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error', 
                'message' => 'Lỗi lưu DB: ' . $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ], 500);
        }
    }

    /* ============================================================
       POST /api/phien-kham/{id}/chi-dinh
       ============================================================ */
    public function addChiDinh(Request $request, $id)
    {
        $data = $request->validate([
            'ma_dich_vu'       => 'required|integer|exists:DichVu,ma_dich_vu',
            'ket_qua_chi_tiet' => 'nullable|string',
        ]);

        $pk = PhienKham::find($id);

        if (!$pk) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy phiên khám',
            ], 404);
        }

        $chiDinh = \App\Models\ChiDinhDichVu::create([
            'ma_phien_kham'    => $id,
            'ma_dich_vu'       => $data['ma_dich_vu'],
            'ket_qua_chi_tiet' => $data['ket_qua_chi_tiet'] ?? null,
            'trang_thai'       => 'ChoThucHien',
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã thêm chỉ định',
            'data'    => $chiDinh->load('dichVu'),
        ], 201);
    }

    /* ============================================================
       DELETE /api/phien-kham/chi-dinh/{id}
       ============================================================ */
    public function removeChiDinh($id)
    {
        $cd = \App\Models\ChiDinhDichVu::find($id);

        if (!$cd) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy chỉ định',
            ], 404);
        }

        $cd->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã xóa chỉ định',
        ]);
    }
}