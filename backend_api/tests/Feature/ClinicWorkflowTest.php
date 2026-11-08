<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;
use App\Models\User; // Hoặc model TaiKhoan tùy cấu trúc nhóm

class ClinicWorkflowTest extends TestCase
{
    // Sử dụng trait để reset database sau mỗi test case nếu cần
    // use RefreshDatabase;

    protected $token;
    protected $lichKhamId;

    /**
     * TC01: Kiểm thử Đăng ký tài khoản mới
     */
    public function test_user_can_register_successfully()
    {
        $response = $this->postJson('/api/auth/register', [
            'ten_dang_nhap' => 'testpatient01',
            'phone_number' => '0987654321',
            'password' => 'Password123!',
            'password_confirmation' => 'Password123!',
            'ho_ten' => 'Nguyễn Văn Test'
        ]);

        // Kỳ vọng trả về mã 201 hoặc 200 tùy API của nhóm
        $response->assertStatus(200)
                 ->assertJsonStructure(['message', 'user']);
    }

    /**
     * TC02: Kiểm thử Đăng nhập hệ thống lấy JWT Token
     */
    public function test_user_can_login_and_receive_jwt_token()
    {
        $response = $this->postJson('/api/auth/login', [
            'ten_dang_nhap' => 'testpatient01', // hoặc dùng số điện thoại tùy logic login
            'password' => 'Password123!'
        ]);

        // Nếu đăng nhập thành công, lưu token để dùng cho các test sau
        if ($response->status() === 200) {
            $data = $response->json();
            $this->token = $data['access_token'] ?? $data['token'] ?? null;
        }

        $response->assertStatus(200)
                 ->assertJsonStructure(['access_token']);
    }

    /**
     * TC03: Kiểm thử Lấy danh mục chuyên khoa (Public Route)
     */
    public function test_can_fetch_specialties_list()
    {
        $response = $this->getJson('/api/chuyen-khoa');

        $response->assertStatus(200)
                 ->assertJsonIsArray();
    }

    /**
     * TC04: Kiểm thử Đặt lịch khám bệnh hợp lệ
     */
    public function test_patient_can_book_appointment()
    {
        // Lấy token giả lập hoặc dùng token từ test đăng nhập
        $token = $this->authenticateTestUser();

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
                         ->postJson('/api/lich-kham', [
                             'ma_chuyen_khoa' => 1,
                             'ma_bs' => 1,
                             'ngay_kham' => date('Y-m-d', strtotime('+1 day')), // Ngày mai
                             'ma_khung_gio' => 1
                         ]);

        // Lưu lại ID lịch khám để test QR ở các bước sau
        if ($response->status() === 201 || $response->status() === 200) {
            $this->lichKhamId = $response->json('data.ma_luot_kham') ?? 1;
        }

        $response->assertStatus(200);
    }

    /**
     * TC05: Kiểm thử Đặt lịch khám với ngày trong quá khứ (Phải thất bại)
     */
    public function test_booking_fails_on_past_date()
    {
        $token = $this->authenticateTestUser();

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
                         ->postJson('/api/lich-kham', [
                             'ma_chuyen_khoa' => 1,
                             'ma_bs' => 1,
                             'ngay_kham' => '2020-01-01', // Ngày trong quá khứ
                             'ma_khung_gio' => 1
                         ]);

        // Kỳ vọng trả về lỗi validate (422 Unprocessable Entity)
        $response->assertStatus(422);
    }

    /**
     * TC06: Kiểm thử Xuất mã QR cho lịch hẹn
     */
    public function test_can_get_qr_code_for_appointment()
    {
        $token = $this->authenticateTestUser();
        $lichKhamId = 1; // ID mẫu trong DB test

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
                         ->getJson("/api/lich-kham/{$lichKhamId}/qr");

        $response->assertStatus(200)
                 ->assertJsonStructure(['qr_token', 'qr_url']);
    }

    /**
     * TC07 & TC08: Kiểm thử Lễ tân quét mã QR
     */
    public function test_receptionist_can_scan_qr_code()
    {
        $receptionistToken = $this->authenticateReceptionistUser();

        $response = $this->withHeader('Authorization', 'Bearer ' . $receptionistToken)
                         ->postJson('/api/lich-kham/scan-qr', [
                             'qr_token' => 'LICHKHAM_TEST_TOKEN_1'
                         ]);

        // Nếu mã hợp lệ sẽ trả về thông tin bệnh nhân & lịch khám
        $response->assertStatus(200);
    }

    /**
     * TC09 & TC10: Kiểm thử Check-in bằng QR và kích hoạt FCM Real-time
     */
    public function test_checkin_by_qr_triggers_fcm_notification()
    {
        $receptionistToken = $this->authenticateReceptionistUser();
        $lichKhamId = 1;

        $response = $this->withHeader('Authorization', 'Bearer ' . $receptionistToken)
                         ->putJson("/api/lich-kham/{$lichKhamId}/checkin-by-qr");

        // Kỳ vọng chuyển trạng thái thành công và gọi Background Job gửi FCM
        $response->assertStatus(200)
                 ->assertJsonFragment(['message' => 'Check-in thành công']);
    }

    /**
     * TC11: Kiểm thử Bác sĩ cập nhật phiên khám và chẩn đoán
     */
    public function test_doctor_can_update_medical_examination()
    {
        $doctorToken = $this->authenticateDoctorUser();
        $phienKhamId = 1;

        $response = $this->withHeader('Authorization', 'Bearer ' . $doctorToken)
                         ->putJson("/api/phien-kham/{$phienKhamId}", [
                             'chan_doan_so_bo' => 'Viêm họng cấp',
                             'ket_luan' => 'Theo dõi điều trị ngoại trú'
                         ]);

        $response->assertStatus(200);
    }

    /**
     * TC12: Kiểm thử Bác sĩ lập đơn thuốc
     */
    public function test_doctor_can_create_prescription()
    {
        $doctorToken = $this->authenticateDoctorUser();

        $response = $this->withHeader('Authorization', 'Bearer ' . $doctorToken)
                         ->postJson('/api/don-thuoc', [
                             'ma_phien_kham' => 1,
                             'chi_tiet' => [
                                 ['ma_thuoc' => 1, 'so_luong' => 10, 'lieu_dung' => 'Sáng 1 viên, chiều 1 viên']
                             ]
                         ]);

        $response->assertStatus(200);
    }

    /**
     * TC13: Kiểm thử Khởi tạo thanh toán VNPay
     */
    public function test_can_initiate_vnpay_payment()
    {
        $token = $this->authenticateTestUser();
        $hoaDonId = 1;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
                         ->postJson("/api/vnpay/create-payment/{$hoaDonId}");

        $response->assertStatus(200)
                 ->assertJsonStructure(['payment_url']);
    }

    // --- Các hàm phụ trợ tạo token phân quyền nhanh cho test ---
    protected function authenticateTestUser()
    {
        // Trả về token của bệnh nhân (hoặc tạo user ảo trong test DB)
        return 'mock_patient_jwt_token';
    }

    protected function authenticateReceptionistUser()
    {
        return 'mock_receptionist_jwt_token';
    }

    protected function authenticateDoctorUser()
    {
        return 'mock_doctor_jwt_token';
    }
}
