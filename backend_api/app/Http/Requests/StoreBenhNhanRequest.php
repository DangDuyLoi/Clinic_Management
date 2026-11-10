<?php

namespace App\Http\Requests;

use App\Models\HoSoBenhAn;
use App\Rules\BhytRule;
use App\Rules\VietnamesePhoneRule;
use Carbon\Carbon;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Validation\Validator;

class StoreBenhNhanRequest extends FormRequest
{
    /**
     * Xác thực quyền gửi request
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Tính toán tuổi chính xác của bệnh nhân dựa trên ngày sinh
     */
    public function getPatientAge(): ?int
    {
        $ngaySinh = $this->input('ngay_sinh');
        if (empty($ngaySinh)) {
            return null;
        }

        try {
            return Carbon::parse($ngaySinh)->age;
        } catch (\Throwable $e) {
            return null;
        }
    }

    /**
     * Định nghĩa các quy tắc kiểm tra tính hợp lệ dữ liệu (Validation Rules)
     */
    public function rules(): array
    {
        $rules = [
            'ho_chu_lot' => 'required|string|max:255',
            'ten' => 'required|string|max:255',
            'ngay_sinh' => 'required|date',
            'gioi_tinh' => 'required|in:0,1', // 1: Nam, 0: Nữ
            'so_dien_thoai' => ['required', 'string', new VietnamesePhoneRule()],
            'so_the_bhyt' => ['nullable', 'string', new BhytRule()],
            'dan_toc' => 'nullable|string|max:100',
            'nghe_nghiep' => 'nullable|string|max:255',
            'quan_he' => 'nullable|string|max:100',
            'email' => 'nullable|email|max:255',
            'ho_chieu' => 'nullable|string|max:20',
            'so_dinh_danh' => 'nullable|string|max:20',
            'quoc_gia' => 'nullable|string|max:100',
            'tinh_thanh' => 'required|string|max:100',
            'quan_huyen' => 'nullable|string|max:100',
            'phuong_xa' => 'required|string|max:100',
            'so_nha' => 'required|string|max:255',
            'ma_benh_nhan' => 'nullable|exists:benh_nhan,ma_benh_nhan',
        ];

        // RÀNG BUỘC NGHIỆP VỤ THEO TUỔI (Tuổi < 14 vs Tuổi >= 14)
        $age = $this->getPatientAge();

        if ($age !== null && $age < 14) {
            // Trẻ em dưới 14 tuổi: CCCD nullable (chưa bắt buộc làm thẻ căn cước)
            $rules['cccd'] = 'nullable|string|regex:/^[0-9]{12}$/';
            // BẮT BUỘC có số điện thoại cha mẹ / người giám hộ hợp lệ
            $rules['nguoi_lien_he_khan_cap'] = ['required', 'string', new VietnamesePhoneRule()];
        } else {
            // Bệnh nhân từ 14 tuổi trở lên: Bắt buộc phải có CCCD gắn chip 12 chữ số
            $rules['cccd'] = 'required|string|regex:/^[0-9]{12}$/';
            $rules['nguoi_lien_he_khan_cap'] = ['nullable', 'string', new VietnamesePhoneRule()];
        }

        return $rules;
    }

    /**
     * Bổ sung validator hook để đối soát chéo (Cross-check)
     */
    public function withValidator(Validator $validator): void
    {
        $validator->after(function () {
            $cccd = $this->input('cccd');
            $ngaySinh = $this->input('ngay_sinh');
            $gioiTinh = $this->input('gioi_tinh');
            $bhyt = $this->input('so_the_bhyt');
            $quanHe = $this->input('quan_he');
            $soDienThoai = $this->input('so_dien_thoai');
            $age = $this->getPatientAge();

            // 1. Cross-check CCCD vs Giới tính & Năm sinh
            if (!empty($cccd) && !empty($ngaySinh) && $gioiTinh !== null) {
                $this->crossCheckCccdVsProfile($cccd, $ngaySinh, (int)$gioiTinh);
            }

            // 2. Cross-check Mã BHYT vs Độ tuổi bệnh nhân
            if (!empty($bhyt) && !empty($ngaySinh)) {
                $this->crossCheckBhytVsAge($bhyt, $age, $ngaySinh);
            }

            // 3. Ràng buộc tính DUY NHẤT của hồ sơ "Bản thân" trong mỗi tài khoản
            if (!empty($quanHe) && !empty($soDienThoai)) {
                $this->checkUniqueSelfProfile($soDienThoai, $quanHe);
            }
        });
    }

