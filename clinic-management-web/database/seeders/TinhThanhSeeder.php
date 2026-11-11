<?php
// database/seeders/TinhThanhSeeder.php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TinhThanhSeeder extends Seeder
{
    public function run(): void
    {
        $ds = [
            ['01', 'Thành phố Hà Nội', 'ThanhPho', null],
            ['04', 'Tỉnh Cao Bằng', 'Tinh', null],
            ['08', 'Tỉnh Tuyên Quang', 'Tinh', 'Sáp nhập Hà Giang + Tuyên Quang'],
            ['11', 'Tỉnh Điện Biên', 'Tinh', null],
            ['12', 'Tỉnh Lai Châu', 'Tinh', null],
            ['14', 'Tỉnh Sơn La', 'Tinh', null],
            ['15', 'Tỉnh Lào Cai', 'Tinh', 'Sáp nhập Lào Cai + Yên Bái'],
            ['19', 'Tỉnh Thái Nguyên', 'Tinh', 'Sáp nhập Thái Nguyên + Bắc Kạn'],
            ['20', 'Tỉnh Lạng Sơn', 'Tinh', null],
            ['22', 'Tỉnh Quảng Ninh', 'Tinh', null],
            ['24', 'Tỉnh Bắc Ninh', 'Tinh', 'Sáp nhập Bắc Ninh + Bắc Giang'],
            ['25', 'Tỉnh Phú Thọ', 'Tinh', 'Sáp nhập Hòa Bình + Vĩnh Phúc + Phú Thọ'],
            ['31', 'Thành phố Hải Phòng', 'ThanhPho', 'Sáp nhập Hải Phòng + Hải Dương'],
            ['33', 'Tỉnh Hưng Yên', 'Tinh', 'Sáp nhập Hưng Yên + Thái Bình'],
            ['37', 'Tỉnh Ninh Bình', 'Tinh', 'Sáp nhập Hà Nam + Nam Định + Ninh Bình'],
            ['38', 'Tỉnh Thanh Hóa', 'Tinh', null],
            ['40', 'Tỉnh Nghệ An', 'Tinh', null],
            ['42', 'Tỉnh Hà Tĩnh', 'Tinh', null],
            ['44', 'Tỉnh Quảng Trị', 'Tinh', 'Sáp nhập Quảng Bình + Quảng Trị'],
            ['46', 'Thành phố Huế', 'ThanhPho', null],
            ['48', 'Thành phố Đà Nẵng', 'ThanhPho', 'Sáp nhập Quảng Nam + Đà Nẵng'],
            ['51', 'Tỉnh Quảng Ngãi', 'Tinh', 'Sáp nhập Kon Tum + Quảng Ngãi'],
            ['52', 'Tỉnh Gia Lai', 'Tinh', 'Sáp nhập Gia Lai + Bình Định'],
            ['56', 'Tỉnh Khánh Hòa', 'Tinh', 'Sáp nhập Khánh Hòa + Ninh Thuận'],
            ['66', 'Tỉnh Đắk Lắk', 'Tinh', 'Sáp nhập Đắk Lắk + Phú Yên'],
            ['68', 'Tỉnh Lâm Đồng', 'Tinh', 'Sáp nhập Lâm Đồng + Đắk Nông + Bình Thuận'],
            ['75', 'Tỉnh Đồng Nai', 'Tinh', 'Sáp nhập Đồng Nai + Bình Phước'],
            ['79', 'Thành phố Hồ Chí Minh', 'ThanhPho', 'Sáp nhập TP.HCM + Bình Dương + Bà Rịa - Vũng Tàu'],
            ['80', 'Tỉnh Tây Ninh', 'Tinh', 'Sáp nhập Tây Ninh + Long An'],
            ['82', 'Tỉnh Đồng Tháp', 'Tinh', 'Sáp nhập Đồng Tháp + Tiền Giang'],
            ['86', 'Tỉnh Vĩnh Long', 'Tinh', 'Sáp nhập Vĩnh Long + Bến Tre + Trà Vinh'],
            ['91', 'Tỉnh An Giang', 'Tinh', 'Sáp nhập An Giang + Kiên Giang'],
            ['92', 'Thành phố Cần Thơ', 'ThanhPho', 'Sáp nhập Cần Thơ + Sóc Trăng + Hậu Giang'],
            ['96', 'Tỉnh Cà Mau', 'Tinh', 'Sáp nhập Cà Mau + Bạc Liêu'],
        ];

        foreach ($ds as [$ma, $ten, $loai, $ghiChu]) {
            DB::table('TinhThanh')->updateOrInsert(
                ['ma_tinh' => $ma],
                [
                    'ten_tinh' => $ten,
                    'loai'     => $loai,
                    'ghi_chu'  => $ghiChu,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }

        // Bổ sung mã đặc biệt cho BHYT (97 - Quốc phòng, 98 - Công an)
        DB::table('TinhThanh')->updateOrInsert(
            ['ma_tinh' => '97'],
            [
                'ten_tinh' => 'Bảo hiểm xã hội Bộ Quốc phòng',
                'loai'     => 'DacBiet',
                'ghi_chu'  => 'Mã dành riêng cho thẻ BHYT do BHXH Bộ Quốc phòng cấp',
                'created_at' => now(),
                'updated_at' => now(),
            ]
        );
        DB::table('TinhThanh')->updateOrInsert(
            ['ma_tinh' => '98'],
            [
                'ten_tinh' => 'Bảo hiểm xã hội Công an nhân dân',
                'loai'     => 'DacBiet',
                'ghi_chu'  => 'Mã dành riêng cho thẻ BHYT do BHXH Công an nhân dân cấp',
                'created_at' => now(),
                'updated_at' => now(),
            ]
        );
    }
}