<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class ValidBhyt implements ValidationRule
{
    protected $ngaySinh;

    public function __construct($ngaySinh)
    {
        $this->ngaySinh = $ngaySinh;
    }

    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (empty($value)) return;

        // 1. Kiểm tra độ dài 15 ký tự
        if (strlen($value) !== 15) {
            $fail('Mã thẻ BHYT phải có đúng 15 ký tự.');
            return;
        }

        // 2. Tách các thành phần
        $maDoiTuong = substr($value, 0, 2); // 2 ký tự đầu
        $mucHuong = substr($value, 2, 1);   // Ký tự thứ 3
        $maTinh = substr($value, 3, 2);     // Ký tự 4-5
        $soDinhDanh = substr($value, 5);    // 10 ký tự cuối

        // 3. KIỂM TRA CHÉO: Mã đối tượng VÀ Mức hưởng phải khớp với CSDL
        $loaiDoiTuong = DB::table('LoaiDoiTuongBHYT')->where('ma_doi_tuong', $maDoiTuong)->first();
        
        if (!$loaiDoiTuong) {
            $fail("Mã đối tượng '{$maDoiTuong}' không hợp lệ.");
            return;
        }

        // Kiểm tra ký tự thứ 3 có trùng với mức hưởng quy định của mã đối tượng không
        if ((string)$loaiDoiTuong->muc_huong !== $mucHuong) {
            $fail("Mức hưởng '{$mucHuong}' không khớp với mã đối tượng '{$maDoiTuong}'. Mã này phải có mức hưởng là '{$loaiDoiTuong->muc_huong}'.");
            return;
        }

        // 4. Kiểm tra ký tự 4-5 (Mã tỉnh thành)
        $isValidTinh = DB::table('TinhThanh')->where('ma_tinh', $maTinh)->exists();
        if (!$isValidTinh) {
            $fail("Mã tỉnh thành '{$maTinh}' không hợp lệ.");
            return;
        }

        // 5. Kiểm tra 10 ký tự cuối (phải là số)
        if (!ctype_digit($soDinhDanh)) {
            $fail('10 ký tự cuối của mã BHYT phải là chữ số.');
            return;
        }

        // 6. RÀNG BUỘC CHÉO: KIỂM TRA TUỔI VỚI MÃ ĐỐI TƯỢNG
        if ($this->ngaySinh) {
            $age = Carbon::parse($this->ngaySinh)->age;

            if ($maDoiTuong === 'TE' && $age >= 6) {
                $fail('Mã TE (Trẻ em) chỉ áp dụng cho bệnh nhân dưới 6 tuổi.');
            } elseif ($maDoiTuong === 'HS' && ($age < 6 || $age > 18)) {
                $fail('Mã HS (Học sinh) chỉ áp dụng cho độ tuổi từ 6 đến 18.');
            } elseif ($maDoiTuong === 'SV' && ($age < 18 || $age > 30)) {
                $fail('Mã SV (Sinh viên) chỉ áp dụng cho độ tuổi từ 18 đến 30.');
            } elseif ($maDoiTuong === 'HT' && $age < 50) {
                $fail('Mã HT (Hưu trí) chỉ áp dụng cho người từ 50 tuổi trở lên.');
            }
        }
    }
}