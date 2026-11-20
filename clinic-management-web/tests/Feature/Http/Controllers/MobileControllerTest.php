<?php

namespace Tests\Feature\Http\Controllers;

use App\Models\BacSi;
use App\Models\BenhNhan;
use App\Models\HoaDon;
use App\Models\HoSoBenhAn;
use App\Models\LichKham;
use App\Models\PhienKham;
use App\Models\TaiKhoan;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;
use Tymon\JWTAuth\Facades\JWTAuth;

class MobileControllerTest extends TestCase
{
    use DatabaseTransactions;

    public function test_returns_canonical_hcm_province_and_components_from_combined_patient_address(): void
    {
        $taiKhoan = TaiKhoan::create([
            'ten_dang_nhap' => 'profile-address-'.Str::random(10),
            'mat_khau' => 'test-password',
            'vai_tro' => 'BenhNhan',
            'trang_thai' => true,
        ]);
        $benhNhan = BenhNhan::create([
            'ma_tk' => $taiKhoan->ma_tk,
            'ho_ten' => 'Nguyễn Văn Test',
            'dia_chi' => '207 Nguyễn Văn Thủ, Phường Tân Định, Quận 1, TP.HCM',
        ]);
        HoSoBenhAn::create([
            'ma_benh_nhan' => $benhNhan->ma_benh_nhan,
            'ma_bhyt' => 'TE1791234567890',
        ]);
        $token = JWTAuth::fromUser($taiKhoan);

        $response = $this->withToken($token)->getJson('/api/mobile/patient-profiles/by-phone');

        $response->assertStatus(200);
        $this->assertSame('207 Nguyễn Văn Thủ', $response->json('data.0.so_nha'));
        $this->assertSame('Phường Tân Định', $response->json('data.0.phuong_xa'));
        $this->assertSame('Quận 1', $response->json('data.0.quan_huyen'));
        $this->assertSame('Thành phố Hồ Chí Minh', $response->json('data.0.tinh_thanh'));
        $this->assertSame('TE1791234567890', $response->json('data.0.ma_bhyt'));
        $this->assertSame('TE1791234567890', $response->json('data.0.so_the_bhyt'));
        $this->assertSame(
            '207 Nguyễn Văn Thủ, Phường Tân Định, Quận 1, TP.HCM',
            $response->json('data.0.dia_chi')
        );
    }

    public function test_splits_three_part_legacy_address_without_inventing_a_ward(): void
    {
        $taiKhoan = TaiKhoan::create([
            'ten_dang_nhap' => 'profile-address-'.Str::random(10),
            'mat_khau' => 'test-password',
            'vai_tro' => 'BenhNhan',
            'trang_thai' => true,
        ]);
        $benhNhan = BenhNhan::create([
            'ma_tk' => $taiKhoan->ma_tk,
            'ho_ten' => 'Bệnh nhân địa chỉ test',
            'dia_chi' => '123 Đường Test, Quận 1, TP.HCM',
        ]);
        HoSoBenhAn::create(['ma_benh_nhan' => $benhNhan->ma_benh_nhan]);
        $token = JWTAuth::fromUser($taiKhoan);

        $response = $this->withToken($token)->getJson('/api/mobile/patient-profiles/by-phone');

        $response->assertStatus(200);
        $this->assertSame('123 Đường Test', $response->json('data.0.so_nha'));
        $this->assertSame('', $response->json('data.0.phuong_xa'));
        $this->assertSame('Quận 1', $response->json('data.0.quan_huyen'));
        $this->assertSame('Thành phố Hồ Chí Minh', $response->json('data.0.tinh_thanh'));
    }

