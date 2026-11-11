<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

class ValidVNPhone implements ValidationRule
{
    protected string $pattern = '/^(0|\+84)(3|5|7|8|9)[0-9]{8}$/';

    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (empty($value)) return;

        if (!preg_match($this->pattern, trim((string)$value))) {
            $fail("Số điện thoại không đúng định dạng Việt Nam (10 số, bắt đầu bằng 03, 05, 07, 08, 09).");
        }
    }
}