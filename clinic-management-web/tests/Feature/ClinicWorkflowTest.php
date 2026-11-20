<?php

namespace Tests\Feature;

use App\Models\BacSi;
use App\Models\BenhNhan;
use App\Models\ChiDinhDichVu;
use App\Models\ChiTietDonThuoc;
use App\Models\DichVu;
use App\Models\DonThuoc;
use App\Models\HoaDon;
use App\Models\HoSoBenhAn;
use App\Models\LichKham;
use App\Models\PhienKham;
use App\Models\TaiKhoan;
use App\Models\Thuoc;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;
use Tymon\JWTAuth\Facades\JWTAuth;

class ClinicWorkflowTest extends TestCase
{
    // Sử dụng DatabaseTransactions để tự động rollback, không làm bẩn DB thật
    use DatabaseTransactions;

    protected $tokenAdmin;

    protected $tokenBacSi;

    protected $tokenLeTan;

    protected $maBenhNhan;

    protected $maHoSo;

    protected $maBacSi;

    protected $maLichKham;

    protected $maPhienKham;

    protected $maHoaDon;

    protected function setUp(): void
    {
        parent::setUp();

        // 1. Tạo Ca làm việc
        $ca = DB::table('CaLamViec')->first();
        if (! $ca) {
            $maCa = DB::table('CaLamViec')->insertGetId([
                'ten_ca' => 'Ca sáng test',
                'gio_bat_dau' => '07:00:00',
                'gio_ket_thuc' => '12:00:00',
                'luot_kham_toi_da' => 50,
            ]);
        } else {
            $maCa = $ca->ma_ca;
        }

        // 2. Tạo Khung giờ
        $kg = DB::table('KhungGio')->first();
        if (! $kg) {
            $maKg = DB::table('KhungGio')->insertGetId([
                'ma_ca' => $maCa,
                'gio_bat_dau' => '08:00:00',
                'gio_ket_thuc' => '09:00:00',
                'luot_kham_toi_da' => 5,
            ]);
        } else {
            $maKg = $kg->ma_khung_gio;
        }

        // 3. Tạo Chuyên khoa
        $ck = DB::table('ChuyenKhoa')->first();
        if (! $ck) {
            $maCk = DB::table('ChuyenKhoa')->insertGetId(['ten_chuyen_khoa' => 'Nội tổng hợp', 'trang_thai' => 1]);
        } else {
            $maCk = $ck->ma_chuyen_khoa;
        }

        // 4. Tạo Tài khoản
        $tkAdmin = TaiKhoan::UpdateOrCreate(['ten_dang_nhap' => 'admin_test'], ['mat_khau' => Hash::make('123456'), 'vai_tro' => 'QuanTri', 'trang_thai' => true]);
        $tkBacSi = TaiKhoan::UpdateOrCreate(['ten_dang_nhap' => 'bacsi_test'], ['mat_khau' => Hash::make('123456'), 'vai_tro' => 'BacSi', 'trang_thai' => true]);
        $tkLeTan = TaiKhoan::UpdateOrCreate(['ten_dang_nhap' => 'letan_test'], ['mat_khau' => Hash::make('123456'), 'vai_tro' => 'LeTan', 'trang_thai' => true]);

        // 5. Tạo Bác sĩ
        $bacSi = BacSi::UpdateOrCreate(['ma_tk' => $tkBacSi->ma_tk], ['ho_ten' => 'BS. Test', 'ma_chuyen_khoa' => $maCk, 'luot_kham_toi_da_moi_ca' => 20]);
        $this->maBacSi = $bacSi->ma_bs;
        // 6. Tạo Bệnh nhân & Hồ sơ
        $randomPhone = '09'.rand(10000000, 99999999);
        $bn = BenhNhan::create(['ho_ten' => 'Bệnh Nhân Test', 'gioi_tinh' => 1, 'ngay_sinh' => '1990-01-01', 'so_dien_thoai' => $randomPhone]);
        $this->maBenhNhan = $bn->ma_benh_nhan;

        $hoSo = HoSoBenhAn::create(['ma_benh_nhan' => $this->maBenhNhan]);
        $this->maHoSo = $hoSo->ma_ho_so;

        // 7. Cấp JWT Token
        $this->tokenAdmin = JWTAuth::fromUser($tkAdmin);
        $this->tokenBacSi = JWTAuth::fromUser($tkBacSi);
        $this->tokenLeTan = JWTAuth::fromUser($tkLeTan);
    }