    /**
     * Bóc tách CCCD 12 số và đối chiếu tính toàn vẹn (Cross-check) với Năm sinh & Giới tính
     */
    private function crossCheckCccdVsProfile(string $cccd, string $ngaySinh, int $gioiTinh): void
    {
        $cccd = trim($cccd);

        if (strlen($cccd) !== 12 || !ctype_digit($cccd)) {
            return;
        }

        $provinceCode = (int)substr($cccd, 0, 3);
        if ($provinceCode < 1 || $provinceCode > 96) {
            throw new HttpResponseException(response()->json([
                'status' => 'error',
                'message' => 'Mã tỉnh/thành phố trên CCCD (3 số đầu) không nằm trong dải 001-096 hợp lệ.'
            ], 422));
        }

        $genderCenturyCode = (int)$cccd[3];
        $expectedGender = ($genderCenturyCode % 2 === 0) ? 1 : 0;
        $centuryBase = 1900 + ((int)floor($genderCenturyCode / 2) * 100);

        $yearLast2Digits = (int)substr($cccd, 4, 2);
        $expectedBirthYear = $centuryBase + $yearLast2Digits;
        $actualBirthYear = (int)date('Y', strtotime($ngaySinh));

        if ($actualBirthYear !== $expectedBirthYear || $gioiTinh !== $expectedGender) {
            throw new HttpResponseException(response()->json([
                'status' => 'error',
                'message' => 'Giới tính hoặc Năm sinh không khớp với dữ liệu từ CCCD'
            ], 422));
        }
    }

    /**
     * Kiểm tra chéo giữa Mã đối tượng BHYT (2 ký tự đầu) và Độ tuổi thực tế của bệnh nhân
     * Chống gian lận: Người lớn khai BHYT học sinh/trẻ em, hoặc ngược lại
     */
    private function crossCheckBhytVsAge(string $bhyt, ?int $age, string $ngaySinh): void
    {
        $code = strtoupper(trim($bhyt));
        if (strlen($code) < 2 || $age === null) {
            return;
        }

        $prefix = substr($code, 0, 2);
        $birthYear = (int)date('Y', strtotime($ngaySinh));

        // 1. Mã 'TE': BHYT Trẻ em dưới 6 tuổi
        if ($prefix === 'TE' && $age >= 6) {
            throw new HttpResponseException(response()->json([
                'status' => 'error',
                'message' => "Mã thẻ BHYT đối tượng 'TE' chỉ dành cho trẻ em dưới 6 tuổi (bệnh nhân hiện tại {$age} tuổi)."
            ], 422));
        }

        // 2. Mã 'HS': BHYT Học sinh phổ thông (từ 6 đến 18 tuổi)
        if ($prefix === 'HS' && ($age < 6 || $age > 18)) {
            throw new HttpResponseException(response()->json([
                'status' => 'error',
                'message' => "Mã thẻ BHYT đối tượng 'HS' chỉ áp dụng cho học sinh từ 6 đến 18 tuổi (bệnh nhân sinh năm {$birthYear}, hiện tại {$age} tuổi không thể sử dụng mã đối tượng này)."
            ], 422));
        }

        // 3. Mã 'SV': BHYT Sinh viên đại học / cao đẳng (từ 18 đến 30 tuổi)
        if ($prefix === 'SV' && ($age < 18 || $age > 30)) {
            throw new HttpResponseException(response()->json([
                'status' => 'error',
                'message' => "Mã thẻ BHYT đối tượng 'SV' chỉ áp dụng cho sinh viên từ 18 đến 30 tuổi (bệnh nhân sinh năm {$birthYear}, hiện tại {$age} tuổi)."
            ], 422));
        }

        // 4. Mã 'HT': BHYT Hưu trí (người cao tuổi nghỉ hưu, thường từ 50 tuổi trở lên)
        if ($prefix === 'HT' && $age < 50) {
            throw new HttpResponseException(response()->json([
                'status' => 'error',
                'message' => "Mã thẻ BHYT đối tượng 'HT' (Hưu trí) chỉ áp dụng cho người đến tuổi nghỉ hưu (bệnh nhân hiện tại {$age} tuổi)."
            ], 422));
        }
    }

