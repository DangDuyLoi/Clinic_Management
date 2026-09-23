<?php

namespace App\Http\Controllers;

use App\Models\Thuoc;
use Illuminate\Http\Request;

class ThuocController extends Controller
{
    /**
     * GET /api/thuoc
     * Query: ?q=search
     */
    public function index(Request $request)
    {
        $query = Thuoc::query();

        if ($q = $request->query('q')) {
            $query->where('ten_thuoc', 'like', "%{$q}%");
        }

        return response()->json([
            'status' => 'success',
            'data'   => $query->orderBy('ten_thuoc')->get(),
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'ten_thuoc'    => 'required|string|max:150|unique:Thuoc,ten_thuoc',
            'don_vi_tinh'  => 'nullable|string|max:50',
            'don_gia'      => 'required|numeric|min:0',
            'so_luong_ton' => 'nullable|integer|min:0',
        ]);

        $t = Thuoc::create($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Thêm thuốc thành công',
            'data'    => $t,
        ], 201);
    }

    public function show($id)
    {
        $t = Thuoc::find($id);
        if (!$t) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy thuốc'], 404);
        }
        return response()->json(['status' => 'success', 'data' => $t]);
    }

    public function update(Request $request, $id)
    {
        $t = Thuoc::find($id);
        if (!$t) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy thuốc'], 404);
        }

        $data = $request->validate([
            'ten_thuoc'    => 'sometimes|string|max:150|unique:Thuoc,ten_thuoc,' . $id . ',ma_thuoc',
            'don_vi_tinh'  => 'nullable|string|max:50',
            'don_gia'      => 'sometimes|numeric|min:0',
            'so_luong_ton' => 'sometimes|integer|min:0',
        ]);

        $t->update($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Cập nhật thành công',
            'data'    => $t,
        ]);
    }

    public function destroy($id)
    {
        $t = Thuoc::find($id);
        if (!$t) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy thuốc'], 404);
        }
        $t->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã xóa thuốc',
        ]);
    }
}