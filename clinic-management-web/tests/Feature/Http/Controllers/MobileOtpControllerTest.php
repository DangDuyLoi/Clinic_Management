<?php

namespace Tests\Feature\Http\Controllers;

use Tests\TestCase;

class MobileOtpControllerTest extends TestCase
{
    public function test_send_otp_returns_service_unavailable_when_demo_mode_is_disabled(): void
    {
        config(['otp.demo_enabled' => false]);

        $this->postJson('/api/mobile/send-otp', ['phone_number' => '0900000001'])
            ->assertStatus(503)
            ->assertJson(['message' => 'OTP provider is not configured.']);
    }

    public function test_verify_otp_rejects_the_demo_code_when_demo_mode_is_disabled(): void
    {
        config(['otp.demo_enabled' => false]);

        $this->postJson('/api/mobile/verify-otp', [
            'phone_number' => '0900000001',
            'otp' => '123456',
        ])
            ->assertStatus(503)
            ->assertJson(['message' => 'OTP provider is not configured.']);
    }

    public function test_send_otp_discloses_the_demo_code_only_when_demo_mode_is_enabled(): void
    {
        config(['otp.demo_enabled' => true]);

        $this->postJson('/api/mobile/send-otp', ['phone_number' => '0900000001'])
            ->assertOk()
            ->assertJson([
                'message' => 'Mã OTP đã được gửi đến số điện thoại (Mã mặc định: 123456)',
            ]);
    }

    public function test_verify_otp_accepts_the_demo_code_only_when_demo_mode_is_enabled(): void
    {
        config(['otp.demo_enabled' => true]);

        $this->postJson('/api/mobile/verify-otp', [
            'phone_number' => '0900000001',
            'otp' => '123456',
        ])
            ->assertOk()
            ->assertJson(['message' => 'Xác thực OTP thành công']);
    }
}
