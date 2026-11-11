<?php

namespace App\Http\Controllers;

use App\Models\BenhNhan;
use Illuminate\Http\Request;

class BenhNhanController extends Controller
{
    /* ============================================================
       GET /api/benh-nhan
       Query: ?q=search&gioi_tinh=Nam&per_page=20
       ============================================================ */
        public function index(Request $request)
    {
        $query = BenhNhan::with('hoSoBenhAn');

        if ($q = $request->query('q')) {
            $query->where(function ($sub) use ($q) {
                $sub->where('ho_ten', 'like', "%{$q}%")
                    ->orWhere('so_dien_thoai', 'like', "%{$q}%")
                    ->orWhere('cccd', 'like', "%{$q}%");
            });
        }

        if ($gt = $request->query('gioi_tinh')) {
            $gioiTinhSo = ($gt === 'Nam') ? 1 : (($gt === 'Nu') ? 0 : $gt);
            $query->where('gioi_tinh', $gioiTinhSo);
        }

        $perPage = (int) $request->query('per_page', 20);
        $data = $query->orderBy('ma_benh_nhan', 'desc')->paginate($perPage);

        // Format lại dữ liệu trước khi trả về cho Frontend
        $data->getCollection()->transform(function ($item) {
            return [
                'ma_benh_nhan' => $item->ma_benh_nhan, // Trả về đúng tên cột mới
                'ho_ten' => $item->ho_ten,
                'ngay_sinh' => $item->ngay_sinh,
                'gioi_tinh' => $item->gioi_tinh == 1 ? 'Nam' : ($item->gioi_tinh == 0 ? 'Nu' : 'Khac'),
                'so_dien_thoai' => $item->so_dien_thoai,
                'cccd' => $item->cccd,
                'dia_chi' => $item->dia_chi,
                'ma_bhyt' => $item->ma_bhyt,
            ];
        });

        return response()->json(['status' => 'success', 'data' => $data]);
    }

    /* ============================================================
       POST /api/benh-nhan
       Tạo bệnh nhân (có thể là khách vãng lai — ma_tk = null)
       Body: { ho_ten, ngay_sinh?, gioi_tinh?, so_dien_thoai, ... }
       ============================================================ */
    public function store(Request $request)
    {
        $data = $request->validate([
            'ho_ten'                 => 'required|string|min:2|max:100',
            'ngay_sinh'              => 'required|date|before:today',
            'gioi_tinh'              => 'nullable|in:Nam,Nu,Khac,1,0',
            'so_dien_thoai'          => ['required', 'string', 'max:15', 'unique:BenhNhan,so_dien_thoai', new \App\Rules\ValidVNPhone()],
            'email'                  => 'nullable|email|max:100',
            'cccd'                   => ['nullable', 'string', 'unique:BenhNhan,cccd', new \App\Rules\ValidCccd($request->ngay_sinh, $request->gioi_tinh)],
            'dia_chi'                => 'nullable|string|max:255',
            'que_quan'               => 'nullable|string|max:100',
            'nguoi_lien_he_khan_cap' => 'nullable|string|max:100',
            'tien_su_benh'           => 'nullable|string',
            'di_ung'                 => 'nullable|string',
            'nhom_mau'               => 'nullable|string|max:5',
            'ma_tk'                  => 'nullable|integer|exists:TaiKhoan,ma_tk',
            'ma_bhyt' => ['nullable', 'string','unique:BenhNhan,ma_bhyt', new \App\Rules\ValidBhyt($request->input('ngay_sinh'))],
        ], [
            'ho_ten.required'        => 'Vui lòng nhập họ tên',
            'ngay_sinh.required' => 'Vui lòng nhập ngày sinh',
            'so_dien_thoai.required' => 'Vui lòng nhập số điện thoại',
            'so_dien_thoai.unique'   => 'Số điện thoại đã tồn tại',
            'cccd.unique'            => 'CCCD đã tồn tại',
            'ma_bhyt.unique'         => 'Mã thẻ BHYT này đã được sử dụng bởi một bệnh nhân khác.',
            'ngay_sinh.date' => 'Ngày sinh không hợp lệ',
        ]);
        if (isset($data['gioi_tinh'])) {
            if ($data['gioi_tinh'] === 'Nam' || $data['gioi_tinh'] === '1') $data['gioi_tinh'] = 1;
            elseif ($data['gioi_tinh'] === 'Nu' || $data['gioi_tinh'] === '0') $data['gioi_tinh'] = 0;
            elseif ($data['gioi_tinh'] === 'Khac') $data['gioi_tinh'] = 1; // Mặc định Khác = 1
        } else {
            $data['gioi_tinh'] = 1; // Mặc định
        }

        $bn->update($data);
        
        \App\Models\HoSoBenhAn::create([
            'ma_benh_nhan' => $bn->ma_benh_nhan,
            'tien_su_benh' => $data['tien_su_benh'] ?? $hoSo->tien_su_benh,
            'nhom_mau'     => $data['nhom_mau'] ?? $hoSo->nhom_mau,
            'ma_bhyt'      => $data['ma_bhyt'] ?? $hoSo->ma_bhyt,
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Tạo hồ sơ bệnh nhân thành công',
            'data'    => $bn->fresh(),
        ], 201);
    }

