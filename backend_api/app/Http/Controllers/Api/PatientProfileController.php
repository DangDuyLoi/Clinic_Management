<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\HoSoBenhAn;
use App\Models\BenhNhan;
use App\Http\Requests\PatientProfileRequest;

class PatientProfileController extends Controller
{
    /**
     * Store a newly created patient profile.
     */
    public function store(PatientProfileRequest $request)
    {
        $data = $request->validated();
        
        // If ma_benh_nhan is not provided, we should probably create one, 
        // but since we don't have authentication context in this example, 
        // let's just create a BenhNhan if it doesn't exist, or use a dummy one for now.
        // Actually, the requirement says "CHƯA TỪNG KHÁM, TẠO HỒ SƠ MỚI", so we create a new BenhNhan first.
        
        $benhNhan = null;
        if (isset($data['ma_benh_nhan'])) {
            $benhNhan = BenhNhan::find($data['ma_benh_nhan']);
        }
        
        if (!$benhNhan) {
            $benhNhan = BenhNhan::firstOrCreate(
                ['so_dien_thoai' => $data['so_dien_thoai']],
                [
                    'ho_ten' => $data['ho_chu_lot'] . ' ' . $data['ten'],
                    'ngay_sinh' => $data['ngay_sinh'],
                    'gioi_tinh' => $data['gioi_tinh'],
                    'dia_chi' => $data['so_nha'] . ', ' . $data['phuong_xa'] . ', ' . $data['tinh_thanh'],
                ]
            );
        }

        $data['ma_benh_nhan'] = $benhNhan->ma_benh_nhan;

        $hoSo = HoSoBenhAn::create($data);

        return response()->json([
            'message' => 'Hồ sơ đã được tạo thành công.',
            'data' => $hoSo
        ], 201);
    }

    /**
     * Find a profile by code (ma_ho_so or ma_benh_nhan).
     */
    public function findByCode(Request $request)
    {
        $request->validate([
            'code' => 'required|string'
        ]);
        
        $code = $request->code;
        
        // Assuming code could be ma_ho_so
        // Example "N24-XXXXX" format mapping, but for now we search by ID directly
        // Let's strip "N24-" if it exists
        $id = preg_replace('/^N\d{2}-/', '', $code);

        $hoSo = HoSoBenhAn::with('benhNhan')->find($id);

        if (!$hoSo) {
            return response()->json(['message' => 'Không tìm thấy hồ sơ'], 404);
        }

        return response()->json(['data' => $hoSo], 200);
    }

    /**
     * Find a profile by personal info.
     */
    public function findByInfo(Request $request)
    {
        $request->validate([
            'ho_chu_lot' => 'required|string',
            'ten' => 'required|string',
            'so_dien_thoai' => 'required|string',
            'gioi_tinh' => 'required|in:0,1',
            'ngay_sinh' => 'required|date' // Assuming year of birth is passed as date or just year
        ]);

        // Search in HoSoBenhAn
        $hoSo = HoSoBenhAn::with('benhNhan')
            ->where('ho_chu_lot', $request->ho_chu_lot)
            ->where('ten', $request->ten)
            ->where('so_dien_thoai', $request->so_dien_thoai)
            ->where('gioi_tinh', $request->gioi_tinh)
            // If they pass year only, we might need whereYear, but let's assume they pass full date or we check year
            ->whereYear('ngay_sinh', date('Y', strtotime($request->ngay_sinh)))
            ->first();

        if (!$hoSo) {
            return response()->json(['message' => 'Không tìm thấy hồ sơ'], 404);
        }

        return response()->json(['data' => $hoSo], 200);
    }
}
