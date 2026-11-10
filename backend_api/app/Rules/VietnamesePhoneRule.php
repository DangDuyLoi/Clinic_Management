<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

class VietnamesePhoneRule implements ValidationRule
{
    /**
     * Regex chuẩn mạng viễn thông di động Việt Nam (10 số với đầu 0, hoặc chuẩn E.164 với +84)
     * Đầu số di động hợp lệ sau quy hoạch viễn thông: 03x, 05x, 07x, 08x, 09x (+843x, +845x, +847x, +848x, +849x)
     */
    protected string $pattern = '/^(0|\+84)(3|5|7|8|9)[0-9]{8}$/';

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

        $phone = trim((string)$value);

        if (!preg_match($this->pattern, $phone)) {
            $fail("{$attribute} không đúng định dạng số điện thoại di động Việt Nam (bắt đầu bằng 0 hoặc +84 kết hợp với các đầu số 3, 5, 7, 8, 9 và gồm 10 chữ số).");
        }
    }
}