    public function test_clears_emergency_contact_when_update_sends_null(): void
    {
        $taiKhoan = TaiKhoan::create([
            'ten_dang_nhap' => 'profile-contact-'.Str::random(10),
            'mat_khau' => 'test-password',
            'vai_tro' => 'BenhNhan',
            'trang_thai' => true,
        ]);
        $benhNhan = BenhNhan::create([
            'ma_tk' => $taiKhoan->ma_tk,
            'ho_ten' => 'Nguyễn Văn Test',
            'nguoi_lien_he_khan_cap' => 'Nguyễn Thị Test',
        ]);
        $hoSo = HoSoBenhAn::create(['ma_benh_nhan' => $benhNhan->ma_benh_nhan]);
        $token = JWTAuth::fromUser($taiKhoan);

        $response = $this->withToken($token)->putJson(
            '/api/mobile/patient-profiles/'.$hoSo->ma_ho_so,
            ['nguoi_lien_he_khan_cap' => null]
        );

        $response->assertStatus(200);
        $this->assertDatabaseHas('benhnhan', [
            'ma_benh_nhan' => $benhNhan->ma_benh_nhan,
            'nguoi_lien_he_khan_cap' => null,
        ]);
    }

    public function test_clears_bhyt_from_patient_and_medical_record_when_update_sends_null(): void
    {
        $taiKhoan = TaiKhoan::create([
            'ten_dang_nhap' => 'profile-bhyt-'.Str::random(10),
            'mat_khau' => 'test-password',
            'vai_tro' => 'BenhNhan',
            'trang_thai' => true,
        ]);
        $benhNhan = BenhNhan::create([
            'ma_tk' => $taiKhoan->ma_tk,
            'ho_ten' => 'Nguyễn Văn Test',
            'ma_bhyt' => 'TE1791234567890',
        ]);
        $hoSo = HoSoBenhAn::create([
            'ma_benh_nhan' => $benhNhan->ma_benh_nhan,
            'ma_bhyt' => 'TE1791234567890',
        ]);
        $token = JWTAuth::fromUser($taiKhoan);

        $response = $this->withToken($token)->putJson(
            '/api/mobile/patient-profiles/'.$hoSo->ma_ho_so,
            ['so_the_bhyt' => null]
        );

        $response->assertStatus(200);
        $this->assertDatabaseHas('benhnhan', [
            'ma_benh_nhan' => $benhNhan->ma_benh_nhan,
            'ma_bhyt' => null,
        ]);
        $this->assertDatabaseHas('hosobenhan', [
            'ma_ho_so' => $hoSo->ma_ho_so,
            'ma_bhyt' => null,
        ]);
    }

