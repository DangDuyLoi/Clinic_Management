<?php

namespace App\Traits;

trait ApiResponse
{
    protected function successResponse($data = null, $message = 'Thành công', $statusCode = 200)
    {
        return response()->json([
            'success' => true,
            'status_code' => $statusCode,
            'message' => $message,
            'data' => $data,
            'errors' => null
        ], $statusCode);
    }

    protected function errorResponse($message = 'Đã có lỗi xảy ra', $statusCode = 400, $errors = null)
    {
        return response()->json([
            'success' => false,
            'status_code' => $statusCode,
            'message' => $message,
            'data' => null,
            'errors' => $errors
        ], $statusCode);
    }
}
