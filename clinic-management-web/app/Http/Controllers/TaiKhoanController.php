<?php

namespace App\Http\Controllers;

use App\Models\TaiKhoan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class TaiKhoanController extends Controller
{
    /* ============================================================
       GET /api/admin/users
       Query: ?q=search&vai_tro=QuanTri&trang_thai=1&per_page=15
       ============================================================ */
    public function index(Request $request)
    {
        $query = TaiKhoan::query();

        // Tìm kiếm theo tên đăng nhập
        if ($q = $request->query('q')) {
            $query->where('ten_dang_nhap', 'like', "%{$q}%");
        }

        // Lọc theo vai trò
        if ($vaiTro = $request->query('vai_tro')) {
            $query->where('vai_tro', $vaiTro);
        }

        // Lọc theo trạng thái
        if ($request->has('trang_thai')) {
            $query->where('trang_thai', (bool) $request->query('trang_thai'));
        }

        // Phân trang
        $perPage = (int) $request->query('per_page', 15);
        $perPage = max(1, min($perPage, 100)); // Giới hạn 1-100

        $users = $query->orderBy('ma_tk', 'desc')->paginate($perPage);

        return response()->json([
            'status' => 'success',
            'data'   => $users,
        ]);
    }

    /* ============================================================
       POST /api/admin/users
       Body: { ten_dang_nhap, mat_khau, vai_tro }
       ============================================================ */
    public function store(Request $request)
    {
        $data = $request->validate([
            'ten_dang_nhap' => 'required|string|min:3|max:50|unique:TaiKhoan,ten_dang_nhap',
            'mat_khau'      => 'required|string|min:6|max:255',
            'vai_tro'       => 'required|in:QuanTri,BacSi,LeTan,BenhNhan',
        ], [
            'ten_dang_nhap.required' => 'Vui lòng nhập tên đăng nhập',
            'ten_dang_nhap.unique'   => 'Tên đăng nhập đã tồn tại',
            'mat_khau.required'      => 'Vui lòng nhập mật khẩu',
            'mat_khau.min'           => 'Mật khẩu phải có ít nhất 6 ký tự',
            'vai_tro.required'       => 'Vui lòng chọn vai trò',
            'vai_tro.in'             => 'Vai trò không hợp lệ',
        ]);

        $tk = TaiKhoan::create([
            'ten_dang_nhap' => $data['ten_dang_nhap'],
            'mat_khau'      => Hash::make($data['mat_khau']),
            'vai_tro'       => $data['vai_tro'],
            'trang_thai'    => true,
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Tạo tài khoản thành công',
            'data'    => $tk,
        ], 201);
    }

    /* ============================================================
       GET /api/admin/users/{id}
       ============================================================ */
    public function show($id)
    {
        $tk = TaiKhoan::with(['bacSi', 'benhNhan'])->find($id);

        if (!$tk) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy tài khoản',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $tk,
        ]);
    }

    /* ============================================================
       PUT /api/admin/users/{id}
       Body: { ten_dang_nhap?, mat_khau?, vai_tro?, trang_thai? }
       ============================================================ */
    public function update(Request $request, $id)
    {
        $tk = TaiKhoan::find($id);

        if (!$tk) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy tài khoản',
            ], 404);
        }

        $data = $request->validate([
            'ten_dang_nhap' => [
                'sometimes', 'string', 'min:3', 'max:50',
                Rule::unique('TaiKhoan', 'ten_dang_nhap')->ignore($id, 'ma_tk'),
            ],
            'mat_khau'   => 'sometimes|string|min:6|max:255',
            'vai_tro'    => 'sometimes|in:QuanTri,BacSi,LeTan,BenhNhan',
            'trang_thai' => 'sometimes|boolean',
        ], [
            'ten_dang_nhap.unique' => 'Tên đăng nhập đã tồn tại',
            'mat_khau.min'         => 'Mật khẩu phải có ít nhất 6 ký tự',
            'vai_tro.in'           => 'Vai trò không hợp lệ',
        ]);

        // Nếu đổi mật khẩu → hash
        if (isset($data['mat_khau'])) {
            $data['mat_khau'] = Hash::make($data['mat_khau']);
        }

        $tk->update($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Cập nhật thành công',
            'data'    => $tk->fresh(),
        ]);
    }

    /* ============================================================
       DELETE /api/admin/users/{id}
       ============================================================ */
    public function destroy($id)
    {
        $tk = TaiKhoan::find($id);

        if (!$tk) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy tài khoản',
            ], 404);
        }

        // Chặn xóa tài khoản Quản trị viên
        if ($tk->vai_tro === 'QuanTri') {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không thể xóa tài khoản Quản trị viên',
            ], 403);
        }

        // Chặn tự xóa chính mình
        $currentUser = auth('api')->user();
        if ($currentUser && $currentUser->ma_tk === $tk->ma_tk) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không thể xóa tài khoản đang đăng nhập',
            ], 403);
        }

        $tk->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã xóa tài khoản',
        ]);
    }

    /* ============================================================
       PUT /api/admin/users/{id}/lock
       Body: { trang_thai: true|false }
       ============================================================ */
    public function toggleLock(Request $request, $id)
    {
        $request->validate([
            'trang_thai' => 'required|boolean',
        ], [
            'trang_thai.required' => 'Vui lòng cung cấp trạng thái',
        ]);

        $tk = TaiKhoan::find($id);

        if (!$tk) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy tài khoản',
            ], 404);
        }

        // Không cho tự khóa chính mình
        $currentUser = auth('api')->user();
        if ($currentUser && $currentUser->ma_tk === $tk->ma_tk) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không thể tự khóa tài khoản của mình',
            ], 403);
        }

        $tk->trang_thai = $request->trang_thai;
        $tk->save();

        return response()->json([
            'status'  => 'success',
            'message' => $request->trang_thai
                ? 'Đã mở khóa tài khoản'
                : 'Đã khóa tài khoản',
            'data'    => $tk,
        ]);
    }
}