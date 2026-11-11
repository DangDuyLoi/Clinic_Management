<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Support\Facades\DB;
class ValidCccd implements ValidationRule
{
    protected $ngaySinh;
    protected $gioiTinh;
    protected array $provinceMapping = [
        '001' => '01', // Hà Nội
        '002' => '08', // Hà Giang -> Tuyên Quang
        '004' => '04', // Cao Bằng
        '006' => '19', // Bắc Kạn -> Thái Nguyên
        '008' => '08', // Tuyên Quang
        '010' => '15', // Lào Cai
        '011' => '11', // Điện Biên
        '012' => '12', // Lai Châu
        '014' => '14', // Sơn La
        '015' => '15', // Yên Bái -> Lào Cai
        '017' => '25', // Hòa Bình -> Phú Thọ
        '019' => '19', // Thái Nguyên
        '020' => '20', // Lạng Sơn
        '022' => '22', // Quảng Ninh
        '024' => '24', // Bắc Giang -> Bắc Ninh
        '025' => '25', // Phú Thọ
        '026' => '25', // Vĩnh Phúc -> Phú Thọ
        '027' => '24', // Bắc Ninh
        '030' => '31', // Hải Dương -> Hải Phòng
        '031' => '31', // Hải Phòng
        '033' => '33', // Hưng Yên
        '034' => '33', // Thái Bình -> Hưng Yên
        '035' => '37', // Hà Nam -> Ninh Bình
        '036' => '37', // Nam Định -> Ninh Bình
        '037' => '37', // Ninh Bình
        '038' => '38', // Thanh Hóa
        '040' => '40', // Nghệ An
        '042' => '42', // Hà Tĩnh
        '044' => '44', // Quảng Bình -> Quảng Trị
        '045' => '44', // Quảng Trị
        '046' => '46', // Thừa Thiên Huế
        '048' => '48', // Đà Nẵng
        '049' => '48', // Quảng Nam -> Đà Nẵng
        '051' => '51', // Quảng Ngãi
        '052' => '52', // Bình Định -> Gia Lai
        '054' => '66', // Phú Yên -> Đắk Lắk
        '056' => '56', // Khánh Hòa
        '058' => '56', // Ninh Thuận -> Khánh Hòa
        '060' => '68', // Bình Thuận -> Lâm Đồng
        '062' => '51', // Kon Tum -> Quảng Ngãi
        '064' => '52', // Gia Lai
        '066' => '66', // Đắk Lắk
        '067' => '68', // Đắk Nông -> Lâm Đồng
        '068' => '68', // Lâm Đồng
        '070' => '75', // Bình Phước -> Đồng Nai
        '072' => '80', // Tây Ninh
        '074' => '79', // Bình Dương -> TP.HCM
        '075' => '75', // Đồng Nai
        '077' => '79', // Bà Rịa - Vũng Tàu -> TP.HCM
        '079' => '79', // TP.HCM
        '080' => '80', // Long An -> Tây Ninh
        '082' => '82', // Tiền Giang -> Đồng Tháp
        '083' => '86', // Bến Tre -> Vĩnh Long
        '084' => '86', // Trà Vinh -> Vĩnh Long
        '086' => '86', // Vĩnh Long
        '087' => '82', // Đồng Tháp
        '089' => '91', // An Giang
        '091' => '91', // Kiên Giang -> An Giang
        '092' => '92', // Cần Thơ
        '093' => '92', // Hậu Giang -> Cần Thơ
        '094' => '92', // Sóc Trăng -> Cần Thơ
        '095' => '96', // Bạc Liêu -> Cà Mau
        '096' => '96', // Cà Mau
    ];


    public function __construct($ngaySinh, $gioiTinh)
    {
        $this->ngaySinh = $ngaySinh;
        $this->gioiTinh = $gioiTinh;
    }

    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (empty($value)) return;

        $cccd = trim((string)$value);

        if (strlen($cccd) !== 12 || !ctype_digit($cccd)) {
            $fail("Số CCCD phải bao gồm chính xác 12 chữ số.");
            return;
        }

        $oldProvinceCode = substr($cccd, 0, 3);
        
        if (!array_key_exists($oldProvinceCode, $this->provinceMapping)) {
            $fail("3 ký tự đầu của CCCD ('{$oldProvinceCode}') không phải là mã tỉnh/thành phố hợp lệ của Việt Nam.");
            return;
        }
        $newProvinceCode = $this->provinceMapping[$oldProvinceCode];
        $isValidTinh = DB::table('TinhThanh')->where('ma_tinh', $newProvinceCode)->exists();
        
        if (!$isValidTinh) {
            // Lỗi này hiếm khi xảy ra, chỉ xảy ra nếu bảng TinhThanh thiếu dữ liệu
            $fail("Lỗi hệ thống: Mã tỉnh mới ({$newProvinceCode}) không tồn tại trong danh mục TinhThanh.");
            return;
        }


        // Kiểm tra chéo nếu có truyền ngày sinh và giới tính
        if ($this->ngaySinh && $this->gioiTinh !== null) {
            $genderCenturyCode = (int)$cccd[3];
            $expectedGender = ($genderCenturyCode % 2 === 0) ? 1 : 0;
            $centuryBase = 1900 + ((int)floor($genderCenturyCode / 2) * 100);
            $yearLast2Digits = (int)substr($cccd, 4, 2);
            $expectedBirthYear = $centuryBase + $yearLast2Digits;
            $actualBirthYear = (int)date('Y', strtotime($this->ngaySinh));

            if ($actualBirthYear !== $expectedBirthYear) {
                $fail("Năm sinh không khớp với dữ liệu từ CCCD (CCCD ghi nhận năm {$expectedBirthYear}).");
                return;
            }

            // Chuyển đổi giới tính web (1: Nam, 0: Nữ) để so sánh
            $webGender = ($this->gioiTinh == 1 || $this->gioiTinh == 'Nam' || $this->gioiTinh == '1') ? 1 : 0;
            
            if ($webGender !== $expectedGender) {
                $fail("Giới tính không khớp với dữ liệu từ CCCD.");
            }
        }
    }
}