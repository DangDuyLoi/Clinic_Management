<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\SendOtpRequest;
use App\Http\Requests\Auth\SetPasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class AuthController extends Controller
{
    public function sendOtp(SendOtpRequest $request)
    {
        $phoneNumber = $request->phone_number;
        // Generate a 6 digit random OTP
        $otp = rand(100000, 999999);
        
        // Save to cache for 5 minutes
        Cache::put('otp_' . $phoneNumber, $otp, now()->addMinutes(5));
        
        // Mock sending SMS
        Log::info("Mock SMS sent to {$phoneNumber} with OTP: {$otp}");

        return response()->json([
            'message' => 'OTP sent successfully',
            // In a real app we wouldn't return the OTP, but for dev it can be helpful if we want
            // 'otp' => $otp
        ], 200);
    }

    public function verifyOtp(Request $request)
    {
        $request->validate([
            'phone_number' => 'required|string',
            'otp' => 'required|string|size:6'
        ]);

        $phoneNumber = $request->phone_number;
        $otp = $request->otp;

        $cachedOtp = Cache::get('otp_' . $phoneNumber);

        if (!$cachedOtp || $cachedOtp != $otp) {
            return response()->json(['message' => 'Invalid or expired OTP'], 400);
        }

        // OTP is valid. The client can now proceed to the next step.
        return response()->json(['message' => 'OTP verified successfully'], 200);
    }

    public function setPassword(SetPasswordRequest $request)
    {
        $phoneNumber = $request->phone_number;

        // Firebase has already verified the OTP on the frontend.
        // In a production environment, you should verify the Firebase ID Token here instead.

        // Create the user
        $user = clone new User;
        $user->phone_number = $phoneNumber;
        $user->name = 'User ' . substr($phoneNumber, -4); // Default name
        $user->password = Hash::make($request->password);
        $user->save();

        // Generate Sanctum token
        $token = $user->createToken('mobile_app_token')->plainTextToken;

        return response()->json([
            'message' => 'User registered successfully',
            'user' => $user,
            'token' => $token
        ], 201);
    }

    public function login(LoginRequest $request)
    {
        $rawPhone = trim($request->phone_number);
        Log::info("Login attempt received for: [{$rawPhone}]");

        // Chuẩn hóa số điện thoại: hỗ trợ cả 0xxx, +84xxx, 84xxx
        $phone0 = str_starts_with($rawPhone, '+84') ? '0' . substr($rawPhone, 3) 
            : (str_starts_with($rawPhone, '84') ? '0' . substr($rawPhone, 2) : $rawPhone);
        $phone84 = str_starts_with($rawPhone, '0') ? '+84' . substr($rawPhone, 1) : $rawPhone;
        $phoneClean = str_starts_with($phone84, '+') ? substr($phone84, 1) : $phone84;

        $user = User::whereIn('phone_number', [$rawPhone, $phone0, $phone84, $phoneClean])
            ->orWhere('email', $rawPhone)
            ->first();

        // 1. Hỗ trợ nếu số điện thoại thuộc về bệnh nhân trong bảng benh_nhan
        if (!$user) {
            $bn = DB::table('benh_nhan')
                ->whereIn('so_dien_thoai', [$rawPhone, $phone0, $phone84, $phoneClean])
                ->first();
            if ($bn) {
                $user = User::firstOrCreate(
                    ['phone_number' => $rawPhone],
                    ['name' => $bn->ho_ten, 'password' => Hash::make($request->password)]
                );
            }
        }

        // 2. Hỗ trợ đăng nhập bằng tài khoản TaiKhoan (admin, bác sĩ, bệnh nhân...)
        if (!$user) {
            $taiKhoan = DB::table('TaiKhoan')->where('ten_dang_nhap', $rawPhone)->first();
            if ($taiKhoan && (Hash::check($request->password, $taiKhoan->mat_khau) || $taiKhoan->mat_khau === $request->password || $request->password === '123456')) {
                $user = User::firstOrCreate(
                    ['phone_number' => $rawPhone],
                    ['name' => $taiKhoan->ten_dang_nhap, 'password' => Hash::make($request->password)]
                );
            }
        }

        // Kiểm tra mật khẩu (hỗ trợ cả mật khẩu đã băm và mật khẩu dự phòng 123456 cho môi trường đồ án)
        $isPasswordValid = false;
        if ($user) {
            if (Hash::check($request->password, $user->password) || $request->password === '123456') {
                $isPasswordValid = true;
            }
        }

        if (!$user || !$isPasswordValid) {
            Log::warning("Login failed for [{$rawPhone}]: User found=" . ($user ? 'YES' : 'NO') . ", Password valid=" . ($isPasswordValid ? 'YES' : 'NO'));
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        Log::info("Login success for [{$rawPhone}] (User ID: {$user->id}, Name: {$user->name})");

        // Lưu FCM Token nếu client gửi kèm
        if ($request->has('fcm_token') && !empty($request->fcm_token)) {
            $user->update(['fcm_token' => $request->fcm_token]);
        }

        // Generate token
        $token = $user->createToken('mobile_app_token')->plainTextToken;

        return response()->json([
            'message' => 'Logged in successfully',
            'user' => $user,
            'token' => $token
        ], 200);
    }

    /**
     * API cập nhật FCM Token (gọi khi token thay đổi hoặc khi login lại)
     */
    public function updateFcmToken(Request $request)
    {
        $request->validate([
            'phone_number' => 'required|string',
            'fcm_token' => 'required|string',
        ]);

        $user = User::where('phone_number', $request->phone_number)->first();

        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        $user->update(['fcm_token' => $request->fcm_token]);

        return response()->json([
            'message' => 'FCM Token updated successfully',
        ], 200);
    }

    /**
     * API Thay đổi mật khẩu người dùng
     */
    public function changePassword(Request $request)
    {
        $request->validate([
            'phone_number' => 'required|string',
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:8',
        ]);

        $rawPhone = trim($request->phone_number);
        $phone0 = str_starts_with($rawPhone, '+84') ? '0' . substr($rawPhone, 3) 
            : (str_starts_with($rawPhone, '84') ? '0' . substr($rawPhone, 2) : $rawPhone);
        $phone84 = str_starts_with($rawPhone, '0') ? '+84' . substr($rawPhone, 1) : $rawPhone;

        $user = User::whereIn('phone_number', [$rawPhone, $phone0, $phone84])->first();

        if (!$user) {
            return response()->json(['message' => 'Không tìm thấy tài khoản người dùng'], 404);
        }

        if (!Hash::check($request->current_password, $user->password) && $request->current_password !== '123456') {
            return response()->json(['message' => 'Mật khẩu hiện tại không chính xác'], 400);
        }

        $newHash = Hash::make($request->new_password);
        $user->update(['password' => $newHash]);

        User::whereIn('phone_number', [$rawPhone, $phone0, $phone84])->update(['password' => $newHash]);

        return response()->json([
            'status' => 'success',
            'message' => 'Đổi mật khẩu thành công',
        ], 200);
    }

    /**
     * API Lấy thông tin cá nhân
     */
    public function getUserInfo(Request $request)
    {
        $rawPhone = $request->query('phone_number') ?? $request->query('phone');
        if (!$rawPhone) {
            $user = $request->user();
            if ($user) $rawPhone = $user->phone_number;
        }
        $rawPhone = $rawPhone ?? '0374244315';
        $phone0 = str_starts_with($rawPhone, '+84') ? '0' . substr($rawPhone, 3) : $rawPhone;
        $phone84 = str_starts_with($rawPhone, '0') ? '+84' . substr($rawPhone, 1) : $rawPhone;

        $user = User::whereIn('phone_number', [$rawPhone, $phone0, $phone84])->first();
        $bn = \Illuminate\Support\Facades\DB::table('benh_nhan')->whereIn('so_dien_thoai', [$rawPhone, $phone0, $phone84])->first();
        $bnClinic = \Illuminate\Support\Facades\DB::table('benhnhan')->whereIn('so_dien_thoai', [$rawPhone, $phone0, $phone84])->first();
        $hoso = \Illuminate\Support\Facades\DB::table('ho_so_benh_an')->whereIn('so_dien_thoai', [$rawPhone, $phone0, $phone84])->first();

        return response()->json([
            'status' => 'success',
            'data' => [
                'name' => $bnClinic->ho_ten ?? ($bn->ho_ten ?? ($hoso ? ($hoso->ho_chu_lot . ' ' . $hoso->ten) : ($user->name ?? 'Đặng Duy Lợi'))),
                'phone' => $phone0,
                'email' => $bnClinic->email ?? ($user->email ?? ''),
                'dob' => $bnClinic->ngay_sinh ?? ($bn->ngay_sinh ?? ($hoso->ngay_sinh ?? '2000-01-01')),
                'gender' => $bnClinic->gioi_tinh ?? (($bn && $bn->gioi_tinh == 1) ? 'Nam' : 'Nữ'),
                'address' => $bnClinic->dia_chi ?? ($bn->dia_chi ?? ($hoso->tinh_thanh ?? 'TP. Hồ Chí Minh')),
                'cccd' => $bnClinic->cccd ?? ($hoso->cccd ?? ''),
            ]
        ]);
    }

    /**
     * API Cập nhật thông tin cá nhân
     */
    public function updateUserInfo(Request $request)
    {
        $request->validate([
            'phone_number' => 'required|string',
            'name' => 'required|string',
        ]);

        $rawPhone = $request->phone_number;
        $phone0 = str_starts_with($rawPhone, '+84') ? '0' . substr($rawPhone, 3) : $rawPhone;
        $phone84 = str_starts_with($rawPhone, '0') ? '+84' . substr($rawPhone, 1) : $rawPhone;

        // Cập nhật User
        User::whereIn('phone_number', [$rawPhone, $phone0, $phone84])->update(['name' => $request->name]);

        // Cập nhật benh_nhan
        \Illuminate\Support\Facades\DB::table('benh_nhan')->whereIn('so_dien_thoai', [$rawPhone, $phone0, $phone84])->update([
            'ho_ten' => $request->name,
            'ngay_sinh' => $request->dob ?? '2000-01-01',
            'dia_chi' => $request->address ?? '',
        ]);

        // Cập nhật benhnhan
        \Illuminate\Support\Facades\DB::table('benhnhan')->whereIn('so_dien_thoai', [$rawPhone, $phone0, $phone84])->update([
            'ho_ten' => $request->name,
            'ngay_sinh' => $request->dob ?? '2000-01-01',
            'dia_chi' => $request->address ?? '',
            'cccd' => $request->cccd ?? '',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Cập nhật thông tin thành công'
        ]);
    }
}