    public function test_creates_patient_relative_with_name_and_address_fields_on_patient_record(): void
    {
        $taiKhoan = TaiKhoan::create([
            'ten_dang_nhap' => 'profile-relative-'.Str::random(10),
            'mat_khau' => 'test-password',
            'vai_tro' => 'BenhNhan',
            'trang_thai' => true,
        ]);
        $token = JWTAuth::fromUser($taiKhoan);

        $response = $this->withToken($token)->postJson('/api/mobile/patient-profiles', [
            'ho_chu_lot' => 'Nguyễn Văn',
            'ten' => 'An',
            'so_nha' => '207 Nguyễn Văn Thủ',
            'phuong_xa' => 'Phường Tân Định',
            'quan_huyen' => 'Quận 1',
            'tinh_thanh' => 'Thành phố Hồ Chí Minh',
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('benhnhan', [
            'ma_benh_nhan' => $response->json('data.ma_benh_nhan'),
            'ho_chu_lot' => 'Nguyễn Văn',
            'ten' => 'An',
            'tinh_thanh' => 'Thành phố Hồ Chí Minh',
            'phuong_xa' => 'Phường Tân Định',
            'so_nha' => '207 Nguyễn Văn Thủ',
        ]);
    }

    public function test_updates_name_and_address_fields_on_patient_record(): void
    {
        $taiKhoan = TaiKhoan::create([
            'ten_dang_nhap' => 'profile-update-'.Str::random(10),
            'mat_khau' => 'test-password',
            'vai_tro' => 'BenhNhan',
            'trang_thai' => true,
        ]);
        $benhNhan = BenhNhan::create([
            'ma_tk' => $taiKhoan->ma_tk,
            'ho_ten' => 'Nguyễn Văn Cũ',
        ]);
        $hoSo = HoSoBenhAn::create(['ma_benh_nhan' => $benhNhan->ma_benh_nhan]);
        $token = JWTAuth::fromUser($taiKhoan);

        $response = $this->withToken($token)->putJson(
            '/api/mobile/patient-profiles/'.$hoSo->ma_ho_so,
            [
                'ho_chu_lot' => 'Nguyễn Văn',
                'ten' => 'An',
                'so_nha' => '207 Nguyễn Văn Thủ',
                'phuong_xa' => 'Phường Tân Định',
                'tinh_thanh' => 'Thành phố Hồ Chí Minh',
            ]
        );

        $response->assertStatus(200);
        $this->assertDatabaseHas('benhnhan', [
            'ma_benh_nhan' => $benhNhan->ma_benh_nhan,
            'ho_chu_lot' => 'Nguyễn Văn',
            'ten' => 'An',
            'tinh_thanh' => 'Thành phố Hồ Chí Minh',
            'phuong_xa' => 'Phường Tân Định',
            'so_nha' => '207 Nguyễn Văn Thủ',
        ]);
    }

    public function test_mobile_booking_uses_patient_birth_date_for_insurance_rule(): void
    {
        $taiKhoan = TaiKhoan::create([
            'ten_dang_nhap' => 'booking-doctor-'.Str::random(10),
            'mat_khau' => 'test-password',
            'vai_tro' => 'BacSi',
            'trang_thai' => true,
        ]);
        $maChuyenKhoa = DB::table('chuyenkhoa')->insertGetId([
            'ten_chuyen_khoa' => 'Chuyên khoa đặt lịch test',
            'trang_thai' => 1,
        ]);
        $bacSi = BacSi::create([
            'ma_tk' => $taiKhoan->ma_tk,
            'ma_chuyen_khoa' => $maChuyenKhoa,
            'ho_ten' => 'Bác sĩ đặt lịch test',
            'luot_kham_toi_da_moi_ca' => 20,
        ]);
        $benhNhan = BenhNhan::create([
            'ho_ten' => 'Bệnh nhân đặt lịch test',
            'ngay_sinh' => '1990-01-01',
        ]);
        $hoSo = HoSoBenhAn::create([
            'ma_benh_nhan' => $benhNhan->ma_benh_nhan,
        ]);

        $response = $this->postJson('/api/mobile/luot-kham/dat-lich', [
            'ma_ho_so' => $hoSo->ma_ho_so,
            'ma_bac_si' => $bacSi->ma_bs,
            'thoi_gian_den_kham' => now()->addDay()->format('Y-m-d H:i:s'),
            'priority_level' => 4,
            'is_bhyt' => false,
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('luotkham', [
            'ma_ho_so' => $hoSo->ma_ho_so,
            'ma_bac_si' => $bacSi->ma_bs,
        ]);
    }

    public function test_mobile_checkin_qr_uses_the_token_accepted_by_reception(): void
    {
        $doctorAccount = TaiKhoan::create([
            'ten_dang_nhap' => 'qr-doctor-'.Str::random(10),
            'mat_khau' => 'test-password',
            'vai_tro' => 'BacSi',
            'trang_thai' => true,
        ]);
        $patientAccount = TaiKhoan::create([
            'ten_dang_nhap' => 'qr-patient-'.Str::random(10),
            'mat_khau' => 'test-password',
            'vai_tro' => 'BenhNhan',
            'trang_thai' => true,
        ]);
        $maChuyenKhoa = DB::table('chuyenkhoa')->insertGetId([
            'ten_chuyen_khoa' => 'Chuyên khoa QR test',
            'trang_thai' => 1,
        ]);
        $bacSi = BacSi::create([
            'ma_tk' => $doctorAccount->ma_tk,
            'ma_chuyen_khoa' => $maChuyenKhoa,
            'ho_ten' => 'Bác sĩ QR test',
            'luot_kham_toi_da_moi_ca' => 20,
        ]);
        $benhNhan = BenhNhan::create([
            'ma_tk' => $patientAccount->ma_tk,
            'ho_ten' => 'Bệnh nhân QR test',
        ]);
        $hoSo = HoSoBenhAn::create(['ma_benh_nhan' => $benhNhan->ma_benh_nhan]);
        $lichKham = LichKham::create([
            'ma_ho_so' => $hoSo->ma_ho_so,
            'ma_bac_si' => $bacSi->ma_bs,
            'thoi_gian_den_kham' => now()->addDay(),
            'trang_thai' => 'da_thanh_toan',
        ]);

        $token = JWTAuth::fromUser($patientAccount);
        $qrEndpoint = '/api/mobile/luot-kham/'.$lichKham->ma_luot_kham.'/qr';
        $qrResponse = $this->withToken($token)->getJson($qrEndpoint);

        $qrResponse->assertOk()->assertJsonPath('status', 'success');
        $qrToken = $qrResponse->json('data.qr_token');
        $this->assertMatchesRegularExpression('/^LK[A-F0-9]{32}$/', $qrToken);
        $this->assertDatabaseHas('luotkham', [
            'ma_luot_kham' => $lichKham->ma_luot_kham,
            'qr_token' => $qrToken,
        ]);

        $otherPatientAccount = TaiKhoan::create([
            'ten_dang_nhap' => 'qr-other-patient-'.Str::random(10),
            'mat_khau' => 'test-password',
            'vai_tro' => 'BenhNhan',
            'trang_thai' => true,
        ]);
        $otherPatient = BenhNhan::create([
            'ma_tk' => $otherPatientAccount->ma_tk,
            'ho_ten' => 'Bệnh nhân QR khác',
        ]);
        $otherHoSo = HoSoBenhAn::create(['ma_benh_nhan' => $otherPatient->ma_benh_nhan]);
        $otherLichKham = LichKham::create([
            'ma_ho_so' => $otherHoSo->ma_ho_so,
            'ma_bac_si' => $bacSi->ma_bs,
            'thoi_gian_den_kham' => now()->addDay(),
            'trang_thai' => 'da_thanh_toan',
        ]);
        $this->withToken($token)
            ->getJson('/api/mobile/luot-kham/'.$otherLichKham->ma_luot_kham.'/qr')
            ->assertStatus(404);

        $this->withToken($token)->postJson('/api/lich-kham/scan-qr', [
            'qr_content' => 'LICHKHAM:'.$qrToken,
        ])->assertOk()
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.ma_luot_kham', $lichKham->ma_luot_kham);
    }

    public function test_mobile_checkin_qr_requires_patient_authentication(): void
    {
        $this->getJson('/api/mobile/luot-kham/1/qr')->assertUnauthorized();
    }

    public function test_mobile_checkin_qr_forbids_non_patient_accounts(): void
    {
        $doctorAccount = TaiKhoan::create([
            'ten_dang_nhap' => 'qr-role-check-'.Str::random(10),
            'mat_khau' => 'test-password',
            'vai_tro' => 'BacSi',
            'trang_thai' => true,
        ]);
        $token = JWTAuth::fromUser($doctorAccount);

        $this->withToken($token)
            ->getJson('/api/mobile/luot-kham/1/qr')
            ->assertStatus(403);
    }

    public function test_vnpay_success_updates_all_bookings_and_returns_to_the_app(): void
    {
        config([
            'services.vnpay.tmn_code' => 'TESTTMN',
            'services.vnpay.hash_secret' => 'test-vnpay-secret',
            'services.vnpay.url' => 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
            'services.vnpay.return_url' => null,
        ]);
        $fixtures = $this->createVnpayAppointments(2);
        $appointments = $fixtures['appointments'];
        $maLuotKham = implode('-', array_map(
            fn (LichKham $appointment): string => (string) $appointment->ma_luot_kham,
            $appointments
        ));

        $paymentUrlResponse = $this->getJson('/api/mobile/vnpay/payment-url?'.http_build_query([
            'ma_luot_kham' => $maLuotKham,
            'amount' => 300000,
        ]));

        $paymentUrlResponse->assertOk()->assertJsonPath('status', 'success');
        parse_str((string) parse_url($paymentUrlResponse->json('payment_url'), PHP_URL_QUERY), $paymentParameters);
        $this->assertSame('/api/mobile/vnpay/return', parse_url($paymentParameters['vnp_ReturnUrl'], PHP_URL_PATH));

        $callbackParameters = $this->signVnpayParams([
            'vnp_Amount' => '30000000',
            'vnp_ResponseCode' => '00',
            'vnp_TmnCode' => 'TESTTMN',
            'vnp_TransactionStatus' => '00',
            'vnp_TxnRef' => $paymentUrlResponse->json('txn_ref'),
            'vnp_SecureHashType' => 'HmacSHA512',
        ]);
        $callbackResponse = $this->get('/api/mobile/vnpay/return?'.http_build_query($callbackParameters));

        $callbackResponse->assertOk()->assertSee('clinicapp:///payment-result?status=success', false);
        foreach ($appointments as $appointment) {
            $this->assertDatabaseHas('luotkham', [
                'ma_luot_kham' => $appointment->ma_luot_kham,
                'trang_thai' => 'da_thanh_toan',
            ]);
        }

        $this->withToken(JWTAuth::fromUser($fixtures['patientAccount']))
            ->getJson('/api/mobile/luot-kham/'.$appointments[0]->ma_luot_kham.'/check-status')
            ->assertOk()
            ->assertJsonPath('data.is_paid', true);
    }

    public function test_mobile_can_pay_a_pending_completed_invoice_via_vnpay(): void
    {
        config([
            'services.vnpay.tmn_code' => 'TESTTMN',
            'services.vnpay.hash_secret' => 'test-vnpay-secret',
            'services.vnpay.url' => 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
            'services.vnpay.return_url' => null,
        ]);
        $fixtures = $this->createVnpayAppointments(1);
        $appointment = $fixtures['appointments'][0];
        $session = PhienKham::create([
            'ma_lich_dat' => $appointment->ma_luot_kham,
            'trang_thai' => 'ChoThanhToan',
        ]);
        $invoice = HoaDon::create([
            'ma_phien_kham' => $session->ma_phien_kham,
            'tien_kham_benh' => 150000,
            'tien_dich_vu' => 50000,
            'tien_thuoc' => 25000,
            'tong_cong' => 225000,
            'tien_bhyt_tra' => 0,
            'tien_benh_nhan_tra' => 25000,
            'trang_thai' => 'ChuaThanhToan',
        ]);
        $appointment->update(['trang_thai' => 'hoan_tat_hoa_don']);

        $invalidAmountResponse = $this->getJson('/api/mobile/vnpay/payment-url?'.http_build_query([
            'ma_luot_kham' => $appointment->ma_luot_kham,
            'amount' => 250000,
        ]));

        $invalidAmountResponse->assertStatus(422);
        $this->assertDatabaseHas('hoadon', [
            'ma_hoa_don' => $invoice->ma_hoa_don,
            'trang_thai' => 'ChuaThanhToan',
        ]);

        $paymentUrlResponse = $this->getJson('/api/mobile/vnpay/payment-url?'.http_build_query([
            'ma_luot_kham' => $appointment->ma_luot_kham,
            'amount' => 25000,
        ]));
        $paymentUrlResponse->assertOk()
            ->assertJsonPath('status', 'success');
        $this->assertStringStartsWith('INVOICE_'.$invoice->ma_hoa_don.'_', $paymentUrlResponse->json('txn_ref'));

        $callbackParameters = $this->signVnpayParams([
            'vnp_Amount' => '2500000',
            'vnp_ResponseCode' => '00',
            'vnp_TmnCode' => 'TESTTMN',
            'vnp_TransactionStatus' => '00',
            'vnp_TxnRef' => $paymentUrlResponse->json('txn_ref'),
            'vnp_SecureHashType' => 'HmacSHA512',
        ]);
        $callbackResponse = $this->get('/api/mobile/vnpay/return?'.http_build_query($callbackParameters));

        $callbackResponse->assertOk()
            ->assertSee('clinicapp:///payment-result?status=success', false)
            ->assertSee('payment_type=invoice', false);
        $this->assertDatabaseHas('hoadon', [
            'ma_hoa_don' => $invoice->ma_hoa_don,
            'trang_thai' => 'DaThanhToan',
            'phuong_thuc' => 'VNPay',
        ]);
        $this->assertDatabaseHas('phienkham', [
            'ma_phien_kham' => $session->ma_phien_kham,
            'trang_thai' => 'HoanThanh',
        ]);
        $this->assertDatabaseHas('luotkham', [
            'ma_luot_kham' => $appointment->ma_luot_kham,
            'trang_thai' => 'hoan_thanh',
        ]);
        $this->withToken(JWTAuth::fromUser($fixtures['patientAccount']))
            ->getJson('/api/mobile/luot-kham/'.$appointment->ma_luot_kham.'/check-status')
            ->assertOk()
            ->assertJsonPath('data.is_paid', true);
    }

    public function test_mobile_appointment_list_exposes_the_balance_of_a_completed_invoice(): void
    {
        $fixtures = $this->createVnpayAppointments(1);
        $appointment = $fixtures['appointments'][0];
        $session = PhienKham::create([
            'ma_lich_dat' => $appointment->ma_luot_kham,
            'trang_thai' => 'ChoThanhToan',
        ]);
        HoaDon::create([
            'ma_phien_kham' => $session->ma_phien_kham,
            'tien_kham_benh' => 150000,
            'tien_dich_vu' => 50000,
            'tien_thuoc' => 25000,
            'tong_cong' => 225000,
            'tien_bhyt_tra' => 0,
            'tien_benh_nhan_tra' => 25000,
            'trang_thai' => 'ChuaThanhToan',
        ]);
        $appointment->update(['trang_thai' => 'hoan_tat_hoa_don']);
        $token = JWTAuth::fromUser($fixtures['patientAccount']);

        $this->withToken($token)
            ->getJson('/api/mobile/luot-kham/'.$appointment->ma_luot_kham.'/check-status')
            ->assertOk()
            ->assertJsonPath('data.is_paid', false);

        $this->withToken($token)
            ->postJson('/api/mobile/luot-kham/danh-sach', [
                'danh_sach_ma_ho_so' => [$appointment->ma_ho_so],
            ])
            ->assertOk()
            ->assertJsonPath('data.0.trang_thai_thanh_toan', 'ChuaThanhToan')
            ->assertJsonPath('data.0.so_tien_can_tra', '25000.00')
            ->assertJsonPath('data.0.is_completed', true);
    }

    public function test_mobile_payment_bills_require_patient_authentication(): void
    {
        $this->getJson('/api/mobile/payment/bills')
            ->assertUnauthorized()
            ->assertJsonPath('message', 'Unauthenticated.');
    }

    public function test_mobile_payment_bills_show_outstanding_balance_and_only_the_users_payment_history(): void
    {
        $fixtures = $this->createVnpayAppointments(2);
        $pendingAppointment = $fixtures['appointments'][0];
        $paidAppointment = $fixtures['appointments'][1];
        $pendingSession = PhienKham::create([
            'ma_lich_dat' => $pendingAppointment->ma_luot_kham,
            'trang_thai' => 'ChoThanhToan',
        ]);
        HoaDon::create([
            'ma_phien_kham' => $pendingSession->ma_phien_kham,
            'tien_kham_benh' => 150000,
            'tien_dich_vu' => 50000,
            'tien_thuoc' => 25000,
            'tong_cong' => 225000,
            'tien_bhyt_tra' => 0,
            'tien_benh_nhan_tra' => 25000,
            'trang_thai' => 'ChuaThanhToan',
        ]);
        $paidSession = PhienKham::create([
            'ma_lich_dat' => $paidAppointment->ma_luot_kham,
            'trang_thai' => 'HoanThanh',
        ]);
        $paidInvoice = HoaDon::create([
            'ma_phien_kham' => $paidSession->ma_phien_kham,
            'tien_kham_benh' => 150000,
            'tien_dich_vu' => 50000,
            'tien_thuoc' => 25000,
            'tong_cong' => 225000,
            'tien_bhyt_tra' => 0,
            'tien_benh_nhan_tra' => 150000,
            'trang_thai' => 'DaThanhToan',
        ]);
        $otherUserFixtures = $this->createVnpayAppointments(1);
        $otherAppointment = $otherUserFixtures['appointments'][0];
        $otherSession = PhienKham::create([
            'ma_lich_dat' => $otherAppointment->ma_luot_kham,
            'trang_thai' => 'HoanThanh',
        ]);
        HoaDon::create([
            'ma_phien_kham' => $otherSession->ma_phien_kham,
            'tien_kham_benh' => 150000,
            'tien_dich_vu' => 0,
            'tien_thuoc' => 0,
            'tong_cong' => 150000,
            'tien_bhyt_tra' => 0,
            'tien_benh_nhan_tra' => 150000,
            'trang_thai' => 'DaThanhToan',
        ]);

        $response = $this->withToken(JWTAuth::fromUser($fixtures['patientAccount']))
            ->getJson('/api/mobile/payment/bills');

        $response->assertOk()
            ->assertJsonPath('status', 'success')
            ->assertJsonCount(1, 'data.pending_bills')
            ->assertJsonPath('data.pending_bills.0.ma_luot_kham', $pendingAppointment->ma_luot_kham)
            ->assertJsonPath('data.pending_bills.0.tong_tien', 25000)
            ->assertJsonCount(3, 'data.payment_history')
            ->assertJsonPath('data.payment_history.0.ma_hoa_don', $paidInvoice->ma_hoa_don)
            ->assertJsonPath('data.payment_history.0.tong_tien', 150000)
            ->assertJsonPath(
                'data.payment_history.1.ma_giao_dich',
                'LK_'.$paidAppointment->ma_luot_kham
            )
            ->assertJsonPath('data.payment_history.1.tong_tien', 75000)
            ->assertJsonPath(
                'data.payment_history.2.ma_giao_dich',
                'LK_'.$pendingAppointment->ma_luot_kham
            )
            ->assertJsonPath('data.payment_history.2.tong_tien', 200000);
        $this->assertNotContains(
            $otherUserFixtures['appointments'][0]->ma_luot_kham,
            array_column($response->json('data.pending_bills'), 'ma_luot_kham')
        );
        $this->assertNotContains(
            $otherAppointment->ma_luot_kham,
            array_column($response->json('data.payment_history'), 'ma_luot_kham')
        );
    }

    public function test_vnpay_invalid_signature_does_not_update_payment_or_return_success(): void
    {
        config(['services.vnpay.hash_secret' => 'test-vnpay-secret']);
        $fixtures = $this->createVnpayAppointments(1);
        $appointment = $fixtures['appointments'][0];
        $callbackParameters = [
            'vnp_Amount' => '15000000',
            'vnp_ResponseCode' => '00',
            'vnp_TransactionStatus' => '00',
            'vnp_TxnRef' => 'BOOKING_'.$appointment->ma_luot_kham.'_1730000000',
            'vnp_SecureHash' => 'invalid-signature',
        ];

        $callbackResponse = $this->get('/api/mobile/vnpay/return?'.http_build_query($callbackParameters));

        $callbackResponse->assertOk()->assertSee('clinicapp:///payment-result?status=failed', false);
        $this->assertDatabaseHas('luotkham', [
            'ma_luot_kham' => $appointment->ma_luot_kham,
            'trang_thai' => 'cho_thanh_toan',
        ]);
    }

    public function test_vnpay_return_rejects_array_callback_values_without_crashing(): void
    {
        $callbackParameters = [
            'vnp_Amount' => '15000000',
            'vnp_ResponseCode' => '00',
            'vnp_TxnRef' => ['malformed'],
        ];

        $this->get('/api/mobile/vnpay/return?'.http_build_query($callbackParameters))
            ->assertOk()
            ->assertSee('clinicapp:///payment-result?status=failed', false);
    }

    public function test_mobile_appointments_include_the_registered_specialty_and_room(): void
    {
        $fixtures = $this->createVnpayAppointments(1);
        $appointment = $fixtures['appointments'][0];
        DB::table('chuyenkhoa')
            ->where('ma_chuyen_khoa', $appointment->bacSi->ma_chuyen_khoa)
            ->update(['phong_kham' => 'Phòng 101 - Tầng 1']);
        $token = JWTAuth::fromUser($fixtures['patientAccount']);

        $response = $this->withToken($token)->postJson('/api/mobile/luot-kham/danh-sach', [
            'danh_sach_ma_ho_so' => [$appointment->ma_ho_so],
        ]);

        $response->assertOk()
            ->assertJsonPath('data.0.ten_chuyen_khoa', 'Chuyên khoa VNPay test')
            ->assertJsonPath('data.0.phong_kham', 'Phòng 101 - Tầng 1');
    }

    public function test_creating_a_medical_session_copies_the_specialty_room(): void
    {
        $fixtures = $this->createVnpayAppointments(1);
        $appointment = $fixtures['appointments'][0];
        DB::table('chuyenkhoa')
            ->where('ma_chuyen_khoa', $appointment->bacSi->ma_chuyen_khoa)
            ->update(['phong_kham' => 'Phòng 101 - Tầng 1']);
        $doctorToken = JWTAuth::fromUser(TaiKhoan::findOrFail($appointment->bacSi->ma_tk));

        $response = $this->withToken($doctorToken)
            ->getJson('/api/phien-kham/by-lich/'.$appointment->ma_luot_kham);

        $response->assertOk()
            ->assertJsonPath('data.phien_kham.phong_kham', 'Phòng 101 - Tầng 1');
        $this->assertDatabaseHas('phienkham', [
            'ma_lich_dat' => $appointment->ma_luot_kham,
            'phong_kham' => 'Phòng 101 - Tầng 1',
        ]);
    }

    /**
     * @return array{patientAccount: TaiKhoan, appointments: list<LichKham>}
     */
    private function createVnpayAppointments(int $count): array
    {
        $doctorAccount = TaiKhoan::create([
            'ten_dang_nhap' => 'vnpay-doctor-'.Str::random(10),
            'mat_khau' => 'test-password',
            'vai_tro' => 'BacSi',
            'trang_thai' => true,
        ]);
        $patientAccount = TaiKhoan::create([
            'ten_dang_nhap' => 'vnpay-patient-'.Str::random(10),
            'mat_khau' => 'test-password',
            'vai_tro' => 'BenhNhan',
            'trang_thai' => true,
        ]);
        $maChuyenKhoa = DB::table('chuyenkhoa')->insertGetId([
            'ten_chuyen_khoa' => 'Chuyên khoa VNPay test',
            'trang_thai' => 1,
        ]);
        $bacSi = BacSi::create([
            'ma_tk' => $doctorAccount->ma_tk,
            'ma_chuyen_khoa' => $maChuyenKhoa,
            'ho_ten' => 'Bác sĩ VNPay test',
            'luot_kham_toi_da_moi_ca' => 20,
        ]);
        $benhNhan = BenhNhan::create([
            'ma_tk' => $patientAccount->ma_tk,
            'ho_ten' => 'Bệnh nhân VNPay test',
        ]);
        $hoSo = HoSoBenhAn::create(['ma_benh_nhan' => $benhNhan->ma_benh_nhan]);
        $appointments = [];

        for ($index = 0; $index < $count; $index++) {
            $appointments[] = LichKham::create([
                'ma_ho_so' => $hoSo->ma_ho_so,
                'ma_bac_si' => $bacSi->ma_bs,
                'thoi_gian_den_kham' => now()->addDays($index + 1),
                'trang_thai' => 'cho_thanh_toan',
                'so_tien' => 150000,
            ]);
        }

        return [
            'patientAccount' => $patientAccount,
            'appointments' => $appointments,
        ];
    }

    private function signVnpayParams(array $parameters): array
    {
        $secureHashType = $parameters['vnp_SecureHashType'] ?? 'HmacSHA512';
        unset($parameters['vnp_SecureHashType']);
        ksort($parameters);

        $hashParts = [];
        foreach ($parameters as $key => $value) {
            $hashParts[] = urlencode($key).'='.urlencode((string) $value);
        }

        $parameters['vnp_SecureHashType'] = $secureHashType;
        $parameters['vnp_SecureHash'] = hash_hmac(
            'sha512',
            implode('&', $hashParts),
            config('services.vnpay.hash_secret')
        );

        return $parameters;
    }
}
