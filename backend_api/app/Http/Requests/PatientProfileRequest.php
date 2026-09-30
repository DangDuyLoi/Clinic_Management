<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class PatientProfileRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true; // We assume authentication is handled by middleware
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'ho_chu_lot' => 'required|string|max:255',
            'ten' => 'required|string|max:255',
            'ngay_sinh' => 'required|date',
            'dan_toc' => 'nullable|string|max:100',
            'gioi_tinh' => 'required|in:0,1',
            'nghe_nghiep' => 'nullable|string|max:255',
            'quan_he' => 'nullable|string|max:100',
            'so_dien_thoai' => 'required|string|max:15',
            'email' => 'nullable|email|max:255',
            'cccd' => 'nullable|string|max:20',
            'ho_chieu' => 'nullable|string|max:20',
            'so_dinh_danh' => 'nullable|string|max:20',
            'quoc_gia' => 'nullable|string|max:100',
            'tinh_thanh' => 'required|string|max:100',
            'phuong_xa' => 'required|string|max:100',
            'so_nha' => 'required|string|max:255',
            // User should pass ma_benh_nhan if the patient already exists, or it will be created
            'ma_benh_nhan' => 'nullable|exists:benh_nhan,ma_benh_nhan',
        ];
    }
}