    /* ============================================================
       GET /api/benh-nhan/{id}
       ============================================================ */
    public function show($id)
    {
        $bn = BenhNhan::with(['taiKhoan','hoSoBenhAn', 'lichKham' => function ($q) {
            $q->orderBy('thoi_gian_den_kham', 'desc')->limit(10);
        }, 'lichKham.bacSi'])->find($id);

        if (!$bn) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy bệnh nhân',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $bn,
        ]);
    }

    /* ============================================================
       PUT /api/benh-nhan/{id}
       ============================================================ */
    public function update(Request $request, $id)
    {
        $bn = BenhNhan::find($id);

        if (!$bn) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy bệnh nhân',
            ], 404);
        }

        $data = $request->validate([
            'ho_ten'                 => 'sometimes|string|min:2|max:100',
            'ngay_sinh'              => 'required|date|before:today',
            'gioi_tinh'              => 'nullable|in:Nam,Nu,Khac,1,0',
            'so_dien_thoai'          => ['required', 'string', 'max:15', 'unique:BenhNhan,so_dien_thoai,' . $id . ',ma_benh_nhan', new \App\Rules\ValidVNPhone()],
            'email'                  => 'nullable|email|max:100',
            'cccd'                   => ['nullable', 'string', 'max:20', 'unique:BenhNhan,cccd,' . $id . ',ma_benh_nhan', new \App\Rules\ValidCccd($request->ngay_sinh, $request->gioi_tinh)],
            'dia_chi'                => 'nullable|string|max:255',
            'que_quan'               => 'nullable|string|max:100',
            'nguoi_lien_he_khan_cap' => 'nullable|string|max:100',
            'tien_su_benh'           => 'nullable|string',
            'di_ung'                 => 'nullable|string',
            'nhom_mau'               => 'nullable|string|max:5',
            'ma_bhyt'                => ['nullable', 'string', 'unique:BenhNhan,ma_bhyt,' . $id . ',ma_benh_nhan',new \App\Rules\ValidBhyt($request->input('ngay_sinh'))],
        ], [
            'ngay_sinh.required' => 'Vui lòng nhập ngày sinh',
            'ngay_sinh.date' => 'Ngày sinh không hợp lệ',
            'so_dien_thoai.unique' => 'Số điện thoại đã tồn tại',
            'cccd.unique'          => 'CCCD đã tồn tại',
            'ma_bhyt.unique' => 'Mã thẻ BHYT này đã được sử dụng bởi một bệnh nhân khác.',
        ]);
        if (isset($data['gioi_tinh'])) {
            if ($data['gioi_tinh'] === 'Nam' || $data['gioi_tinh'] === '1') $data['gioi_tinh'] = 1;
            elseif ($data['gioi_tinh'] === 'Nu' || $data['gioi_tinh'] === '0') $data['gioi_tinh'] = 0;
            elseif ($data['gioi_tinh'] === 'Khac') $data['gioi_tinh'] = 1;
        }

        $bn->update($data);

        $hoSo = \App\Models\HoSoBenhAn::where('ma_benh_nhan', $id)->first();
        if ($hoSo) {
            $hoSo->update([
                'tien_su_benh' => $data['tien_su_benh'] ?? $hoSo->tien_su_benh,
                'nhom_mau'     => $data['nhom_mau'] ?? $hoSo->nhom_mau,
                'ma_bhyt'      => $data['ma_bhyt'] ?? $hoSo->ma_bhyt,
            ]);
        }

        return response()->json([
            'status'  => 'success',
            'message' => 'Cập nhật thành công',
            'data'    => $bn->fresh(),
        ]);
    }

    /* ============================================================
       DELETE /api/benh-nhan/{id}
       ============================================================ */
    public function destroy($id)
    {
        $bn = BenhNhan::find($id);

        if (!$bn) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy bệnh nhân',
            ], 404);
        }

        // Chặn xóa nếu còn lịch khám chưa hoàn thành
        $soLichChuaXong = $bn->lichKham()
            ->whereNotIn('trang_thai', ['HoanThanh', 'DaHuy'])
            ->count();

        if ($soLichChuaXong > 0) {
            return response()->json([
                'status'  => 'error',
                'message' => "Không thể xóa. Bệnh nhân còn {$soLichChuaXong} lịch khám chưa hoàn thành.",
            ], 400);
        }

        $bn->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã xóa bệnh nhân',
        ]);
    }
        /**
     * GET /api/benh-nhan/{id}/lich-su-kham
     * Lịch sử khám của bệnh nhân (tất cả phiên khám đã hoàn thành)
     */
        public function lichSuKham($id)
    {
        $benhNhan = BenhNhan::find($id);
        if (!$benhNhan) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy bệnh nhân'], 404);
        }

        // Tìm hồ sơ bệnh án tương ứng
        $hoSo = \App\Models\HoSoBenhAn::where('ma_benh_nhan', $id)->first();
        
        if (!$hoSo) {
            return response()->json([
                'status' => 'success',
                'data' => ['benh_nhan' => $benhNhan, 'tong_lan_kham' => 0, 'lich_su' => []]
            ]);
        }

        // Lấy tất cả phiên khám của bệnh nhân thông qua ma_ho_so
        $lichSu = \App\Models\PhienKham::with([
                'lichKham.bacSi.chuyenKhoa',
                'chiDinh.dichVu',
                'donThuoc.chiTiet.thuoc',
                'hoaDon',
            ])
            ->whereHas('lichKham', function ($q) use ($hoSo) {
                $q->where('ma_ho_so', $hoSo->ma_ho_so);
            })
            ->orderBy('ma_phien_kham', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data'   => [
                'benh_nhan' => [
                    'ma_benh_nhan'  => $benhNhan->ma_benh_nhan,
                    'ho_ten'        => $benhNhan->ho_ten,
                    'ngay_sinh'     => $benhNhan->ngay_sinh,
                    'gioi_tinh'     => $benhNhan->gioi_tinh,
                    'so_dien_thoai' => $benhNhan->so_dien_thoai,
                ],
                'tong_lan_kham' => $lichSu->count(),
                'lich_su'       => $lichSu,
            ],
        ]);
    }

    /**
     * GET /api/benh-nhan/{id}/thong-ke
     * Thống kê nhanh về bệnh nhân
     */
    public function thongKe($id)
    {
        $benhNhan = BenhNhan::find($id);
        if (!$benhNhan) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy bệnh nhân',
            ], 404);
        }

        $lichKham = \App\Models\LichKham::where('ma_bn', $id);

        $tongLanKham      = (clone $lichKham)->where('trang_thai', 'HoanThanh')->count();
        $tongLanHuy       = (clone $lichKham)->where('trang_thai', 'DaHuy')->count();
        $lanKhamGanNhat   = (clone $lichKham)->where('trang_thai', 'HoanThanh')
                                ->orderBy('thoi_gian_den_kham', 'desc')->first();
        $lanKhamSapToi    = (clone $lichKham)->whereIn('trang_thai', ['ChoXacNhan', 'ChoKham'])
                                ->where('thoi_gian_den_kham', '>=', now()->toDateString())
                                ->orderBy('thoi_gian_den_kham')->first();

        // Tổng tiền đã thanh toán
        $tongTien = \App\Models\HoaDon::whereHas('phienKham.lichKham', function ($q) use ($id) {
                $q->where('ma_bn', $id);
            })
            ->where('trang_thai', 'DaThanhToan')
            ->sum('tong_cong');

        return response()->json([
            'status' => 'success',
            'data'   => [
                'tong_lan_kham'    => $tongLanKham,
                'tong_lan_huy'     => $tongLanHuy,
                'tong_tien'        => (float) $tongTien,
                'lan_kham_gan_nhat'=> $lanKhamGanNhat ? [
                    'thoi_gian_den_kham' => $lanKhamGanNhat->thoi_gian_den_kham,
                    'chan_doan' => $lanKhamGanNhat->phienKham?->chan_doan_cuoi_cung,
                ] : null,
                'lan_kham_sap_toi' => $lanKhamSapToi ? [
                    'ma_lich_dat' => $lanKhamSapToi->ma_lich_dat,
                    'thoi_gian_den_kham'   => $lanKhamSapToi->thoi_gian_den_kham,
                    'trang_thai'  => $lanKhamSapToi->trang_thai,
                ] : null,
            ],
        ]);
    }
        public function getTinhThanh()
    {
        $data = \Illuminate\Support\Facades\DB::table('TinhThanh')->orderBy('ten_tinh')->get();
        return response()->json(['status' => 'success', 'data' => $data]);
    }
}   