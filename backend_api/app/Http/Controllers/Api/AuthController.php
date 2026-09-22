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
        $user = User::where('phone_number', $request->phone_number)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        // Generate token
        $token = $user->createToken('mobile_app_token')->plainTextToken;

        return response()->json([
            'message' => 'Logged in successfully',
            'user' => $user,
            'token' => $token
        ], 200);
    }
}
