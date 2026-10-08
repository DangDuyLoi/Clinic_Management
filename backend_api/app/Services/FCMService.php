<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Google\Auth\Credentials\ServiceAccountCredentials;
use Google\Auth\HttpHandler\HttpHandlerFactory;

class FCMService
{
    /**
     * Lấy Access Token từ Firebase Service Account JSON
     */
    private static function getAccessToken(): ?string
    {
        try {
            $keyFilePath = storage_path('app/firebase-credentials.json');
            
            if (!file_exists($keyFilePath)) {
                Log::error('Không tìm thấy file firebase-credentials.json tại: ' . $keyFilePath);
                return null;
            }

            $credentials = new ServiceAccountCredentials(
                ['https://www.googleapis.com/auth/firebase.messaging'],
                $keyFilePath
            );

            // Fetch the access token
            $token = $credentials->fetchAuthToken(HttpHandlerFactory::build());

            return $token['access_token'] ?? null;
        } catch (\Exception $e) {
            Log::error("FCM GetToken Exception: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Lấy Project ID từ Firebase Service Account JSON
     */
    private static function getProjectId(): string
    {
        try {
            $keyFilePath = storage_path('app/firebase-credentials.json');
            $jsonContent = json_decode(file_get_contents($keyFilePath), true);
            return $jsonContent['project_id'] ?? 'verify-otp-f794a';
        } catch (\Exception $e) {
            return 'verify-otp-f794a';
        }
    }

    /**
     * Gửi Push Notification qua Firebase Cloud Messaging (FCM) HTTP v1 API
     *
     * @param string $fcmToken - FCM Token của thiết bị nhận
     * @param string $title - Tiêu đề thông báo
     * @param string $body - Nội dung thông báo
     * @param array $data - Dữ liệu bổ sung (optional)
     * @return bool
     */
    public static function sendNotification(string $fcmToken, string $title, string $body, array $data = []): bool
    {
        $accessToken = self::getAccessToken();
        $projectId = self::getProjectId();

        if (empty($accessToken)) {
            Log::warning('Không thể lấy Access Token cho FCM HTTP v1 API.');
            return false;
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
            ])->post("https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send", [
                'message' => [
                    'token' => $fcmToken,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                    ],
                    // Data payload phải chứa các string key-value
                    'data' => array_map('strval', $data),
                    'android' => [
                        'notification' => [
                            'sound' => 'default',
                        ]
                    ],
                    'apns' => [
                        'payload' => [
                            'aps' => [
                                'sound' => 'default'
                            ]
                        ]
                    ]
                ]
            ]);

            if ($response->successful()) {
                Log::info("FCM Notification gửi thành công (HTTP v1) tới token: " . substr($fcmToken, 0, 20) . "...");
                return true;
            } else {
                Log::error("FCM Notification thất bại (HTTP v1): " . $response->body());
                return false;
            }
        } catch (\Exception $e) {
            Log::error("FCM Exception: " . $e->getMessage());
            return false;
        }
    }
}