    /**
     * Ràng buộc duy nhất: Mỗi tài khoản / Số điện thoại chỉ được phép có duy nhất MỘT hồ sơ là "Bản thân"
     */
    private function checkUniqueSelfProfile(string $soDienThoai, string $quanHe): void
    {
        if (trim($quanHe) !== 'Bản thân') {
            return;
        }

        $phone0 = str_starts_with($soDienThoai, '+84') ? '0' . substr($soDienThoai, 3) : $soDienThoai;
        $phone84 = str_starts_with($soDienThoai, '0') ? '+84' . substr($soDienThoai, 1) : $soDienThoai;

        // Nếu là update, bỏ qua chính hồ sơ đang sửa
        $currentId = $this->route('id');

        $exists = HoSoBenhAn::whereIn('so_dien_thoai', [$soDienThoai, $phone0, $phone84])
            ->where('quan_he', 'Bản thân')
            ->when($currentId, function ($query, $id) {
                $query->where('ma_ho_so', '!=', $id);
            })
            ->exists();

        if ($exists) {
            throw new HttpResponseException(response()->json([
                'status' => 'error',
                'message' => "Số điện thoại này đã có một hồ sơ 'Bản thân'. Mỗi tài khoản chỉ được phép có duy nhất một hồ sơ Bản thân, các hồ sơ khác vui lòng chọn quan hệ là Con cái, Vợ/Chồng, Bố/Mẹ hoặc Họ hàng."
            ], 422));
        }
    }

    /**
     * Tùy chỉnh thông báo lỗi tiếng Việt thân thiện
     */
    public function messages(): array
    {
        return [
            'ho_chu_lot.required' => 'Vui lòng nhập họ và chữ lót.',
            'ten.required' => 'Vui lòng nhập tên người bệnh.',
            'ngay_sinh.required' => 'Vui lòng chọn ngày sinh.',
            'ngay_sinh.date' => 'Ngày sinh không đúng định dạng ngày tháng.',
            'gioi_tinh.required' => 'Vui lòng chọn giới tính.',
            'gioi_tinh.in' => 'Giới tính chỉ chấp nhận giá trị Nam (1) hoặc Nữ (0).',
            'so_dien_thoai.required' => 'Vui lòng nhập số điện thoại liên hệ.',
            'cccd.required' => 'Bệnh nhân từ 14 tuổi trở lên bắt buộc phải cung cấp số CCCD gắn chip.',
            'cccd.regex' => 'Số CCCD phải bao gồm chính xác 12 chữ số.',
            'nguoi_lien_he_khan_cap.required' => 'Bệnh nhân dưới 14 tuổi bắt buộc phải có số điện thoại của cha mẹ hoặc người giám hộ.',
            'tinh_thanh.required' => 'Vui lòng chọn Tỉnh/Thành phố thường trú.',
            'phuong_xa.required' => 'Vui lòng chọn Phường/Xã thường trú.',
            'so_nha.required' => 'Vui lòng nhập địa chỉ chi tiết (số nhà, tên đường).',
        ];
    }
}