    /**
     * TC01: Kiểm thử Đăng ký tài khoản mới
     */
    public function test_user_can_register_successfully()
    {
        $tenDangNhap = 'testpatient_'.rand(1000, 9999);
        $phone = '09'.rand(10000000, 99999999);
        $response = $this->postJson('/api/auth/register', [
            'ten_dang_nhap' => $tenDangNhap,
            'phone_number' => $phone,
            'password' => 'Password123!',
            'password_confirmation' => 'Password123!',
            'ho_ten' => 'Nguyễn Văn Test',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure(['message', 'user']);
    }

    /**
     * TC02: Kiểm thử Đăng nhập hệ thống lấy JWT Token
     */
    public function test_user_can_login_and_receive_jwt_token()
    {
        $response = $this->postJson('/api/auth/login', [
            'ten_dang_nhap' => 'letan_test',
            'password' => '123456',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure(['status', 'token']);
    }

    /**
     * TC03: Kiểm thử Lấy danh mục chuyên khoa (Public Route)
     */
    public function test_can_fetch_specialties_list()
    {
        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenAdmin)
            ->getJson('/api/chuyen-khoa');

        $response->assertStatus(200)
            ->assertJsonStructure(['status', 'data']); // Backend trả về object thay vì mảng thuần
    }

    /**
     * TC04: Kiểm thử Đặt lịch khám bệnh hợp lệ
     */
    public function test_patient_can_book_appointment()
    {
        $maKg = DB::table('KhungGio')->first()->ma_khung_gio;
        $maCk = DB::table('ChuyenKhoa')->first()->ma_chuyen_khoa;

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenLeTan)
            ->postJson('/api/lich-kham', [
                'ma_benh_nhan' => $this->maBenhNhan,
                'ma_chuyen_khoa' => $maCk,
                'ngay_kham' => date('Y-m-d', strtotime('+1 day')),
                'ma_khung_gio' => $maKg,
                'hinh_thuc_kham' => 'DichVu',
            ]);

        if ($response->status() !== 201) {
            $this->fail('Lỗi API: '.json_encode($response->json()));
        }

        $response->assertStatus(201);
    }

    /**
     * TC05: Kiểm thử Đặt lịch khám với ngày trong quá khứ (Phải thất bại)
     */
    public function test_booking_fails_on_past_date()
    {
        $maKg = DB::table('KhungGio')->first()->ma_khung_gio;
        $maCk = DB::table('ChuyenKhoa')->first()->ma_chuyen_khoa;

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenLeTan)
            ->postJson('/api/lich-kham', [
                'ma_benh_nhan' => $this->maBenhNhan,
                'ma_chuyen_khoa' => $maCk,
                'ngay_kham' => '2020-01-01',
                'ma_khung_gio' => $maKg,
                'hinh_thuc_kham' => 'DichVu',
            ]);

        $response->assertStatus(422);
    }

    /**
     * TC06: Kiểm thử Xuất mã QR cho lịch hẹn
     */
    public function test_can_get_qr_code_for_appointment()
    {
        // Tạo một lịch khám giả lập trước
        $lk = LichKham::create(['ma_ho_so' => $this->maHoSo,
            'ma_bac_si' => $this->maBacSi,
            'thoi_gian_den_kham' => now(),
            'trang_thai' => 'cho_kham',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenLeTan)
            ->getJson("/api/lich-kham/{$lk->ma_luot_kham}/qr");

        $response->assertStatus(200)
            ->assertJsonStructure(['status', 'data' => ['qr_token', 'qr_url']]);
    }

    /**
     * TC07 & TC08: Kiểm thử Lễ tân quét mã QR
     */
    public function test_receptionist_can_scan_qr_code()
    {
        $lk = LichKham::create([
            'ma_ho_so' => $this->maHoSo, 'ma_bac_si' => $this->maBacSi, 'thoi_gian_den_kham' => now(),
            'trang_thai' => 'cho_kham', 'qr_token' => 'LICHKHAM_TEST_TOKEN_1',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenLeTan)
            ->postJson('/api/lich-kham/scan-qr', [
                'qr_token' => 'LICHKHAM_TEST_TOKEN_1',
            ]);

        $response->assertStatus(200);
    }

    /**
     * TC09 & TC10: Kiểm thử Check-in bằng QR và kích hoạt FCM Real-time
     */
    public function test_checkin_by_qr_triggers_fcm_notification()
    {
        $lk = LichKham::create(['ma_ho_so' => $this->maHoSo, 'ma_bac_si' => $this->maBacSi, 'thoi_gian_den_kham' => now(), 'trang_thai' => 'cho_kham']);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenLeTan)
            ->putJson("/api/lich-kham/{$lk->ma_luot_kham}/checkin-by-qr");

        $response->assertStatus(200)
            ->assertJsonFragment(['message' => 'Check-in thành công']);
    }

    /**
     * TC11: Kiểm thử Bác sĩ cập nhật phiên khám và chẩn đoán
     */
    public function test_doctor_can_update_medical_examination()
    {
        $lk = LichKham::create(['ma_ho_so' => $this->maHoSo, 'ma_bac_si' => $this->maBacSi, 'thoi_gian_den_kham' => now(), 'trang_thai' => 'dang_kham']);
        $pk = PhienKham::create(['ma_lich_dat' => $lk->ma_luot_kham, 'trang_thai' => 'ChoKetLuan']);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenBacSi)
            ->putJson("/api/phien-kham/{$pk->ma_phien_kham}", [
                'chan_doan_so_bo' => 'Viêm họng cấp',
                'chan_doan_cuoi_cung' => 'Theo dõi điều trị ngoại trú',
                'ghi_chu_y_te' => 'Uống nhiều nước',
            ]);

        $response->assertStatus(200);
    }

    public function test_finishing_unpaid_appointment_creates_pending_invoice_for_exam_fee()
    {
        $lk = LichKham::create([
            'ma_ho_so' => $this->maHoSo,
            'ma_bac_si' => $this->maBacSi,
            'thoi_gian_den_kham' => now(),
            'trang_thai' => 'cho_thanh_toan',
            'so_tien' => 150000,
            'hinh_thuc_kham' => 'DichVu',
        ]);
        $pk = PhienKham::create([
            'ma_lich_dat' => $lk->ma_luot_kham,
            'trang_thai' => 'ChoKetLuan',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenBacSi)
            ->postJson("/api/phien-kham/{$pk->ma_phien_kham}/finish");

        $response->assertOk()
            ->assertJsonPath('data.trang_thai', 'ChuaThanhToan');
        $this->assertDatabaseHas('hoadon', [
            'ma_phien_kham' => $pk->ma_phien_kham,
            'trang_thai' => 'ChuaThanhToan',
        ]);
        $this->assertSame(
            150000.0,
            (float) HoaDon::where('ma_phien_kham', $pk->ma_phien_kham)->value('tien_benh_nhan_tra')
        );
    }

    public function test_finishing_paid_appointment_does_not_charge_exam_fee_twice()
    {
        $lk = LichKham::create([
            'ma_ho_so' => $this->maHoSo,
            'ma_bac_si' => $this->maBacSi,
            'thoi_gian_den_kham' => now(),
            'trang_thai' => 'cho_kham',
            'so_tien' => 150000,
            'hinh_thuc_kham' => 'DichVu',
        ]);
        $pk = PhienKham::create([
            'ma_lich_dat' => $lk->ma_luot_kham,
            'trang_thai' => 'ChoKetLuan',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenBacSi)
            ->postJson("/api/phien-kham/{$pk->ma_phien_kham}/finish");

        $response->assertOk()
            ->assertJsonPath('data.trang_thai', 'DaThanhToan');
        $this->assertDatabaseHas('hoadon', [
            'ma_phien_kham' => $pk->ma_phien_kham,
            'trang_thai' => 'DaThanhToan',
        ]);
        $this->assertSame(
            0.0,
            (float) HoaDon::where('ma_phien_kham', $pk->ma_phien_kham)->value('tien_benh_nhan_tra')
        );
        $this->assertSame('HoanThanh', $pk->fresh()->trang_thai);
        $this->assertSame('hoan_thanh', $lk->fresh()->trang_thai);
        $this->assertNotNull(HoaDon::where('ma_phien_kham', $pk->ma_phien_kham)->value('ngay_thanh_toan'));
    }

    public function test_finishing_paid_appointment_charges_only_new_visit_services()
    {
        $lk = LichKham::create([
            'ma_ho_so' => $this->maHoSo,
            'ma_bac_si' => $this->maBacSi,
            'thoi_gian_den_kham' => now(),
            'trang_thai' => 'da_thanh_toan',
            'so_tien' => 150000,
            'hinh_thuc_kham' => 'DichVu',
        ]);
        $pk = PhienKham::create([
            'ma_lich_dat' => $lk->ma_luot_kham,
            'trang_thai' => 'ChoKetLuan',
        ]);
        $service = DichVu::create([
            'ten_dich_vu' => 'Dịch vụ bổ sung test',
            'don_gia' => 30000,
        ]);
        ChiDinhDichVu::create([
            'ma_phien_kham' => $pk->ma_phien_kham,
            'ma_dich_vu' => $service->ma_dich_vu,
            'trang_thai' => 'ChoThucHien',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenBacSi)
            ->postJson("/api/phien-kham/{$pk->ma_phien_kham}/finish");

        $response->assertOk()
            ->assertJsonPath('data.trang_thai', 'ChuaThanhToan');
        $this->assertSame(
            180000.0,
            (float) HoaDon::where('ma_phien_kham', $pk->ma_phien_kham)->value('tong_cong')
        );
        $this->assertSame(
            30000.0,
            (float) HoaDon::where('ma_phien_kham', $pk->ma_phien_kham)->value('tien_benh_nhan_tra')
        );
        $this->assertSame('hoan_tat_hoa_don', $lk->fresh()->trang_thai);
    }

    public function test_admin_can_mark_medicine_as_bhyt_covered()
    {
        $thuoc = Thuoc::create([
            'ten_thuoc' => 'Thuốc cập nhật BHYT test',
            'don_gia' => 1000,
            'so_luong_ton' => 10,
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenAdmin)
            ->putJson("/api/thuoc/{$thuoc->ma_thuoc}", ['is_bhyt' => true]);

        $response->assertOk()
            ->assertJsonPath('data.is_bhyt', true);
        $this->assertDatabaseHas('thuoc', [
            'ma_thuoc' => $thuoc->ma_thuoc,
            'is_bhyt' => 1,
        ]);
    }

    public function test_bhyt_visit_covers_bhyt_medicine_and_charges_non_bhyt_medicine()
    {
        $benhNhan = BenhNhan::findOrFail($this->maBenhNhan);
        $benhNhan->ma_bhyt = 'CH1234567890123';
        $benhNhan->save();

        $lichKham = LichKham::create([
            'ma_ho_so' => $this->maHoSo,
            'ma_bac_si' => $this->maBacSi,
            'thoi_gian_den_kham' => now(),
            'trang_thai' => 'cho_thanh_toan',
            'hinh_thuc_kham' => 'BHYT',
            'so_tien' => 1000,
        ]);
        $phienKham = PhienKham::create([
            'ma_lich_dat' => $lichKham->ma_luot_kham,
            'trang_thai' => 'ChoKetLuan',
        ]);
        $thuocBhyt = Thuoc::create([
            'ten_thuoc' => 'Thuốc BHYT test',
            'don_gia' => 100000,
            'so_luong_ton' => 1,
            'is_bhyt' => true,
        ]);
        $thuocNgoaiBhyt = Thuoc::create([
            'ten_thuoc' => 'Thuốc ngoài BHYT test',
            'don_gia' => 400000,
            'so_luong_ton' => 1,
            'is_bhyt' => false,
        ]);
        $donThuoc = DonThuoc::create([
            'ma_phien_kham' => $phienKham->ma_phien_kham,
            'tong_tien' => 500000,
        ]);
        ChiTietDonThuoc::create([
            'ma_don_thuoc' => $donThuoc->ma_don_thuoc,
            'ma_thuoc' => $thuocBhyt->ma_thuoc,
            'so_luong' => 1,
            'lieu_luong' => 'Ngày uống 1 viên',
            'thanh_tien' => 100000,
        ]);
        ChiTietDonThuoc::create([
            'ma_don_thuoc' => $donThuoc->ma_don_thuoc,
            'ma_thuoc' => $thuocNgoaiBhyt->ma_thuoc,
            'so_luong' => 1,
            'lieu_luong' => 'Ngày uống 1 viên',
            'thanh_tien' => 400000,
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenBacSi)
            ->postJson("/api/phien-kham/{$phienKham->ma_phien_kham}/finish");

        $response->assertOk();
        $this->assertSame(
            100800.0,
            (float) HoaDon::where('ma_phien_kham', $phienKham->ma_phien_kham)->value('tien_bhyt_tra')
        );
        $this->assertSame(
            400200.0,
            (float) HoaDon::where('ma_phien_kham', $phienKham->ma_phien_kham)->value('tien_benh_nhan_tra')
        );
    }

    public function test_service_visit_still_charges_bhyt_medicine()
    {
        $lichKham = LichKham::create([
            'ma_ho_so' => $this->maHoSo,
            'ma_bac_si' => $this->maBacSi,
            'thoi_gian_den_kham' => now(),
            'trang_thai' => 'cho_thanh_toan',
            'hinh_thuc_kham' => 'DichVu',
            'so_tien' => 1000,
        ]);
        $phienKham = PhienKham::create([
            'ma_lich_dat' => $lichKham->ma_luot_kham,
            'trang_thai' => 'ChoKetLuan',
        ]);
        $thuocBhyt = Thuoc::create([
            'ten_thuoc' => 'Thuốc BHYT dịch vụ test',
            'don_gia' => 100000,
            'so_luong_ton' => 1,
            'is_bhyt' => true,
        ]);
        $donThuoc = DonThuoc::create([
            'ma_phien_kham' => $phienKham->ma_phien_kham,
            'tong_tien' => 100000,
        ]);
        ChiTietDonThuoc::create([
            'ma_don_thuoc' => $donThuoc->ma_don_thuoc,
            'ma_thuoc' => $thuocBhyt->ma_thuoc,
            'so_luong' => 1,
            'lieu_luong' => 'Ngày uống 1 viên',
            'thanh_tien' => 100000,
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenBacSi)
            ->postJson("/api/phien-kham/{$phienKham->ma_phien_kham}/finish");

        $response->assertOk();
        $this->assertSame(
            0.0,
            (float) HoaDon::where('ma_phien_kham', $phienKham->ma_phien_kham)->value('tien_bhyt_tra')
        );
        $this->assertSame(
            101000.0,
            (float) HoaDon::where('ma_phien_kham', $phienKham->ma_phien_kham)->value('tien_benh_nhan_tra')
        );
    }

    public function test_receptionist_appointment_list_includes_invoice_payment_status()
    {
        $lk = LichKham::create([
            'ma_ho_so' => $this->maHoSo,
            'ma_bac_si' => $this->maBacSi,
            'thoi_gian_den_kham' => now(),
            'trang_thai' => 'hoan_tat_hoa_don',
            'hinh_thuc_kham' => 'DichVu',
        ]);
        $pk = PhienKham::create([
            'ma_lich_dat' => $lk->ma_luot_kham,
            'trang_thai' => 'ChoThanhToan',
        ]);
        $hd = HoaDon::create([
            'ma_phien_kham' => $pk->ma_phien_kham,
            'tien_kham_benh' => 150000,
            'tien_dich_vu' => 50000,
            'tien_thuoc' => 0,
            'tong_cong' => 200000,
            'tien_bhyt_tra' => 0,
            'tien_benh_nhan_tra' => 50000,
            'trang_thai' => 'ChuaThanhToan',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenLeTan)
            ->getJson('/api/lich-kham?per_page=100');

        $response->assertOk()->assertJsonFragment([
            'ma_hoa_don' => $hd->ma_hoa_don,
            'trang_thai' => 'ChuaThanhToan',
        ]);
    }

    public function test_receptionist_appointment_list_shows_paid_invoice_as_completed()
    {
        $lichKham = LichKham::create([
            'ma_ho_so' => $this->maHoSo,
            'ma_bac_si' => $this->maBacSi,
            'thoi_gian_den_kham' => now(),
            'trang_thai' => 'hoan_tat_hoa_don',
            'hinh_thuc_kham' => 'BHYT',
        ]);
        $phienKham = PhienKham::create([
            'ma_lich_dat' => $lichKham->ma_luot_kham,
            'trang_thai' => 'ChoThanhToan',
        ]);
        HoaDon::create([
            'ma_phien_kham' => $phienKham->ma_phien_kham,
            'tien_kham_benh' => 0,
            'tien_dich_vu' => 0,
            'tien_thuoc' => 0,
            'tong_cong' => 0,
            'tien_bhyt_tra' => 0,
            'tien_benh_nhan_tra' => 0,
            'trang_thai' => 'DaThanhToan',
            'ngay_thanh_toan' => now(),
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenLeTan)
            ->getJson('/api/lich-kham?trang_thai=hoan_thanh&per_page=100');

        $response->assertOk()->assertJsonFragment([
            'ma_luot_kham' => $lichKham->ma_luot_kham,
            'trang_thai' => 'hoan_thanh',
        ]);
    }

    /**
     * TC12: Kiểm thử Bác sĩ lập đơn thuốc
     */
    public function test_doctor_can_create_prescription()
    {
        $lk = LichKham::create(['ma_ho_so' => $this->maHoSo, 'ma_bac_si' => $this->maBacSi, 'thoi_gian_den_kham' => now(), 'trang_thai' => 'dang_kham']);
        $pk = PhienKham::create(['ma_lich_dat' => $lk->ma_luot_kham, 'trang_thai' => 'ChoKetLuan']);

        // Đảm bảo có thuốc mã 1 trong DB
        $thuoc = Thuoc::firstOrCreate(['ma_thuoc' => 1], ['ten_thuoc' => 'Paracetamol', 'don_gia' => 1000, 'so_luong_ton' => 100]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenBacSi)
            ->postJson('/api/don-thuoc', [
                'ma_phien_kham' => $pk->ma_phien_kham,
                'chi_tiet' => [
                    ['ma_thuoc' => $thuoc->ma_thuoc, 'so_luong' => 10, 'lieu_luong' => 'Sáng 1 viên, chiều 1 viên'], // Đổi lieu_dung -> lieu_luong
                ],
            ]);

        $response->assertStatus(201); // API trả về 201 Created
    }

    /**
     * TC13: Kiểm thử Khởi tạo thanh toán VNPay
     */
    public function test_can_initiate_vnpay_payment()
    {
        // Cần có Hóa Đơn thì mới tạo được link VNPay
        $lk = LichKham::create(['ma_ho_so' => $this->maHoSo, 'ma_bac_si' => $this->maBacSi, 'thoi_gian_den_kham' => now(), 'trang_thai' => 'cho_thanh_toan']);
        $pk = PhienKham::create(['ma_lich_dat' => $lk->ma_luot_kham, 'trang_thai' => 'ChoThanhToan']);
        $hd = HoaDon::create([
            'ma_phien_kham' => $pk->ma_phien_kham,
            'tien_kham_benh' => 150000,
            'tien_dich_vu' => 0,
            'tien_thuoc' => 0,
            'tong_cong' => 150000,
            'tien_bhyt_tra' => 0,
            'tien_benh_nhan_tra' => 150000,
            'trang_thai' => 'ChuaThanhToan',
            'ngay_tao' => now(),
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->tokenLeTan)
            ->postJson("/api/vnpay/create-payment/{$hd->ma_hoa_don}");

        $response->assertStatus(200)
            ->assertJsonStructure(['status', 'payment_url']);
    }
}
