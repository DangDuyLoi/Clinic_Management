<?php

namespace App\Http\Controllers;

use App\Models\BacSi;
use App\Models\TaiKhoan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class BacSiController extends Controller
{
    /* ============================================================
       GET /api/bac-si
       Query: ?q=search&chuyen_khoa=1&trang_thai=1
       ============================================================ */
    public function index(Request $request)
    {
        $query = BacSi::with(['chuyenKhoa', 'taiKhoan']);

        // Tìm kiếm theo họ tên
        if ($q = $request->query('q')) {
            $query->where('ho_ten', 'like', "%{$q}%");
        }

        // Lọc theo chuyên khoa
        if ($maCK = $request->query('chuyen_khoa')) {
            $query->where('ma_chuyen_khoa', $maCK);
        }

        // Lọc theo trạng thái tài khoản
        if ($request->has('trang_thai')) {
            $trangThai = (bool) $request->query('trang_thai');
            $query->whereHas('taiKhoan', function ($q) use ($trangThai) {
                $q->where('trang_thai', $trangThai);
            });
        }

        $data = $query->orderBy('ho_ten')->get();

        return response()->json([
            'status' => 'success',
            'data'   => $data,
        ]);
    }

    /* ============================================================
       POST /api/bac-si
       Tạo tài khoản + hồ sơ bác sĩ trong 1 transaction
       Body: {
         ten_dang_nhap, mat_khau,
         ho_ten, ma_chuyen_khoa, trinh_do?,
         luot_kham_toi_da_moi_ca?
       }
       ============================================================ */
    public function store(Request $request)
    {
        $data = $request->validate([
            'ten_dang_nhap'          => 'required|string|min:3|max:50|unique:TaiKhoan,ten_dang_nhap',
            'mat_khau'               => 'required|string|min:6|max:255',
            'ho_ten'                 => 'required|string|min:2|max:100',
            'ma_chuyen_khoa'         => 'required|integer|exists:ChuyenKhoa,ma_chuyen_khoa',
            'trinh_do'               => 'nullable|string|max:100',
            'luot_kham_toi_da_moi_ca' => 'nullable|integer|min:1|max:100',
        ], [
            'ten_dang_nhap.required'  => 'Vui lòng nhập tên đăng nhập',
            'ten_dang_nhap.unique'    => 'Tên đăng nhập đã tồn tại',
            'mat_khau.required'       => 'Vui lòng nhập mật khẩu',
            'mat_khau.min'            => 'Mật khẩu phải có ít nhất 6 ký tự',
            'ho_ten.required'         => 'Vui lòng nhập họ tên bác sĩ',
            'ma_chuyen_khoa.required' => 'Vui lòng chọn chuyên khoa',
            'ma_chuyen_khoa.exists'   => 'Chuyên khoa không tồn tại',
            'luot_kham_toi_da_moi_ca.min' => 'Số lượt khám phải >= 1',
            'luot_kham_toi_da_moi_ca.max' => 'Số lượt khám không quá 100',
        ]);

        try {
            $bacSi = DB::transaction(function () use ($data) {
                // 1. Tạo tài khoản với vai_tro = BacSi
                $tk = TaiKhoan::create([
                    'ten_dang_nhap' => $data['ten_dang_nhap'],
                    'mat_khau'      => Hash::make($data['mat_khau']),
                    'vai_tro'       => 'BacSi',
                    'trang_thai'    => true,
                ]);

                // 2. Tạo hồ sơ bác sĩ liên kết với tài khoản
                return BacSi::create([
                    'ma_tk'                   => $tk->ma_tk,
                    'ma_chuyen_khoa'          => $data['ma_chuyen_khoa'],
                    'ho_ten'                  => $data['ho_ten'],
                    'trinh_do'                => $data['trinh_do'] ?? null,
                    'luot_kham_toi_da_moi_ca' => $data['luot_kham_toi_da_moi_ca'] ?? 20,
                ]);
            });

            return response()->json([
                'status'  => 'success',
                'message' => 'Tạo bác sĩ thành công',
                'data'    => $bacSi->load(['chuyenKhoa', 'taiKhoan']),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không thể tạo bác sĩ: ' . $e->getMessage(),
            ], 500);
        }
    }

    /* ============================================================
       GET /api/bac-si/{id}
       ============================================================ */
    public function show($id)
    {
        $bs = BacSi::with(['chuyenKhoa', 'taiKhoan', 'lichKham'])->find($id);

        if (!$bs) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy bác sĩ',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $bs,
        ]);
    }

    /* ============================================================
       PUT /api/bac-si/{id}
       Chỉ cập nhật hồ sơ bác sĩ — KHÔNG sửa tài khoản
       Body: { ho_ten?, ma_chuyen_khoa?, trinh_do?, luot_kham_toi_da_moi_ca? }
       ============================================================ */
    public function update(Request $request, $id)
    {
        $bs = BacSi::find($id);

        if (!$bs) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy bác sĩ',
            ], 404);
        }

        $data = $request->validate([
            'ho_ten'                  => 'sometimes|string|min:2|max:100',
            'ma_chuyen_khoa'          => 'sometimes|integer|exists:ChuyenKhoa,ma_chuyen_khoa',
            'trinh_do'                => 'nullable|string|max:100',
            'luot_kham_toi_da_moi_ca' => 'sometimes|integer|min:1|max:100',
        ], [
            'ho_ten.min'              => 'Họ tên phải có ít nhất 2 ký tự',
            'ma_chuyen_khoa.exists'   => 'Chuyên khoa không tồn tại',
            'luot_kham_toi_da_moi_ca.min' => 'Số lượt khám phải >= 1',
            'luot_kham_toi_da_moi_ca.max' => 'Số lượt khám không quá 100',
        ]);

        $bs->update($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Cập nhật thành công',
            'data'    => $bs->fresh()->load(['chuyenKhoa', 'taiKhoan']),
        ]);
    }

    /* ============================================================
       DELETE /api/bac-si/{id}
       Xóa hồ sơ bác sĩ + tài khoản liên quan (nếu có)
       Chặn xóa nếu bác sĩ còn lịch khám chưa hoàn thành
       ============================================================ */
    public function destroy($id)
    {
        $bs = BacSi::find($id);

        if (!$bs) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy bác sĩ',
            ], 404);
        }

        // Kiểm tra còn lịch khám chưa hoàn thành
        $soLichChuaXong = $bs->lichKham()
            ->whereNotIn('trang_thai', ['HoanThanh', 'DaHuy'])
            ->count();

        if ($soLichChuaXong > 0) {
            return response()->json([
                'status'  => 'error',
                'message' => "Không thể xóa. Bác sĩ còn {$soLichChuaXong} lịch khám chưa hoàn thành.",
            ], 400);
        }

        try {
            DB::transaction(function () use ($bs) {
                $maTk = $bs->ma_tk;

                // Xóa hồ sơ bác sĩ trước
                $bs->delete();

                // Xóa tài khoản liên quan (nếu có)
                if ($maTk) {
                    TaiKhoan::where('ma_tk', $maTk)->delete();
                }
            });

            return response()->json([
                'status'  => 'success',
                'message' => 'Đã xóa bác sĩ và tài khoản liên quan',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không thể xóa: ' . $e->getMessage(),
            ], 500);
        }
    }
}