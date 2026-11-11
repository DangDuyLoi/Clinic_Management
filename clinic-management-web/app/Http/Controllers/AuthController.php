<?php

namespace App\Http\Controllers;

use App\Models\TaiKhoan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Tymon\JWTAuth\Exceptions\JWTException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'ten_dang_nhap' => 'required|string',
            'password'      => 'required|string',
        ]);

        $credentials = [
            'ten_dang_nhap' => $request->ten_dang_nhap,
            'password'      => $request->password, // JWT sẽ dùng getAuthPassword() để map vào cột mat_khau
        ];

        try {
            if (!$token = auth('api')->attempt($credentials)) {
                return response()->json(['status' => 'error', 'message' => 'Tên đăng nhập hoặc mật khẩu không đúng'], 401);
            }
        } catch (JWTException $e) {
            return response()->json(['status' => 'error', 'message' => 'Không thể tạo token: ' . $e->getMessage()], 500);
        }

        $user = auth('api')->user();
        if (!$user->trang_thai) {
            auth('api')->logout();
            return response()->json(['status' => 'error', 'message' => 'Tài khoản đã bị khóa'], 403);
        }

        return $this->respondWithToken($token, 'Đăng nhập thành công');
    }

    public function register(Request $request)
    {
        $request->validate([
            'ten_dang_nhap' => 'required|string|unique:TaiKhoan,ten_dang_nhap',
            'password'      => 'required|string|min:6',
            'ho_ten'        => 'required|string',
            'phone_number'  => 'required|string'
        ]);

        $tk = TaiKhoan::create([
            'ten_dang_nhap' => $request->ten_dang_nhap,
            'mat_khau'      => Hash::make($request->password),
            'vai_tro'       => 'BenhNhan',
            'trang_thai'    => true,
        ]);

        \App\Models\BenhNhan::create([
            'ma_tk' => $tk->ma_tk,
            'ho_ten' => $request->ho_ten,
            'so_dien_thoai' => $request->phone_number,
            'gioi_tinh' => 1,
            'ngay_sinh' => '1990-01-01'
        ]);

        return response()->json(['message' => 'Đăng ký thành công', 'user' => $tk], 200);
    }

    public function logout()
    {
        auth('api')->logout();
        return response()->json(['status' => 'success', 'message' => 'Đăng xuất thành công']);
    }

    public function me()
    {
        return response()->json(['status' => 'success', 'data' => $this->formatUser(auth('api')->user())]);
    }

    public function refresh()
    {
        try {
            return $this->respondWithToken(auth('api')->refresh(), 'Token đã được làm mới');
        } catch (JWTException $e) {
            return response()->json(['status' => 'error', 'message' => 'Không thể refresh token'], 401);
        }
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'mat_khau_cu' => 'required|string',
            'mat_khau_moi' => 'required|string|min:6|confirmed',
        ]);

        $user = auth('api')->user();

        if (!Hash::check($request->mat_khau_cu, $user->mat_khau)) {
            return response()->json(['status' => 'error', 'message' => 'Mật khẩu cũ không đúng'], 400);
        }

        $user->mat_khau = Hash::make($request->mat_khau_moi);
        $user->save();

        return response()->json(['status' => 'success', 'message' => 'Đổi mật khẩu thành công']);
    }

    private function respondWithToken(string $token, string $message): \Illuminate\Http\JsonResponse
    {
        return response()->json([
            'status'       => 'success',
            'message'      => $message,
            'token'        => $token,
            'data'    => [
                'token'      => $token,
                'token_type' => 'bearer',
                'expires_in' => auth('api')->factory()->getTTL() * 60,
                'user'       => $this->formatUser(auth('api')->user()),
            ],
        ]);
    }

    private function formatUser($user): array
    {
        return [
            'ma_tk'         => $user->ma_tk,
            'ten_dang_nhap' => $user->ten_dang_nhap,
            'vai_tro'       => $user->vai_tro,
            'trang_thai'    => (bool) $user->trang_thai,
            'ho_ten'        => $user->ho_ten ?? $user->bacSi?->ho_ten ?? $user->benhNhan?->ho_ten ?? $user->ten_dang_nhap,
        ];
    }
}