<?php

namespace App\Http\Controllers;

use App\Models\BacSi;
use App\Models\BenhNhan;
use App\Models\ChiDinhDichVu;
use App\Models\HoaDon;
use App\Models\HoSoBenhAn;
use App\Models\KhungGio;
use App\Models\LichKham;
use App\Models\PhienKham;
use App\Models\TaiKhoan;
use App\Rules\ValidBhyt;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class MobileController extends Controller
{
    // =========================================================================
    // 1. AUTH
    // =========================================================================

    public function login(Request $request)
    {
        $request->validate([
            'phone_number' => 'required|string',
            'password' => 'required|string',
        ]);

        $taiKhoan = TaiKhoan::where('ten_dang_nhap', $request->phone_number)
            ->where('vai_tro', 'BenhNhan')
            ->first();

        if (! $taiKhoan) {
            $benhNhan = BenhNhan::where('so_dien_thoai', $request->phone_number)->first();
            if ($benhNhan && $benhNhan->ma_tk) {
                $taiKhoan = TaiKhoan::find($benhNhan->ma_tk);
            }
        }
        if (! $taiKhoan) {
            return response()->json(['message' => 'Số điện thoại chưa được đăng ký'], 401);
        }

        if (! \Hash::check($request->password, $taiKhoan->mat_khau)) {
            return response()->json(['message' => 'Mật khẩu không đúng'], 401);
        }

        $benhNhanChinh = BenhNhan::where('ma_tk', $taiKhoan->ma_tk)
            ->where('so_dien_thoai', $request->phone_number)
            ->first();

        if (! $benhNhanChinh) {
            $benhNhanChinh = BenhNhan::where('ma_tk', $taiKhoan->ma_tk)->first();
        }

        // Cập nhật FCM Token nếu có
        if ($request->fcm_token) {
            $taiKhoan->update(['fcm_token' => $request->fcm_token]);
        }

        $token = auth('api')->login($taiKhoan);

        return response()->json([
            'message' => 'Đăng nhập thành công',
            'token' => $token,
            'data' => [
                'id' => $taiKhoan->ma_tk,
                'phone' => $benhNhanChinh ? $benhNhanChinh->so_dien_thoai : $taiKhoan->ten_dang_nhap,
                'name' => $benhNhanChinh ? $benhNhanChinh->ho_ten : 'Bệnh nhân',
            ],
        ]);
    }

    public function sendOtp(Request $request)
    {
        if (! config('otp.demo_enabled')) {
            return response()->json(['message' => 'OTP provider is not configured.'], 503);
        }

        return response()->json(['message' => 'Mã OTP đã được gửi đến số điện thoại (Mã mặc định: 123456)']);
    }

    public function verifyOtp(Request $request)
    {
        if (! config('otp.demo_enabled')) {
            return response()->json(['message' => 'OTP provider is not configured.'], 503);
        }

        $otp = $request->otp;
        if ($otp === '123456') {
            return response()->json(['message' => 'Xác thực OTP thành công']);
        }

        return response()->json(['message' => 'Mã OTP không đúng'], 400);
    }

    public function setPassword(Request $request)
    {
        $phone = $request->phone_number;
        $password = $request->password;

        $benhNhan = BenhNhan::where('so_dien_thoai', $phone)->first();
        if (! $benhNhan) {
            // Nếu bệnh nhân chưa tồn tại, tạo mới tài khoản + bệnh nhân
            $taiKhoan = TaiKhoan::create([
                'ten_dang_nhap' => $phone,
                'mat_khau' => Hash::make($password),
                'vai_tro' => 'BenhNhan',
                'trang_thai' => true,
            ]);
            $benhNhan = BenhNhan::create([
                'ma_tk' => $taiKhoan->ma_tk,
                'ho_ten' => 'Bệnh nhân '.$phone,
                'so_dien_thoai' => $phone,
                'gioi_tinh' => 1,
                'ngay_sinh' => '1990-01-01',
            ]);
            HoSoBenhAn::create(['ma_benh_nhan' => $benhNhan->ma_benh_nhan]);
        } else {
            // Nếu đã có, cập nhật mật khẩu
            $taiKhoan = TaiKhoan::find($benhNhan->ma_tk);
            if ($taiKhoan) {
                $taiKhoan->update(['mat_khau' => Hash::make($password)]);
            }
        }

        $token = auth('api')->login($taiKhoan);

        return response()->json(['message' => 'Tạo mật khẩu thành công', 'token' => $token]);
    }

    public function updateFcmToken(Request $request)
    {
        $request->validate([
            'phone_number' => 'required|string',
            'fcm_token' => 'required|string|max:500',
        ]);

        // Tìm bệnh nhân theo SĐT → lấy tài khoản → cập nhật token
        $benhNhan = BenhNhan::where('so_dien_thoai', $request->phone_number)->first();

        if (! $benhNhan || ! $benhNhan->ma_tk) {
            return response()->json(['message' => 'Không tìm thấy tài khoản'], 404);
        }

        $taiKhoan = TaiKhoan::find($benhNhan->ma_tk);
        if (! $taiKhoan) {
            return response()->json(['message' => 'Không tìm thấy tài khoản'], 404);
        }

        $taiKhoan->update(['fcm_token' => $request->fcm_token]);

        return response()->json(['message' => 'Cập nhật FCM Token thành công']);
    }

    public function logout()
    {
        auth('api')->logout();

        return response()->json(['message' => 'Đăng xuất thành công']);
    }

    // =========================================================================
    // 2. MASTER DATA & HỒ SƠ BỆNH NHÂN
    // =========================================================================

    public function metadata()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'ethnic_groups' => ['Kinh', 'Tày', 'Thái', 'Mường', 'H Mông', 'Dao', 'Khmer', 'Nùng', 'Hoa'],
                'relationships' => ['Bản thân', 'Vợ / Chồng', 'Bố / Mẹ', 'Con cái', 'Anh / Chị / Em ruột'],
                'occupations' => ['Cán bộ', 'Công nhân', 'Nông dân', 'Học sinh / Sinh viên', 'Kinh doanh', 'Nội trợ'],
                'countries' => ['Việt Nam', 'Hoa Kỳ (Mỹ)', 'Nhật Bản', 'Hàn Quốc', 'Trung Quốc'],
            ],
        ]);
    }

    public function getProfilesByPhone(Request $request)
    {
        $maTk = auth('api')->id();
        if (! $maTk) {
            return response()->json(['data' => []]);
        }

        $benhNhans = BenhNhan::where('ma_tk', $maTk)->get();
        if ($benhNhans->isEmpty()) {
            return response()->json(['data' => []]);
        }

        $data = [];
        foreach ($benhNhans as $benhNhan) {
            // Lấy hồ sơ bệnh án tương ứng
            $hoSo = HoSoBenhAn::where('ma_benh_nhan', $benhNhan->ma_benh_nhan)->first();

            if ($hoSo) {
                // --- XỬ LÝ TÁCH TÊN TỰ ĐỘNG NẾU DỮ LIỆU CŨ BỊ NULL ---
                $hoChuLot = $benhNhan->ho_chu_lot;
                $ten = $benhNhan->ten;
                $hoTen = $benhNhan->ho_ten;

                if (empty($hoChuLot) && empty($ten) && ! empty($hoTen)) {
                    $parts = explode(' ', trim($hoTen));
                    if (count($parts) > 1) {
                        $ten = array_pop($parts); // Chữ cuối cùng là Tên
                        $hoChuLot = implode(' ', $parts); // Phần còn lại là Họ và Tên lót
                    } else {
                        $hoChuLot = $hoTen;
                        $ten = '';
                    }
                }
                $tinhThanh = $benhNhan->tinh_thanh ?? $hoSo->tinh_thanh;
                $quanHuyen = $hoSo->quan_huyen;
                $phuongXa = $benhNhan->phuong_xa ?? $hoSo->phuong_xa;
                $soNha = $benhNhan->so_nha ?? $hoSo->so_nha;
                $diaChiParts = array_map('trim', explode(',', (string) $benhNhan->dia_chi));

                if (count($diaChiParts) === 4) {
                    $soNha = $diaChiParts[0];
                    $phuongXa = $diaChiParts[1];
                    $quanHuyen = $diaChiParts[2];
                    $tinhThanh = $diaChiParts[3];
                } elseif (
                    count($diaChiParts) === 3
                    && preg_match('/^(quận|huyện|thị xã)\b/ui', $diaChiParts[1]) === 1
                ) {
                    // Legacy addresses may omit the ward; preserve the available components.
                    $soNha = $soNha ?: $diaChiParts[0];
                    $quanHuyen = $quanHuyen ?: $diaChiParts[1];
                    $tinhThanh = $tinhThanh ?: $diaChiParts[2];
                }
                if (strcasecmp(trim((string) $tinhThanh), 'TP.HCM') === 0) {
                    $tinhThanh = 'Thành phố Hồ Chí Minh';
                }

                // -----------------------------------------------------------
                $data[] = [
                    'ma_ho_so' => $hoSo->ma_ho_so,
                    'ho_ten' => $hoTen,
                    'ho_chu_lot' => $hoChuLot ?? '',
                    'ten' => $ten ?? '',
                    'ngay_sinh' => $benhNhan->ngay_sinh ? $benhNhan->ngay_sinh->format('Y-m-d') : null,
                    'gioi_tinh' => $benhNhan->gioi_tinh,
                    'so_dien_thoai' => $benhNhan->so_dien_thoai,
                    'email' => $benhNhan->email ?? '',
                    'cccd' => $benhNhan->cccd ?? '',
                    'dia_chi' => $benhNhan->dia_chi ?? '',
                    'que_quan' => $benhNhan->que_quan ?? '',
                    'nguoi_lien_he_khan_cap' => $benhNhan->nguoi_lien_he_khan_cap ?? '',
                    // Các trường từ hồ sơ bệnh án
                    'dan_toc' => $hoSo->dan_toc ?? 'Kinh',
                    'nghe_nghiep' => $hoSo->nghe_nghiep ?? '',
                    'quan_he' => $hoSo->quan_he ?? 'Bản thân',
                    'quoc_gia' => $hoSo->quoc_gia ?? 'Việt Nam',
                    'tinh_thanh' => $tinhThanh ?? '',
                    'quan_huyen' => $quanHuyen ?? '',
                    'phuong_xa' => $phuongXa ?? '',
                    'so_nha' => $soNha ?? '',
                    'nhom_mau' => $hoSo->nhom_mau,
                    'ma_bhyt' => $hoSo->ma_bhyt,
                    'so_the_bhyt' => $hoSo->ma_bhyt,
                    'tien_su_benh' => $hoSo->tien_su_benh ?? '',
                    'di_ung' => $benhNhan->di_ung ?? '',
                ];
            }
        }

        return response()->json(['data' => $data], 200);
    }

    public function createProfile(Request $request)
    {
        $hoTen = $request->input('ho_ten');
        if (! $hoTen) {
            $hoChuLot = $request->input('ho_chu_lot', '');
            $ten = $request->input('ten', '');
            $hoTen = trim($hoChuLot.' '.$ten);
        }
        if (empty($hoTen)) {
            return response()->json(['message' => 'Vui lòng nhập họ và tên bệnh nhân'], 400);
        }
        $diaChiParts = array_filter([
            $request->input('so_nha'),
            $request->input('phuong_xa'),
            $request->input('quan_huyen'),
            $request->input('tinh_thanh'),
        ]);
        $diaChiFull = implode(', ', $diaChiParts);
        try {
            // Sử dụng Transaction: Nếu bất kỳ bước nào lỗi, toàn bộ sẽ bị hủy (Rollback)
            $result = \DB::transaction(function () use ($request, $hoTen, $diaChiFull) {

                $benhNhanData = [
                    'ho_ten' => $hoTen,
                    'ho_chu_lot' => $request->input('ho_chu_lot'),
                    'ten' => $request->input('ten'),
                    'ngay_sinh' => $request->ngay_sinh,
                    'gioi_tinh' => $request->gioi_tinh ?? 1,
                    'so_dien_thoai' => $request->so_dien_thoai,
                    'cccd' => $request->cccd,
                    'email' => $request->email,
                    'dia_chi' => $diaChiFull,
                    'tinh_thanh' => $request->input('tinh_thanh'),
                    'phuong_xa' => $request->input('phuong_xa'),
                    'so_nha' => $request->input('so_nha'),
                    'nguoi_lien_he_khan_cap' => $request->nguoi_lien_he_khan_cap,
                    'ma_bhyt' => $request->input('so_the_bhyt') ?? $request->input('ma_bhyt'),
                    'ma_tk' => auth('api')->id(),
                ];
                if (\Schema::hasColumn('benhnhan', 'que_quan')) {
                    $benhNhanData['que_quan'] = $request->input('que_quan') ?? $request->input('tinh_thanh');
                }
                $benhNhan = BenhNhan::create($benhNhanData);

                // 3. Tạo hồ sơ bệnh án đi kèm
                $hoSoData = [
                    'ma_benh_nhan' => $benhNhan->ma_benh_nhan,
                    'nhom_mau' => $request->input('nhom_mau'),
                    'ma_bhyt' => $request->input('so_the_bhyt') ?? $request->input('ma_bhyt'),
                    'tien_su_benh' => $request->input('tien_su_benh'),
                ];

                foreach (['dan_toc', 'nghe_nghiep', 'quan_he', 'quoc_gia', 'quan_huyen'] as $column) {
                    if (\Schema::hasColumn('hosobenhan', $column)) {
                        $hoSoData[$column] = $request->input($column);
                    }
                }

                HoSoBenhAn::create($hoSoData);

                return $benhNhan;
            });

            return response()->json([
                'message' => 'Tạo hồ sơ thành công',
                'data' => $result,
            ], 201);

        } catch (\Exception $e) {
            // Ghi log lỗi ra file để dễ debug
            \Log::error('Lỗi tạo hồ sơ: '.$e->getMessage());

            return response()->json([
                'message' => 'Không thể tạo hồ sơ: '.$e->getMessage(),
                'error_details' => [
                    'file' => $e->getFile(),
                    'line' => $e->getLine(),
                ],
            ], 500);
        }
    }

    public function updateProfile(Request $request, $id)
    {
        $hoSo = HoSoBenhAn::find($id);
        if (! $hoSo) {
            return response()->json(['message' => 'Không tìm thấy hồ sơ'], 404);
        }

        $benhNhan = BenhNhan::find($hoSo->ma_benh_nhan);

        if ($benhNhan) {
            if ($request->has('ho_chu_lot') || $request->has('ten')) {
                // Nếu App gửi tách rời
                $hoChuLot = $request->input('ho_chu_lot', '');
                $ten = $request->input('ten', '');
                $benhNhan->ho_chu_lot = $hoChuLot;
                $benhNhan->ten = $ten;
                $benhNhan->ho_ten = trim($hoChuLot.' '.$ten);
            } elseif ($request->has('ho_ten') && ! empty($request->input('ho_ten'))) {
                // Nếu App chỉ gửi tên gộp -> Tự động tách
                $hoTen = trim($request->input('ho_ten'));
                $benhNhan->ho_ten = $hoTen;

                $parts = explode(' ', $hoTen);
                if (count($parts) > 1) {
                    $benhNhan->ten = array_pop($parts);
                    $benhNhan->ho_chu_lot = implode(' ', $parts);
                } else {
                    $benhNhan->ho_chu_lot = $hoTen;
                    $benhNhan->ten = '';
                }
            }

            foreach (['tinh_thanh', 'phuong_xa', 'so_nha'] as $field) {
                if ($request->exists($field)) {
                    $benhNhan->{$field} = $request->input($field);
                }
            }

            if ($request->exists('so_nha') || $request->exists('phuong_xa') || $request->exists('quan_huyen') || $request->exists('tinh_thanh')) {
                $diaChiParts = array_filter([
                    $request->input('so_nha'),
                    $request->input('phuong_xa'),
                    $request->input('quan_huyen'),
                    $request->input('tinh_thanh'),
                ]);
                $benhNhan->dia_chi = implode(', ', $diaChiParts);
            }
            if ($request->has('ngay_sinh')) {
                $benhNhan->ngay_sinh = $request->ngay_sinh;
            }
            if ($request->has('gioi_tinh')) {
                $benhNhan->gioi_tinh = $request->gioi_tinh;
            }
            if ($request->has('so_dien_thoai')) {
                $benhNhan->so_dien_thoai = $request->so_dien_thoai;
            }
            if ($request->has('cccd')) {
                $benhNhan->cccd = $request->cccd;
            }
            if ($request->exists('nguoi_lien_he_khan_cap')) {
                $benhNhan->nguoi_lien_he_khan_cap = $request->input('nguoi_lien_he_khan_cap');
            }
            if ($request->has('di_ung')) {
                $benhNhan->di_ung = $request->di_ung;
            }
            if ($request->has('que_quan') && \Schema::hasColumn('benhnhan', 'que_quan')) {
                $benhNhan->que_quan = $request->que_quan ?? $request->tinh_thanh;
            }
            $benhNhan->save();
        }

        foreach (['dan_toc', 'nghe_nghiep', 'quan_he', 'quoc_gia', 'quan_huyen'] as $column) {
            if ($request->exists($column) && \Schema::hasColumn('hosobenhan', $column)) {
                $hoSo->{$column} = $request->input($column);
            }
        }

        if ($request->has('nhom_mau')) {
            $hoSo->nhom_mau = $request->nhom_mau;
        }
        if ($request->has('tien_su_benh')) {
            $hoSo->tien_su_benh = $request->tien_su_benh;
        }

        // Xử lý xóa hoặc cập nhật mã BHYT
        if ($request->exists('so_the_bhyt') || $request->exists('ma_bhyt')) {
            $maBhyt = $request->exists('so_the_bhyt')
                ? $request->input('so_the_bhyt')
                : $request->input('ma_bhyt');
            $maBhyt = empty($maBhyt) ? null : $maBhyt;

            $hoSo->ma_bhyt = $maBhyt;
            if ($benhNhan) {
                $benhNhan->ma_bhyt = $maBhyt;
                $benhNhan->save();
            }
        }

        $hoSo->save();

        return response()->json(['message' => 'Cập nhật thành công', 'data' => $benhNhan]);
    }

    public function deleteProfile($id)
    {
        $hoSo = HoSoBenhAn::find($id);
        if ($hoSo) {
            $benhNhan = BenhNhan::find($hoSo->ma_benh_nhan);
            $hoSo->delete();
            if ($benhNhan) {
                $benhNhan->delete();
            } // Xóa luôn bệnh nhân nếu là hồ sơ phụ
        }

        return response()->json(['message' => 'Đã xóa hồ sơ']);
    }

    public function findProfileByCode(Request $request)
    {
        $code = $request->query('code'); // Có thể là ma_ho_so hoặc CCCD
        $hoSo = HoSoBenhAn::where('ma_ho_so', $code)->first();
        if (! $hoSo) {
            $benhNhan = BenhNhan::where('cccd', $code)->first();
            if ($benhNhan) {
                $hoSo = HoSoBenhAn::where('ma_benh_nhan', $benhNhan->ma_benh_nhan)->first();
            }
        }

        return response()->json(['data' => $hoSo]);
    }

    public function findProfileByInfo(Request $request)
    {
        $query = BenhNhan::query();
        if ($request->filled('phone')) {
            $query->where('so_dien_thoai', $request->phone);
        }
        if ($request->filled('cccd')) {
            $query->where('cccd', $request->cccd);
        }

        $benhNhan = $query->first();
        $hoSo = $benhNhan ? HoSoBenhAn::where('ma_benh_nhan', $benhNhan->ma_benh_nhan)->first() : null;

        return response()->json(['data' => $hoSo]);
    }

    // =========================================================================
    // 3. ĐẶT LỊCH & QUẢN LÝ LƯỢT KHÁM
    // =========================================================================

    public function datLich(Request $request)
    {
        $hoSo = HoSoBenhAn::with('benhNhan')->find($request->input('ma_ho_so'));
        $ngaySinh = $hoSo?->benhNhan?->ngay_sinh;

        $validator = Validator::make($request->all(), [
            'ma_ho_so' => 'required|exists:HoSoBenhAn,ma_ho_so',
            'ma_bac_si' => 'required|exists:BacSi,ma_bs',
            'thoi_gian_den_kham' => 'required|date',
            'priority_level' => 'integer|in:1,2,3,4',
            'is_bhyt' => 'boolean',
            'ma_the_bhyt' => ['nullable', 'string', new ValidBhyt($ngaySinh)],
            'so_tien' => 'nullable|numeric',

        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }
        $hinhThucKham = ($request->is_bhyt ?? false) ? 'BHYT' : 'DichVu';

        // Bỏ qua thanh toán VNPay ở đây, tạo lịch trực tiếp
        $lichKham = LichKham::create([
            'ma_ho_so' => $request->ma_ho_so,
            'ma_bac_si' => $request->ma_bac_si,
            'thoi_gian_den_kham' => $request->thoi_gian_den_kham,
            'priority_level' => $request->priority_level ?? 4,
            'trang_thai' => $request->trang_thai ?? 'cho_thanh_toan',
            'is_bhyt' => $request->is_bhyt ?? false,
            'ma_the_bhyt' => $request->ma_the_bhyt,
            'so_tien' => $request->so_tien,
            'hinh_thuc_kham' => $hinhThucKham,
        ]);

        return response()->json([
            'message' => 'Đặt lịch thành công',
            'data' => $lichKham->load('bacSi'),
        ], 201);
    }

    public function danhSach(Request $request)
    {
        $maHoSoList = $request->input('danh_sach_ma_ho_so', []);
        $appointments = LichKham::with(['bacSi.chuyenKhoa', 'phienKham.hoaDon'])
            ->whereIn('ma_ho_so', $maHoSoList)
            ->orderBy('thoi_gian_den_kham', 'desc')
            ->get();
        $trangThaiDaThanhToan = ['da_thanh_toan', 'cho_kham', 'dang_kham', 'hoan_thanh'];
        $data = $appointments->map(function ($item) {
            $hoaDon = $item->phienKham?->hoaDon;

            $trangThaiThanhToan = 'ChuaThanhToan';
            $soTienCanTra = 0;

            if ($hoaDon) {
                if ($hoaDon->tien_benh_nhan_tra <= 0) {
                    $trangThaiThanhToan = 'DaThanhToan';
                } else {
                    $trangThaiThanhToan = $hoaDon->trang_thai === 'DaThanhToan' ? 'DaThanhToan' : 'ChuaThanhToan';
                }
                $soTienCanTra = $hoaDon->tien_benh_nhan_tra;
            } else {
                // Nếu chưa có Hóa đơn (chưa khám xong)
                $trangThaiDaThanhToan = ['da_thanh_toan', 'cho_kham', 'dang_kham', 'hoan_thanh'];
                $trangThaiThanhToan = in_array($item->trang_thai, $trangThaiDaThanhToan) ? 'DaThanhToan' : 'ChuaThanhToan';
                $soTienCanTra = $item->so_tien ?? 150000;
            }
            $isCompleted = in_array($item->trang_thai, ['hoan_tat_hoa_don', 'hoan_thanh']);

            return [
                'ma_luot_kham' => $item->ma_luot_kham,
                'ma_ho_so' => $item->ma_ho_so,
                'thoi_gian_den_kham' => $item->thoi_gian_den_kham?->format('Y-m-d H:i:s'),
                'ten_bac_si' => $item->bacSi?->ho_ten ?? 'Đang cập nhật',
                'ten_chuyen_khoa' => $item->bacSi?->chuyenKhoa?->ten_chuyen_khoa,
                'phong_kham' => $item->phienKham?->phong_kham
                    ?? $item->bacSi?->chuyenKhoa?->phong_kham,
                'trang_thai_kham' => $item->trang_thai,
                'trang_thai_thanh_toan' => $trangThaiThanhToan,
                'so_tien_can_tra' => $soTienCanTra,
                'ten_benh_nhan' => $item->hoSo->benhNhan->ho_ten ?? '',
                'is_completed' => $isCompleted,
            ];
        });

        return response()->json(['data' => $data], 200);
    }

    public function paymentBills()
    {
        $maTk = auth('api')->id();
        if (! $maTk) {
            return response()->json(['status' => 'error', 'message' => 'Unauthenticated.'], 401);
        }

        $maHoSoList = HoSoBenhAn::whereHas('benhNhan', function ($query) use ($maTk) {
            $query->where('ma_tk', $maTk);
        })->pluck('ma_ho_so');

        $appointments = LichKham::with([
            'hoSo.benhNhan',
            'bacSi.chuyenKhoa',
            'phienKham.hoaDon',
        ])
            ->whereIn('ma_ho_so', $maHoSoList)
            ->where('trang_thai', '!=', 'huy')
            ->orderByDesc('ma_luot_kham')
            ->get();

        $pendingBills = [];
        $paymentHistory = [];

        foreach ($appointments as $appointment) {
            $invoice = $appointment->phienKham?->hoaDon;
            $date = $appointment->thoi_gian_den_kham;
            $doctor = $appointment->bacSi;
            $specialty = $doctor?->chuyenKhoa;
            $patient = $appointment->hoSo?->benhNhan;

            $baseDetails = [
                'ma_luot_kham' => (int) $appointment->ma_luot_kham,
                'ngay_kham' => $date?->format('d/m/Y') ?? '--/--/----',
                'thoi_gian_kham' => $date?->format('H:i') ?? '--:--',
                'chuyen_khoa' => $specialty?->ten_chuyen_khoa ?? 'Khám chuyên khoa',
                'bac_si' => $doctor?->ho_ten ?? 'Bác sĩ phụ trách',
                'ten_benh_nhan' => $patient?->ho_ten ?? '',
            ];

            if ($invoice) {
                $tienKham = (float) $invoice->tien_kham_benh;
                $tienDichVu = (float) $invoice->tien_dich_vu;
                $tienThuoc = (float) $invoice->tien_thuoc;
                $tienBhyt = (float) $invoice->tien_bhyt_tra;
                $soTienConNo = max(0, (float) $invoice->tien_benh_nhan_tra);
                $daThanhToanLucDatLich = max(
                    0,
                    (float) $invoice->tong_cong - $tienBhyt - $soTienConNo
                );

                if ($invoice->trang_thai === 'ChuaThanhToan' && $soTienConNo > 0) {
                    $pendingBills[] = [
                        ...$baseDetails,
                        'ma_hoa_don' => (int) $invoice->ma_hoa_don,
                        'tien_kham' => $tienKham,
                        'tien_dich_vu' => $tienDichVu,
                        'tien_thuoc' => $tienThuoc,
                        'tien_bhyt' => $tienBhyt,
                        'tong_cong' => (float) $invoice->tong_cong,
                        'tong_tien' => $soTienConNo,
                        'trang_thai' => 'Chờ thanh toán',
                    ];
                } elseif ($invoice->trang_thai === 'DaThanhToan' && $soTienConNo > 0) {
                    $ngayThanhToan = $invoice->ngay_thanh_toan ?? $invoice->ngay_tao;
                    $paymentHistory[] = [
                        ...$baseDetails,
                        'ma_giao_dich' => 'HD_'.$invoice->ma_hoa_don,
                        'ma_hoa_don' => (int) $invoice->ma_hoa_don,
                        'thoi_gian_thanh_toan' => $ngayThanhToan
                            ? Carbon::parse($ngayThanhToan)->format('H:i - d/m/Y')
                            : '--',
                        'tien_kham' => $tienKham,
                        'tien_dich_vu' => $tienDichVu,
                        'tien_thuoc' => $tienThuoc,
                        'tong_tien' => $soTienConNo,
                        'phuong_thuc' => $invoice->phuong_thuc ?? 'VNPay',
                        'trang_thai' => 'Thành công',
                    ];
                }

                if ($daThanhToanLucDatLich > 0) {
                    $paymentTime = $appointment->updated_at ?? $appointment->created_at;
                    $paymentHistory[] = [
                        ...$baseDetails,
                        'ma_giao_dich' => 'LK_'.$appointment->ma_luot_kham,
                        'thoi_gian_thanh_toan' => $paymentTime
                            ? Carbon::parse($paymentTime)->format('H:i - d/m/Y')
                            : '--',
                        'tien_kham' => $daThanhToanLucDatLich,
                        'tien_dich_vu' => 0,
                        'tien_thuoc' => 0,
                        'tong_tien' => $daThanhToanLucDatLich,
                        'phuong_thuc' => 'Thanh toán lúc đặt lịch',
                        'trang_thai' => 'Thành công',
                    ];
                }

                continue;
            }

            $amount = (float) ($appointment->so_tien ?? $specialty?->gia_kham ?? 150000);
            if ($appointment->trang_thai === 'cho_thanh_toan') {
                $pendingBills[] = [
                    ...$baseDetails,
                    'tien_kham' => $amount,
                    'tien_dich_vu' => 0,
                    'tien_thuoc' => 0,
                    'tong_tien' => $amount,
                    'trang_thai' => 'Chờ thanh toán',
                ];
            } elseif (
                $amount > 0
                && in_array($appointment->trang_thai, [
                    'da_thanh_toan',
                    'cho_kham',
                    'dang_kham',
                    'hoan_thanh',
                ], true)
            ) {
                $paymentTime = $appointment->updated_at ?? $appointment->created_at;
                $paymentHistory[] = [
                    ...$baseDetails,
                    'ma_giao_dich' => 'LK_'.$appointment->ma_luot_kham,
                    'thoi_gian_thanh_toan' => $paymentTime
                        ? Carbon::parse($paymentTime)->format('H:i - d/m/Y')
                        : '--',
                    'tien_kham' => $amount,
                    'tien_dich_vu' => 0,
                    'tien_thuoc' => 0,
                    'tong_tien' => $amount,
                    'phuong_thuc' => 'Thanh toán lúc đặt lịch',
                    'trang_thai' => 'Thành công',
                ];
            }
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'pending_bills' => $pendingBills,
                'payment_history' => $paymentHistory,
            ],
        ]);
    }

    /**
     * GET /api/mobile/luot-kham/gio-trong?ma_bac_si=1&ngay_kham=2026-11-20
     * Trả về danh sách giờ còn trống của bác sĩ trong ngày
     */
    public function gioTrong(Request $request)
    {
        date_default_timezone_set('Asia/Ho_Chi_Minh');
        $bayGio = Carbon::now();

        $maBacSi = $request->query('ma_bac_si');
        $ngayKham = $request->query('ngay_kham');

        if (! $maBacSi) {
            return response()->json(['danh_sach_gio_trong' => [], 'message' => 'Thiếu mã bác sĩ'], 400);
        }
        if (! $ngayKham) {
            return response()->json(['danh_sach_gio_trong' => [], 'message' => 'Thiếu ngày khám'], 400);
        }
        $ngayKhamObj = Carbon::parse($ngayKham);
        $ngayKhamStr = $ngayKhamObj->format('Y-m-d');

        if ($ngayKhamStr < $bayGio->format('Y-m-d')) {
            return response()->json(['danh_sach_gio_trong' => [], 'message' => 'Ngày khám đã qua'], 200);
        }
        $daDat = LichKham::where('ma_bac_si', $maBacSi)
            ->whereDate('thoi_gian_den_kham', $ngayKhamStr)
            ->where('trang_thai', '!=', 'huy')
            ->pluck('thoi_gian_den_kham')
            ->map(fn ($t) => Carbon::parse($t)->format('H:i'))
            ->toArray();

        $tatCaKhungGio = KhungGio::with('caLamViec')->orderBy('gio_bat_dau')->get();
        if ($tatCaKhungGio->isEmpty()) {
            return response()->json(['danh_sach_gio_trong' => [], 'message' => 'Chưa cấu hình khung giờ'], 200);
        }

        $gioTrong = [];
        $laHomNay = ($ngayKhamStr === $bayGio->format('Y-m-d'));

        foreach ($tatCaKhungGio as $kg) {
            $batDau = Carbon::parse($ngayKhamStr.' '.$kg->gio_bat_dau);
            $ketThuc = Carbon::parse($ngayKhamStr.' '.$kg->gio_ket_thuc);

            while ($batDau->lt($ketThuc)) {
                $gioBatDauStr = $batDau->format('H:i');

                if ($laHomNay && $batDau->lt($bayGio)) {
                    $batDau->addMinutes(30);

                    continue;
                }
                if (! in_array($gioBatDauStr, $daDat)) {
                    $gioTrong[] = $gioBatDauStr;
                }
                $batDau->addMinutes(30);
            }
        }

        return response()->json([
            'danh_sach_gio_trong' => $gioTrong,
            'ngay_kham' => $ngayKhamStr,
            'ma_bac_si' => (int) $maBacSi,
        ], 200);

    }

    public function checkStatus($id)
    {
        $lk = LichKham::with('phienKham.hoaDon')->findOrFail($id);
        $hoaDon = $lk->phienKham?->hoaDon;
        $isPaid = $hoaDon
            ? $hoaDon->trang_thai === 'DaThanhToan' || $hoaDon->tien_benh_nhan_tra <= 0
            : in_array($lk->trang_thai, [
                'da_thanh_toan',
                'cho_kham',
                'dang_kham',
                'hoan_thanh',
            ], true);

        return response()->json([
            'status' => 'success',
            'data' => [
                'ma_luot_kham' => $lk->ma_luot_kham,
                'trang_thai' => $lk->trang_thai,
                'so_thu_tu' => $lk->so_thu_tu,
                'is_paid' => $isPaid,
            ],
        ], 200);
    }

    public function hangDoi($id)
    {
        $lk = LichKham::findOrFail($id);

        return response()->json([
            'ma_luot_kham' => $lk->ma_luot_kham,
            'so_thu_tu' => $lk->so_thu_tu,
            'trang_thai' => $lk->trang_thai,
        ], 200);
    }

    public function tiepNhan($id)
    {
        $lk = LichKham::findOrFail($id);
        if (! in_array($lk->trang_thai, ['da_thanh_toan', 'cho_kham'])) {
            return response()->json([
                'message' => 'Không thể check-in. Lượt khám này đã khám xong hoặc đã bị hủy.',
                'trang_thai_hien_tai' => $lk->trang_thai,
            ], 400);
        }
        $lk->update(['trang_thai' => 'cho_kham']);

        return response()->json(['message' => 'Tiếp nhận thành công', 'data' => $lk], 200);
    }

    public function huy($id)
    {
        $lk = LichKham::findOrFail($id);
        $lk->update(['trang_thai' => 'huy']);

        return response()->json(['message' => 'Đã hủy'], 200);
    }

    public function thongBaoSapDenLuot(Request $request, $id)
    {
        return response()->json(['message' => 'Đã gửi thông báo'], 200);
    }

    // =========================================================================
    // 4. EMR (LỊCH SỬ KHÁM & KẾT QUẢ CẬN LÂM SÀNG)
    // =========================================================================

    public function lichSuKham(Request $request)
    {
        $phone = $request->query('phone');
        if (! $phone) {
            return response()->json(['data' => []]);
        }

        $benhNhan = BenhNhan::where('so_dien_thoai', $phone)->first();
        if (! $benhNhan) {
            return response()->json(['data' => []]);
        }

        $hoSoIds = HoSoBenhAn::where('ma_benh_nhan', $benhNhan->ma_benh_nhan)->pluck('ma_ho_so');

        $luotKhamIds = LichKham::whereIn('ma_ho_so', $hoSoIds)->pluck('ma_luot_kham');

        $phienKhams = PhienKham::with(['lichKham.bacSi', 'donThuoc.chiTiet.thuoc'])
            ->whereIn('ma_lich_dat', $luotKhamIds)
            ->orderBy('ngay_tao', 'desc')->get();

        $data = $phienKhams->map(function ($pk) {
            $thuocList = [];
            if ($pk->donThuoc) {
                foreach ($pk->donThuoc->chiTiet as $ct) {
                    $thuocList[] = [
                        'name' => $ct->thuoc->ten_thuoc ?? 'N/A',
                        'quantity' => $ct->so_luong,
                        'dosage' => $ct->lieu_luong,
                    ];
                }
            }

            return [
                'id' => $pk->ma_phien_kham,
                'date' => Carbon::parse($pk->ngay_tao)->format('d/m/Y'),
                'department' => $pk->lichKham->bacSi->chuyenKhoa->ten_chuyen_khoa ?? 'Đa khoa',
                'doctor' => $pk->lichKham->bacSi->ho_ten ?? 'Bác sĩ',
                'room' => 'Phòng khám',
                'diagnosis' => $pk->chan_doan_cuoi_cung ?? 'Chưa có kết luận',
                'note' => $pk->ghi_chu_y_te,
                'medications' => $thuocList,
            ];
        });

        return response()->json(['data' => $data], 200);
    }

    public function ketQuaCls(Request $request)
    {
        $phone = $request->query('phone');
        $benhNhan = BenhNhan::where('so_dien_thoai', $phone)->first();
        if (! $benhNhan) {
            return response()->json(['data' => []]);
        }

        $hoSoIds = HoSoBenhAn::where('ma_benh_nhan', $benhNhan->ma_benh_nhan)->pluck('ma_ho_so');

        // Lấy danh sách chỉ định dịch vụ
        $chiDinhs = ChiDinhDichVu::with(['phienKham.lichKham.bacSi', 'dichVu'])
            ->whereHas('phienKham.lichKham', function ($q) use ($hoSoIds) {
                $q->whereIn('ma_ho_so', $hoSoIds);
            })->orderBy('ma_chi_dinh', 'desc')->get();

        $data = $chiDinhs->map(function ($cd) {
            return [
                'id' => $cd->ma_chi_dinh,
                'date' => $cd->phienKham && $cd->phienKham->ngay_tao ? Carbon::parse($cd->phienKham->ngay_tao)->format('d/m/Y') : '',
                'test_name' => $cd->dichVu->ten_dich_vu ?? 'Xét nghiệm',
                'department' => $cd->phienKham->lichKham->bacSi->chuyenKhoa->ten_chuyen_khoa ?? 'Đa khoa',
                'doctor' => $cd->phienKham->lichKham->bacSi->ho_ten ?? 'Bác sĩ',
                'result' => $cd->ket_qua_chi_tiet ?? 'Chưa có kết quả',
                'status' => $cd->trang_thai === 'DaCoKetQua' ? 'Đã có kết quả' : 'Đang chờ',
                'price' => number_format($cd->dichVu->don_gia ?? 0, 0, ',', '.').'đ',
            ];
        });

        return response()->json(['data' => $data], 200);
    }

    // =========================================================================
    // 5. BHYT & VNPAY
    // =========================================================================

    public function traCuuBhyt(Request $request)
    {
        $maThe = $request->input('ma_the');
        // Gọi thử rule validate BHYT (nếu hợp lệ thì trả về true)
        $validator = Validator::make(['ma_the' => $maThe], [
            'ma_the' => [new ValidBhyt(null)],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'invalid',
                'message' => $validator->errors()->first('ma_the'),
                'is_blacklisted' => false,
            ]);
        }

        return response()->json([
            'status' => 'valid',
            'is_blacklisted' => false,
            'ma_the' => $maThe,
        ], 200);
    }

    /**
     * GET /api/mobile/vnpay/payment-url?amount=150000&ma_luot_kham=5
     */
    public function vnpayPaymentUrl(Request $request)
    {
        $maLuotKham = $request->query('ma_luot_kham');
        $rawAmount = $request->query('amount', 0);
        $amount = is_numeric($rawAmount) ? (float) $rawAmount : -1;

        if (! is_string($maLuotKham) || trim($maLuotKham) === '') {
            return response()->json([
                'status' => 'error',
                'message' => 'Mã lượt khám không hợp lệ.',
            ], 422);
        }

        $maLuotKham = trim($maLuotKham);
        $maLuotKhamIds = explode('-', $maLuotKham);
        $validIds = [];
        foreach ($maLuotKhamIds as $id) {
            if (! ctype_digit($id) || (int) $id < 1) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Danh sách mã lượt khám không hợp lệ.',
                ], 422);
            }
            $validIds[] = (int) $id;
        }
        $maLuotKhamIds = array_values(array_unique($validIds));
        if (count($maLuotKhamIds) !== count($validIds)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Danh sách mã lượt khám bị trùng.',
            ], 422);
        }

        $luotKhams = LichKham::with('phienKham.hoaDon')
            ->whereIn('ma_luot_kham', $maLuotKhamIds)
            ->get();
        if ($luotKhams->count() !== count($maLuotKhamIds)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Không tìm thấy đầy đủ các lượt khám đã yêu cầu.',
            ], 404);
        }

        $hoaDons = $luotKhams
            ->map(fn ($luotKham) => $luotKham->phienKham?->hoaDon)
            ->filter();
        $isInvoicePayment = $hoaDons->isNotEmpty();

        if ($isInvoicePayment && ($luotKhams->count() !== 1 || $hoaDons->count() !== 1)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Mỗi hóa đơn cần được thanh toán riêng.',
            ], 422);
        }

        $hoaDon = $isInvoicePayment ? $hoaDons->first() : null;
        if ($hoaDon && $hoaDon->trang_thai !== 'ChuaThanhToan') {
            return response()->json([
                'status' => 'error',
                'message' => 'Hóa đơn không ở trạng thái chờ thanh toán.',
            ], 409);
        }

        $expectedAmount = $hoaDon
            ? (float) $hoaDon->tien_benh_nhan_tra
            : $luotKhams->sum(
                fn ($luotKham): float => (float) ($luotKham->so_tien ?? 150000)
            );
        if (round($amount, 2) !== round($expectedAmount, 2)) {
            return response()->json([
                'status' => 'error',
                'message' => $hoaDon
                    ? 'Số tiền thanh toán không khớp với số dư hóa đơn.'
                    : 'Số tiền thanh toán không khớp với các lượt khám.',
            ], 422);
        }

        if ($amount < 5000) {
            if ($hoaDon) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Số dư hóa đơn phải từ 5.000đ trở lên để thanh toán qua VNPay.',
                ], 422);
            }

            if ($amount <= 0) {
                foreach ($luotKhams as $luotKham) {
                    $luotKham->update(['trang_thai' => 'da_thanh_toan']);
                    if ($luotKham->phienKham?->hoaDon) {
                        $luotKham->phienKham->hoaDon->update(['trang_thai' => 'DaThanhToan']);
                    }
                }

                return response()->json([
                    'status' => 'error',
                    'message' => 'Lượt khám này đã được miễn phí 100%, không cần thanh toán.',
                ]);
            }

            return response()->json([
                'status' => 'error',
                'message' => 'Số tiền thanh toán qua VNPay phải từ 5.000đ trở lên.',
            ]);
        }

        // Lấy config VNPay
        $vnp_TmnCode = config('services.vnpay.tmn_code');
        $vnp_HashSecret = config('services.vnpay.hash_secret');
        $vnp_Url = config('services.vnpay.url');

        if (! $vnp_TmnCode || ! $vnp_HashSecret) {
            return response()->json([
                'status' => 'error',
                'message' => 'Chưa cấu hình VNPay. Cần thêm VNPAY_TMN_CODE và VNPAY_HASH_SECRET vào .env',
            ], 500);
        }

        // Tạo mã giao dịch
        $vnp_TxnRef = $hoaDon
            ? 'INVOICE_'.$hoaDon->ma_hoa_don.'_'.time()
            : 'BOOKING_'.$maLuotKham.'_'.time();
        $vnp_OrderInfo = $hoaDon
            ? 'Thanh toan hoa don '.$hoaDon->ma_hoa_don
            : 'Thanh toan phi kham luot '.$maLuotKham;
        $vnp_OrderType = 'other';
        $vnp_Amount = (int) ($amount * 100);
        $vnp_Locale = 'vn';
        $vnp_IpAddr = $request->ip();

        $vnp_ReturnUrl = config('services.vnpay.return_url')
            ?: $request->getSchemeAndHttpHost().'/api/mobile/vnpay/return';

        date_default_timezone_set('Asia/Ho_Chi_Minh');
        $vnp_CreateDate = date('YmdHis');
        $vnp_ExpireDate = date('YmdHis', strtotime('+15 minutes'));

        $inputData = [
            'vnp_Version' => '2.1.0',
            'vnp_TmnCode' => $vnp_TmnCode,
            'vnp_Amount' => $vnp_Amount,
            'vnp_Command' => 'pay',
            'vnp_CreateDate' => $vnp_CreateDate,
            'vnp_CurrCode' => 'VND',
            'vnp_IpAddr' => $vnp_IpAddr,
            'vnp_Locale' => $vnp_Locale,
            'vnp_OrderInfo' => $vnp_OrderInfo,
            'vnp_OrderType' => $vnp_OrderType,
            'vnp_ReturnUrl' => $vnp_ReturnUrl,
            'vnp_TxnRef' => $vnp_TxnRef,
            'vnp_ExpireDate' => $vnp_ExpireDate,
        ];

        ksort($inputData);
        $hashData = '';
        $query = '';
        $i = 0;
        foreach ($inputData as $key => $value) {
            if ($i === 1) {
                $hashData .= '&'.urlencode($key).'='.urlencode($value);
            } else {
                $hashData .= urlencode($key).'='.urlencode($value);
                $i = 1;
            }
            $query .= urlencode($key).'='.urlencode($value).'&';
        }

        // ⚠️ TÊN BIẾN PHẢI LÀ $vnpSecureHash (chữ S viết hoa, không có dấu _)
        $vnpSecureHash = hash_hmac('sha512', $hashData, $vnp_HashSecret);

        // ⚠️ DÙNG ĐÚNG $vnpSecureHash Ở ĐÂY
        $paymentUrl = $vnp_Url.'?'.$query.'vnp_SecureHash='.$vnpSecureHash;

        return response()->json([
            'status' => 'success',
            'message' => 'Tạo URL thanh toán thành công',
            'payment_url' => $paymentUrl,
            'txn_ref' => $vnp_TxnRef,
        ]);
    }

    /**
     * GET /api/mobile/vnpay/return
     * VNPay redirect về đây sau khi thanh toán xong
     */
    public function vnpayReturn(Request $request)
    {
        $vnp_HashSecret = config('services.vnpay.hash_secret');
        $inputData = $request->all();
        $vnp_SecureHash = $inputData['vnp_SecureHash'] ?? '';
        unset($inputData['vnp_SecureHash']);
        unset($inputData['vnp_SecureHashType']);

        $inputDataIsScalar = true;
        foreach ($inputData as $key => $value) {
            if (! is_scalar($value)) {
                $inputDataIsScalar = false;
                $inputData[$key] = '';
            }
        }

        ksort($inputData);
        $hashData = '';
        $i = 0;
        foreach ($inputData as $key => $value) {
            if ($i == 1) {
                $hashData .= '&'.urlencode($key).'='.urlencode($value);
            } else {
                $hashData .= urlencode($key).'='.urlencode($value);
                $i = 1;
            }
        }

        $secureHash = is_string($vnp_HashSecret) && $vnp_HashSecret !== ''
            ? hash_hmac('sha512', $hashData, $vnp_HashSecret)
            : '';
        $responseCode = $inputData['vnp_ResponseCode'] ?? '';
        $transactionStatus = $inputData['vnp_TransactionStatus'] ?? '';
        $txnRef = $inputData['vnp_TxnRef'] ?? '';
        $responseCode = is_string($responseCode) ? $responseCode : '';
        $transactionStatus = is_string($transactionStatus) ? $transactionStatus : '';
        $txnRef = is_string($txnRef) ? $txnRef : '';

        $parts = explode('_', $txnRef);
        $paymentType = $parts[0] ?? '';
        $hoaDon = null;
        $validIds = [];
        $expectedAmount = 0;

        if ($paymentType === 'INVOICE' && isset($parts[1]) && ctype_digit($parts[1])) {
            $hoaDon = HoaDon::with('phienKham.lichKham')->find((int) $parts[1]);
            $lichKham = $hoaDon?->phienKham?->lichKham;
            if ($lichKham) {
                $validIds = [(int) $lichKham->ma_luot_kham];
                $expectedAmount = (float) $hoaDon->tien_benh_nhan_tra;
            }
        } elseif ($paymentType === 'BOOKING') {
            $rawIdList = $parts[1] ?? '';
            $maLuotKhamIds = $rawIdList === '' ? [] : explode('-', $rawIdList);
            foreach ($maLuotKhamIds as $id) {
                if (! ctype_digit($id) || (int) $id < 1) {
                    $validIds = [];
                    break;
                }
                $validIds[] = (int) $id;
            }
            if (count(array_unique($validIds)) !== count($validIds)) {
                $validIds = [];
            }

            $luotKhams = $validIds
                ? LichKham::whereIn('ma_luot_kham', $validIds)->get()
                : collect();
            $expectedAmount = $luotKhams->sum(
                fn ($luotKham): float => (float) ($luotKham->so_tien ?? 150000)
            );
        }

        $rawCallbackAmount = $inputData['vnp_Amount'] ?? '';
        $callbackAmount = is_numeric($rawCallbackAmount) ? (int) $rawCallbackAmount : 0;
        $signatureIsValid = $inputDataIsScalar
            && $secureHash !== ''
            && is_string($vnp_SecureHash)
            && hash_equals($secureHash, $vnp_SecureHash);
        $expectedMerchantCode = config('services.vnpay.tmn_code');
        $receivedMerchantCode = $inputData['vnp_TmnCode'] ?? null;
        $merchantIsValid = is_string($expectedMerchantCode)
            && $expectedMerchantCode !== ''
            && is_string($receivedMerchantCode)
            && hash_equals($expectedMerchantCode, $receivedMerchantCode);
        $appointmentsAreValid = false;
        if ($paymentType === 'INVOICE') {
            $appointmentsAreValid = $hoaDon !== null
                && $validIds !== []
                && in_array($hoaDon->trang_thai, ['ChuaThanhToan', 'DaThanhToan'], true)
                && $expectedAmount > 0
                && $callbackAmount === (int) round($expectedAmount * 100);
        } elseif ($paymentType === 'BOOKING') {
            $appointmentsAreValid = $validIds !== []
                && $luotKhams->count() === count($validIds)
                && $callbackAmount === (int) round($expectedAmount * 100);
        }
        $success = $signatureIsValid
            && $merchantIsValid
            && $appointmentsAreValid
            && $responseCode === '00'
            && $transactionStatus === '00';

        if ($success) {
            if ($paymentType === 'INVOICE') {
                DB::transaction(function () use ($hoaDon): void {
                    if ($hoaDon->trang_thai !== 'DaThanhToan') {
                        $hoaDon->update([
                            'trang_thai' => 'DaThanhToan',
                            'phuong_thuc' => 'VNPay',
                            'ngay_thanh_toan' => now(),
                        ]);
                    }

                    $phienKham = $hoaDon->phienKham;
                    if ($phienKham) {
                        $phienKham->update(['trang_thai' => 'HoanThanh']);
                        $phienKham->lichKham?->update(['trang_thai' => 'hoan_thanh']);
                    }
                });
            } else {
                LichKham::whereIn('ma_luot_kham', $validIds)
                    ->update(['trang_thai' => 'da_thanh_toan']);
            }
        }

        $deepLink = 'clinicapp:///payment-result?'.http_build_query([
            'status' => $success ? 'success' : 'failed',
            'ma_luot_kham' => implode('-', $validIds),
            'amount' => $callbackAmount / 100,
            'response_code' => $responseCode,
            'payment_type' => $paymentType === 'INVOICE' ? 'invoice' : 'booking',
        ], '', '&', PHP_QUERY_RFC3986);

        return response()->view('mobile.vnpay-return', [
            'isSuccess' => $success,
            'responseCode' => $responseCode,
            'deepLink' => $deepLink,
        ]);
    }

    public function bacSi(Request $request)
    {
        $query = BacSi::with('chuyenKhoa');
        if ($maCK = $request->query('ma_chuyen_khoa')) {
            $query->where('ma_chuyen_khoa', $maCK);
        }
        $data = $query->get()->map(function ($bs) {
            return [
                'ma_bs' => $bs->ma_bs,
                'ho_ten' => $bs->ho_ten,
                'trinh_do' => $bs->trinh_do,
                'ma_chuyen_khoa' => $bs->ma_chuyen_khoa,
                // Làm phẳng (flatten) dữ liệu chuyên khoa thành chuỗi String
                'chuyen_khoa' => $bs->chuyenKhoa ? $bs->chuyenKhoa->ten_chuyen_khoa : 'Đa khoa',
            ];
        });

        return response()->json(['status' => 'success', 'data' => $data]);
    }
}
