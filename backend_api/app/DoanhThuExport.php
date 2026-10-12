<?php

namespace App\Exports;

use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;

class DoanhThuExport implements FromCollection, WithHeadings, WithMapping
{
    protected $tuNgay;
    protected $denNgay;

    // Nhận ngày tháng từ Controller truyền sang
    public function __construct($tuNgay, $denNgay)
    {
        $this->tuNgay = $tuNgay;
        $this->denNgay = $denNgay;
    }

    // Lấy dữ liệu từ Database
    public function collection()
    {
        return DB::table('HoaDon')
            ->where('trang_thai', 'DaThanhToan')
            ->whereBetween('ngay_thanh_toan', [$this->tuNgay . ' 00:00:00', $this->denNgay . ' 23:59:59'])
            ->select('ma_hoa_don', 'ma_phien_kham', 'ngay_thanh_toan', 'phuong_thuc', 'tong_cong')
            ->orderBy('ngay_thanh_toan', 'desc')
            ->get();
    }

    // Tiêu đề các cột trong file Excel
    public function headings(): array
    {
        return [
            'Mã Hóa Đơn',
            'Mã Phiên Khám',
            'Ngày Thanh Toán',
            'Phương Thức',
            'Tổng Tiền (VNĐ)'
        ];
    }

    // Map dữ liệu vào từng dòng
    public function map($hoaDon): array
    {
        return [
            $hoaDon->ma_hoa_don,
            $hoaDon->ma_phien_kham,
            $hoaDon->ngay_thanh_toan,
            $hoaDon->phuong_thuc,
            number_format($hoaDon->tong_cong, 0, ',', '.') . ' VNĐ'
        ];
    }
}
