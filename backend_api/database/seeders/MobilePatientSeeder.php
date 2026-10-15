<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class MobilePatientSeeder extends Seeder
{
    public function run()
    {
        $passHash = Hash::make('123456');
        $loiPassHash = Hash::make('SWKH@k4i');

        // 1. Tài khoản User cho Mobile
        $mobileUsers = [
            ['phone_number' => '+84374244315', 'name' => 'Đặng Duy Lợi', 'password' => $loiPassHash],
            ['phone_number' => '0374244315',   'name' => 'Đặng Duy Lợi', 'password' => $loiPassHash],
            ['phone_number' => '0901234567',   'name' => 'Nguyễn Văn A', 'password' => $passHash],
            ['phone_number' => '+84901234567', 'name' => 'Nguyễn Văn A', 'password' => $passHash],
        ];

        foreach ($mobileUsers as $u) {
            $existing = DB::table('users')->where('phone_number', $u['phone_number'])->first();
            if ($existing) {
                DB::table('users')->where('id', $existing->id)->update([
                    'name' => $u['name'],
                    'password' => $u['password'],
                    'updated_at' => now(),
                ]);
            } else {
                DB::table('users')->insert([
                    'phone_number' => $u['phone_number'],
                    'name' => $u['name'],
                    'password' => $u['password'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }

        // Đảm bảo tất cả bệnh nhân trong bảng benh_nhan đều có tài khoản users (mật khẩu mặc định: 123456)
        $allPatients = DB::table('benh_nhan')->get();
        foreach ($allPatients as $p) {
            if (!empty($p->so_dien_thoai)) {
                $rawP = trim($p->so_dien_thoai);
                $p0 = str_starts_with($rawP, '+84') ? '0' . substr($rawP, 3) : $rawP;
                $p84 = str_starts_with($rawP, '0') ? '+84' . substr($rawP, 1) : $rawP;

                foreach (array_unique([$rawP, $p0, $p84]) as $targetPhone) {
                    $exist = DB::table('users')->where('phone_number', $targetPhone)->first();
                    if ($exist) {
                        DB::table('users')->where('id', $exist->id)->update([
                            'password' => $passHash,
                            'updated_at' => now(),
                        ]);
                    } else {
                        DB::table('users')->insert([
                            'phone_number' => $targetPhone,
                            'name' => $p->ho_ten,
                            'password' => $passHash,
                            'created_at' => now(),
                            'updated_at' => now(),
                        ]);
                    }
                }
            }
        }

        // 2. Bệnh nhân #1
        $existingBn = DB::table('benh_nhan')->where('ma_benh_nhan', 1)->first();
        if ($existingBn) {
            DB::table('benh_nhan')->where('ma_benh_nhan', 1)->update([
                'ho_ten' => 'Nguyễn Văn A',
                'so_dien_thoai' => '0901234567',
                'ngay_sinh' => '1990-05-15',
                'gioi_tinh' => 1,
                'dia_chi' => '123 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
                'updated_at' => now(),
            ]);
        } else {
            DB::table('benh_nhan')->insert([
                'ma_benh_nhan' => 1,
                'ho_ten' => 'Nguyễn Văn A',
                'so_dien_thoai' => '0901234567',
                'ngay_sinh' => '1990-05-15',
                'gioi_tinh' => 1,
                'dia_chi' => '123 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // 3. Hồ sơ bệnh án #1
        $existingHs = DB::table('ho_so_benh_an')->where('ma_ho_so', 1)->first();
        $hsData = [
            'ma_benh_nhan' => 1,
            'ho_chu_lot' => 'Nguyễn',
            'ten' => 'Văn A',
            'ngay_sinh' => '1990-05-15',
            'gioi_tinh' => 1,
            'so_dien_thoai' => '0901234567',
            'email' => 'nguyenvana@gmail.com',
            'cccd' => '079090000001',
            'quoc_gia' => 'Việt Nam',
            'tinh_thanh' => 'TP. Hồ Chí Minh',
            'phuong_xa' => 'Phường Bến Nghé',
            'so_nha' => '123 Nguyễn Huệ',
            'tien_su_benh' => 'Dị ứng hải sản',
            'nhom_mau' => 'O',
        ];
        if ($existingHs) {
            DB::table('ho_so_benh_an')->where('ma_ho_so', 1)->update(array_merge($hsData, ['updated_at' => now()]));
        } else {
            DB::table('ho_so_benh_an')->insert(array_merge(['ma_ho_so' => 1], $hsData, ['created_at' => now(), 'updated_at' => now()]));
        }

        // 4. Lịch khám mẫu cho Mobile
        $today = Carbon::today()->format('Y-m-d');
        $tomorrow = Carbon::tomorrow()->format('Y-m-d');
        $nextWeek = Carbon::today()->addDays(3)->format('Y-m-d');

        $sampleAppointments = [
            [
                'ma_luot_kham' => 101,
                'ma_ho_so' => 1,
                'ma_bac_si' => 1,
                'thoi_gian_den_kham' => "{$today} 08:30:00",
                'trang_thai' => 'cho_kham',
                'chan_doan' => null,
            ],
            [
                'ma_luot_kham' => 102,
                'ma_ho_so' => 1,
                'ma_bac_si' => 2,
                'thoi_gian_den_kham' => "{$tomorrow} 09:30:00",
                'trang_thai' => 'da_thanh_toan',
                'chan_doan' => null,
            ],
            [
                'ma_luot_kham' => 103,
                'ma_ho_so' => 1,
                'ma_bac_si' => 3,
                'thoi_gian_den_kham' => "{$nextWeek} 14:00:00",
                'trang_thai' => 'cho_thanh_toan',
                'chan_doan' => null,
            ],
        ];

        foreach ($sampleAppointments as $app) {
            $exists = DB::table('luot_kham')->where('ma_luot_kham', $app['ma_luot_kham'])->first();
            if ($exists) {
                DB::table('luot_kham')->where('ma_luot_kham', $app['ma_luot_kham'])->update(array_merge($app, ['updated_at' => now()]));
            } else {
                DB::table('luot_kham')->insert(array_merge($app, ['created_at' => now(), 'updated_at' => now()]));
            }
        }

        $this->command->info('Đã đồng bộ dữ liệu phân hệ Patient Mobile thành công!');
    }
}
