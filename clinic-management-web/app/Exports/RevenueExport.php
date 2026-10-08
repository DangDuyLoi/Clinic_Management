<?php

namespace App\Exports;

use App\Models\HoaDon;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithTitle;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class RevenueExport implements FromCollection, WithHeadings, WithStyles, WithTitle
{
    protected $from;
    protected $to;

    public function __construct($from, $to)
    {
        $this->from = $from;
        $this->to = $to;
    }

    public function collection()
    {
        return HoaDon::with(['phienKham.lichKham.benhNhan', 'phienKham.lichKham.bacSi'])
            ->where('trang_thai', 'DaThanhToan')
            ->whereBetween('ngay_thanh_toan', [$this->from . ' 00:00:00', $this->to . ' 23:59:59'])
            ->orderBy('ngay_thanh_toan')
            ->get()
            ->map(function ($hd) {
                $bn = $hd->phienKham?->lichKham?->benhNhan?->ho_ten ?? '—';
                $bs = $hd->phienKham?->lichKham?->bacSi?->ho_ten ?? '—';
                return [
                    $hd->ma_hoa_don,
                    \Carbon\Carbon::parse($hd->ngay_thanh_toan)->format('d/m/Y H:i'),
                    $bn,
                    $bs,
                    number_format($hd->tien_kham_benh, 0, ',', '.'),
                    number_format($hd->tien_dich_vu, 0, ',', '.'),
                    number_format($hd->tien_thuoc, 0, ',', '.'),
                    number_format($hd->tong_cong, 0, ',', '.'),
                    $hd->phuong_thuc,
                ];
            });
    }

    public function headings(): array
    {
        return [
            'Mã HĐ', 'Ngày thanh toán', 'Bệnh nhân', 'Bác sĩ',
            'Tiền khám (VNĐ)', 'Tiền dịch vụ (VNĐ)', 'Tiền thuốc (VNĐ)',
            'Tổng cộng (VNĐ)', 'Phương thức',
        ];
    }

    public function styles(Worksheet $sheet)
    {
        return [
            1 => [
                'font' => ['bold' => true, 'color' => ['rgb' => 'FFFFFF']],
                'fill' => ['fillType' => 'solid', 'color' => ['rgb' => '0D6EFD']],
            ],
        ];
    }

    public function title(): string
    {
        return 'Doanh thu';
    }
}