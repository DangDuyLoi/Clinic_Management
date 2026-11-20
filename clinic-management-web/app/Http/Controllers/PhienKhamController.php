<?php

namespace App\Http\Controllers;

use App\Models\ChiDinhDichVu;
use App\Models\HoaDon;
use App\Models\LichKham;
use App\Models\PhienKham;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

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
            'data' => $query->orderBy('ma_phien_kham', 'desc')->paginate(20),
        ]);
    }

    /* ============================================================
       GET /api/phien-kham/by-lich/{maLich}
       ============================================================ */
    public function getByLichKham($maLich)
    {
        $lich = LichKham::with(['hoSo.benhNhan', 'bacSi.chuyenKhoa'])->find($maLich);

        if (! $lich) {
            return response()->json([
                'status' => 'error',
                'message' => 'Không tìm thấy lịch khám',
            ], 404);
        }

        $phienKham = PhienKham::with([
            'chiDinh.dichVu',
            'donThuoc.chiTiet.thuoc',
            'hoaDon',
        ])->where('ma_lich_dat', $maLich)->first();

        // Nếu chưa có phiên khám → tạo mới + đổi trạng thái lịch thành 'dang_kham'
        if (! $phienKham) {
            $phienKham = PhienKham::create([
                'ma_lich_dat' => $maLich,
                'phong_kham' => $lich->bacSi?->chuyenKhoa?->phong_kham,
                'trang_thai' => 'ChoCanLamSang',
            ]);
        }
        if ($lich->trang_thai !== 'hoan_thanh') {
            $lich->trang_thai = 'dang_kham';
            $lich->save();
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'lich_kham' => $lich,
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

        if (! $pk) {
            return response()->json([
                'status' => 'error',
                'message' => 'Không tìm thấy phiên khám',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $pk,
        ]);
    }

    /* ============================================================
       PUT /api/phien-kham/{id}
       Cập nhật chẩn đoán
       ============================================================ */
    public function update(Request $request, $id)
    {
        $pk = PhienKham::find($id);

        if (! $pk) {
            return response()->json([
                'status' => 'error',
                'message' => 'Không tìm thấy phiên khám',
            ], 404);
        }

        $data = $request->validate([
            'chan_doan_so_bo' => 'nullable|string|max:2000',
            'chan_doan_cuoi_cung' => 'nullable|string|max:2000',
            'ghi_chu_y_te' => 'nullable|string|max:2000',
            'trang_thai' => 'nullable|in:ChoCanLamSang,ChoKetLuan,ChoThanhToan,HoanThanh',
        ]);

        $pk->update($data);

        return response()->json([
            'status' => 'success',
            'message' => 'Cập nhật chẩn đoán thành công',
            'data' => $pk->fresh(),
        ]);
    }

    /* ============================================================
       POST /api/phien-kham/{id}/finish
       Hoàn thành phiên khám — Tính tiền & Tạo hóa đơn
       ============================================================ */
    public function finish($id)
    {
        $pk = PhienKham::with(['lichKham.hoSo.benhNhan', 'chiDinh.dichVu', 'donThuoc.chiTiet.thuoc'])->find($id);
        if (! $pk) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy phiên khám'], 404);
        }
        if (in_array($pk->trang_thai, ['HoanThanh', 'ChoThanhToan'])) {
            return response()->json(['status' => 'error', 'message' => 'Đã hoàn thành trước đó'], 400);
        }

        try {
            $result = DB::transaction(function () use ($pk) {
                $pk->trang_thai = 'ChoThanhToan';
                $pk->save();

                $lich = $pk->lichKham;
                $hinhThuc = $lich->hinh_thuc_kham ?? 'DichVu';
                $daThanhToanPhiKhamTruoc = $lich && in_array($lich->trang_thai, [
                    'da_thanh_toan',
                    'cho_kham',
                    'dang_kham',
                    'hoan_thanh',
                ], true);

                if ($lich) {
                    $lich->trang_thai = 'hoan_tat_hoa_don';
                    $lich->save();
                }
                // 1. Lấy tiền khám cơ bản
                $tienKhamBenh = (float) ($lich->so_tien ?? 0);
                // Nếu so_tien null (lịch cũ), fallback về giá của chuyên khoa
                if ($tienKhamBenh == 0 && $lich->bacSi && $lich->bacSi->chuyenKhoa) {
                    $tienKhamBenh = (float) $lich->bacSi->chuyenKhoa->gia_kham;
                }

                // 2. Tính tiền dịch vụ & thuốc
                $tienDichVuGoc = 0;
                foreach ($pk->chiDinh as $cd) {
                    if ($cd->dichVu) {
                        $tienDichVuGoc += (float) $cd->dichVu->don_gia;
                    }
                }

                $tienThuocGoc = 0;
                $tienThuocBhyt = 0;
                if ($pk->donThuoc) {
                    foreach ($pk->donThuoc->chiTiet as $chiTiet) {
                        $thanhTien = (float) $chiTiet->thanh_tien;
                        $tienThuocGoc += $thanhTien;

                        if ($chiTiet->thuoc?->is_bhyt) {
                            $tienThuocBhyt += $thanhTien;
                        }
                    }
                }
                // TỔNG CỘNG GỐC = Tiền khám + Dịch vụ + Thuốc
                $tongCongGoc = $tienKhamBenh + $tienDichVuGoc + $tienThuocGoc;

                // 3. Tính BHYT (nếu có)
                $tienBhytTra = 0;
                if ($hinhThuc === 'BHYT') {
                    $benhNhan = $lich->hoSo->benhNhan ?? null;
                    if ($benhNhan && $benhNhan->ma_bhyt && strlen($benhNhan->ma_bhyt) === 15) {
                        $maDoiTuong = substr($benhNhan->ma_bhyt, 0, 2);
                        $loaiDoiTuong = \DB::table('loaidoituongbhyt')->where('ma_doi_tuong', $maDoiTuong)->first();

                        if (! $loaiDoiTuong) {
                            throw new \Exception("Lỗi dữ liệu BHYT: Mã đối tượng '{$maDoiTuong}' không có trong danh mục.");
                        }

                        $mucHuong = $loaiDoiTuong->ty_le_huong;
                        if ($tongCongGoc < 379500) {
                            $mucHuong = 100;
                        }
                        $tienBhytTra = $tienThuocBhyt
                            + ($tienKhamBenh + $tienDichVuGoc) * ($mucHuong / 100);
                    }
                }

                // 4. Tính tiền bệnh nhân THỰC TẾ phải trả cho toàn bộ hóa đơn
                $tongTienBenhNhanPhaiTra = $tongCongGoc - $tienBhytTra;

                // 5. TRỪ ĐI SỐ TIỀN ĐÃ THANH TOÁN TRƯỚC ĐÓ (Lúc đặt lịch)
                $daThanhToanTruoc = 0;
                if ($daThanhToanPhiKhamTruoc) {
                    $daThanhToanTruoc = (float) ($lich->so_tien ?? $tienKhamBenh);
                }

                $conLaiPhaiTra = max(0, $tongTienBenhNhanPhaiTra - $daThanhToanTruoc);

                \Log::info("Finish PK#{$pk->ma_phien_kham} - Kham: {$tienKhamBenh}, DichVu: {$tienDichVuGoc}, Thuoc: {$tienThuocGoc}, DaThu: {$daThanhToanTruoc}, ConLai: {$conLaiPhaiTra}");

                // 6. LƯU HÓA ĐƠN
                $hoaDon = HoaDon::updateOrCreate(
                    ['ma_phien_kham' => $pk->ma_phien_kham],
                    [
                        'tien_kham_benh' => $tienKhamBenh, // Lưu lại để hiển thị hóa đơn
                        'tien_dich_vu' => $tienDichVuGoc,
                        'tien_thuoc' => $tienThuocGoc,
                        'tong_cong' => $tongCongGoc,
                        'tien_bhyt_tra' => $tienBhytTra,
                        'tien_benh_nhan_tra' => $conLaiPhaiTra, // Số tiền thực tế còn nợ
                        'trang_thai' => $conLaiPhaiTra == 0 ? 'DaThanhToan' : 'ChuaThanhToan', // Nếu cấn trừ hết thì auto Đã thanh toán
                        'ngay_tao' => now(),
                        'ngay_thanh_toan' => $conLaiPhaiTra == 0 ? now() : null,
                    ]
                );

                if ($conLaiPhaiTra == 0) {
                    $pk->trang_thai = 'HoanThanh';
                    $pk->save();

                    if ($lich) {
                        $lich->trang_thai = 'hoan_thanh';
                        $lich->save();
                    }
                }

                return $hoaDon;
            });

            return response()->json(['status' => 'success', 'message' => 'Đã hoàn thành khám.', 'data' => $result]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Lỗi lưu DB: '.$e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ], 500);
        }
    }

    /* ============================================================
       POST /api/phien-kham/{id}/chi-dinh
       ============================================================ */
    public function addChiDinh(Request $request, $id)
    {
        $data = $request->validate([
            'ma_dich_vu' => 'required|integer|exists:DichVu,ma_dich_vu',
            'ket_qua_chi_tiet' => 'nullable|string',
        ]);

        $pk = PhienKham::find($id);

        if (! $pk) {
            return response()->json([
                'status' => 'error',
                'message' => 'Không tìm thấy phiên khám',
            ], 404);
        }

        $chiDinh = ChiDinhDichVu::create([
            'ma_phien_kham' => $id,
            'ma_dich_vu' => $data['ma_dich_vu'],
            'ket_qua_chi_tiet' => $data['ket_qua_chi_tiet'] ?? null,
            'trang_thai' => 'ChoThucHien',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Đã thêm chỉ định',
            'data' => $chiDinh->load('dichVu'),
        ], 201);
    }

    /* ============================================================
       DELETE /api/phien-kham/chi-dinh/{id}
       ============================================================ */
    public function removeChiDinh($id)
    {
        $cd = ChiDinhDichVu::find($id);

        if (! $cd) {
            return response()->json([
                'status' => 'error',
                'message' => 'Không tìm thấy chỉ định',
            ], 404);
        }

        $cd->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Đã xóa chỉ định',
        ]);
    }
}
