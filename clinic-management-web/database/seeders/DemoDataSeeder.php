<?php

namespace Database\Seeders;

use App\Models\BacSi;
use App\Models\BenhNhan;
use App\Models\CaLamViec;
use App\Models\ChuyenKhoa;
use App\Models\DichVu;
use App\Models\HoaDon;
use App\Models\HoSoBenhAn;
use App\Models\KhungGio;
use App\Models\LichKham;
use App\Models\PhienKham;
use App\Models\TaiKhoan;
use App\Models\Thuoc;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use RuntimeException;

class DemoDataSeeder extends Seeder
{
    public function run(): void
    {
        if (app()->environment('production')) {
            throw new RuntimeException('Demo data cannot be seeded in production.');
        }

        $password = config('demo.account_password');

        if (! is_string($password) || strlen($password) < 12) {
            throw new RuntimeException('Set STAGING_DEMO_PASSWORD to at least 12 characters before seeding demo data.');
        }

        DB::transaction(function () use ($password): void {
            $this->createAccount('demo-admin', 'Quản trị viên Demo', 'QuanTri', $password);
            $this->createAccount('demo-reception', 'Lễ tân Demo', 'LeTan', $password);
            $doctorAccount = $this->createAccount('demo-doctor', 'Bác sĩ Demo', 'BacSi', $password);
            $patientAccount = $this->createAccount('0900000001', 'Bệnh nhân Demo', 'BenhNhan', $password);

            $specialty = ChuyenKhoa::updateOrCreate(
                ['ten_chuyen_khoa' => 'Nội tổng hợp'],
                [
                    'mo_ta' => 'Chuyên khoa mẫu dành cho môi trường staging.',
                    'gia_kham' => 150000,
                    'phong_kham' => 'Phòng 101 - Tầng 1',
                    'trang_thai' => true,
                ],
            );

            $doctor = BacSi::updateOrCreate(
                ['ma_tk' => $doctorAccount->ma_tk],
                [
                    'ma_chuyen_khoa' => $specialty->ma_chuyen_khoa,
                    'ho_ten' => 'Bác sĩ Demo',
                    'trinh_do' => 'Bác sĩ',
                    'luot_kham_toi_da_moi_ca' => 20,
                ],
            );

            $patient = BenhNhan::updateOrCreate(
                ['so_dien_thoai' => '0900000001'],
                [
                    'ma_tk' => $patientAccount->ma_tk,
                    'ho_ten' => 'Bệnh nhân Demo',
                    'ngay_sinh' => '1990-01-01',
                    'gioi_tinh' => 1,
                    'email' => 'demo.patient@example.test',
                    'dia_chi' => 'Địa chỉ dữ liệu giả',
                ],
            );

            $patientRecord = HoSoBenhAn::updateOrCreate(
                ['ma_benh_nhan' => $patient->ma_benh_nhan],
                [
                    'tien_su_benh' => 'Hồ sơ giả phục vụ kiểm thử staging.',
                    'nhom_mau' => 'O+',
                ],
            );

            DichVu::updateOrCreate(
                ['ten_dich_vu' => 'Xét nghiệm tổng quát (demo)'],
                [
                    'don_gia' => 100000,
                    'mo_ta' => 'Dịch vụ giả phục vụ kiểm thử staging.',
                ],
            );

            Thuoc::updateOrCreate(
                ['ten_thuoc' => 'Paracetamol 500 mg (demo)'],
                [
                    'don_vi_tinh' => 'Viên',
                    'don_gia' => 1000,
                    'so_luong_ton' => 100,
                    'is_bhyt' => true,
                ],
            );

            Thuoc::updateOrCreate(
                ['ten_thuoc' => 'Vitamin C 500 mg (demo)'],
                [
                    'don_vi_tinh' => 'Viên',
                    'don_gia' => 1500,
                    'so_luong_ton' => 100,
                    'is_bhyt' => false,
                ],
            );

            $shift = CaLamViec::updateOrCreate(
                ['ten_ca' => 'Ca sáng (demo)'],
                [
                    'gio_bat_dau' => '08:00:00',
                    'gio_ket_thuc' => '12:00:00',
                    'luot_kham_toi_da' => 20,
                ],
            );

            KhungGio::updateOrCreate(
                [
                    'ma_ca' => $shift->ma_ca,
                    'gio_bat_dau' => '08:00:00',
                    'gio_ket_thuc' => '08:30:00',
                ],
                ['luot_kham_toi_da' => 3],
            );

            $appointment = LichKham::updateOrCreate(
                ['qr_token' => 'demo-staging-pending-payment'],
                [
                    'ma_ho_so' => $patientRecord->ma_ho_so,
                    'ma_bac_si' => $doctor->ma_bs,
                    'so_thu_tu' => 9001,
                    'thoi_gian_den_kham' => now()->subDay()->setTime(9, 0),
                    'trang_thai' => 'hoan_thanh',
                    'chan_doan' => 'Dữ liệu khám giả',
                    'hinh_thuc_kham' => 'DichVu',
                    'is_bhyt' => false,
                    'ma_the_bhyt' => null,
                    'so_tien' => 0,
                ],
            );

            $session = PhienKham::updateOrCreate(
                ['ma_lich_dat' => $appointment->ma_luot_kham],
                [
                    'chan_doan_so_bo' => 'Khám tổng quát (dữ liệu demo)',
                    'chan_doan_cuoi_cung' => 'Không có kết luận y tế thật.',
                    'trang_thai' => 'HoanThanh',
                    'ngay_tao' => now()->subDay(),
                    'phong_kham' => $specialty->phong_kham,
                ],
            );

            HoaDon::updateOrCreate(
                ['ma_phien_kham' => $session->ma_phien_kham],
                [
                    'tien_kham_benh' => 150000,
                    'tien_dich_vu' => 0,
                    'tien_thuoc' => 0,
                    'tong_cong' => 150000,
                    'tien_bhyt_tra' => 0,
                    'tien_benh_nhan_tra' => 150000,
                    'trang_thai' => 'ChuaThanhToan',
                    'ngay_tao' => now()->subDay(),
                    'ngay_thanh_toan' => null,
                ],
            );
        });
    }

    private function createAccount(string $username, string $fullName, string $role, string $password): TaiKhoan
    {
        return TaiKhoan::updateOrCreate(
            ['ten_dang_nhap' => $username],
            [
                'mat_khau' => Hash::make($password),
                'ho_ten' => $fullName,
                'vai_tro' => $role,
                'trang_thai' => true,
            ],
        );
    }
}
