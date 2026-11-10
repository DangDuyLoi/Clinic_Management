<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

class BhytRule implements ValidationRule
{
    /**
     * Danh sách mã đối tượng tham gia BHYT hợp lệ theo quy định của BHXH Việt Nam (QĐ 1666/QĐ-BHXH)
     */
    protected array $validSubjectCodes = [
        // Người lao động & người sử dụng lao động đóng
        'DN', 'HX', 'CH', 'NN', 'TK', 'HC', 'XK',
        // Tổ chức BHXH đóng
        'HT', 'TB', 'NO',
        // Ngân sách Nhà nước đóng
        'QN', 'CA', 'CY', 'CB', 'KC', 'TE', 'BT', 'HN', 'DT', 'DK', 'XD', 'TS', 'TC',
        // Ngân sách Nhà nước hỗ trợ mức đóng
        'CN', 'HS', 'SV', 'GB',
        // Tham gia theo hộ gia đình & đối tượng khác
        'GD', 'PV'
    ];

    /**
     * Run the validation rule.
     *
     * @param  \Closure(string, ?string=): \Illuminate\Translation\PotentiallyTranslatedString  $fail
     */
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (empty($value)) {
            return;
        }

        $code = strtoupper(trim((string)$value));

        // 1. Kiểm tra độ dài bắt buộc 15 ký tự
        if (strlen($code) !== 15) {
            $fail("Mã thẻ BHYT phải có chính xác 15 ký tự theo quy định BHXH Việt Nam.");
            return;
        }

        // 2. Ký tự 1-2: Mã đối tượng tham gia
        $subjectCode = substr($code, 0, 2);
        if (!in_array($subjectCode, $this->validSubjectCodes, true)) {
            $fail("Hai ký tự đầu của mã thẻ BHYT ('{$subjectCode}') không thuộc danh mục mã đối tượng hợp lệ của BHXH.");
            return;
        }

        // 3. Ký tự thứ 3: Mức hưởng BHYT (từ 1 đến 5)
        $benefitLevel = substr($code, 2, 1);
        if (!in_array($benefitLevel, ['1', '2', '3', '4', '5'], true)) {
            $fail("Ký tự thứ 3 của thẻ BHYT biểu thị mức hưởng, phải là số từ 1 đến 5.");
            return;
        }

        // 4. Ký tự 4-5: Mã tỉnh/thành phố cấp thẻ (từ 01 đến 96)
        $provinceCode = substr($code, 3, 2);
        if (!ctype_digit($provinceCode) || (int)$provinceCode < 1 || (int)$provinceCode > 96) {
            $fail("Ký tự thứ 4 và 5 của mã thẻ BHYT biểu thị mã tỉnh/thành phố, phải là số từ 01 đến 96.");
            return;
        }

        // 5. 10 ký tự cuối: Mã số định danh BHXH của cá nhân (phải là 10 chữ số)
        $personalCode = substr($code, 5, 10);
        if (!ctype_digit($personalCode) || strlen($personalCode) !== 10) {
            $fail("10 ký tự cuối của mã thẻ BHYT phải là dãy số định danh BHXH duy nhất gồm 10 chữ số.");
            return;
        }
    }
}

