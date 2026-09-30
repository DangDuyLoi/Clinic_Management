<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckRole
{
    /**
     * Kiểm tra vai trò của user từ JWT payload.
     * Dùng: Route::middleware('role:QuanTri,BacSi')
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Chưa xác thực',
            ], 401);
        }

        if (!in_array($user->vai_tro, $roles, true)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Bạn không có quyền truy cập chức năng này',
            ], 403);
        }

        return $next($request);
    }
}