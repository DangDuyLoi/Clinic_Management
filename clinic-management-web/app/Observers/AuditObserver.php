<?php

namespace App\Observers;

use App\Models\NhatKyHeThong;
use Illuminate\Database\Eloquent\Model;

class AuditObserver
{
    /**
     * Khi tạo mới bản ghi
     */
    public function created(Model $model): void
    {
        $this->ghiLog('CREATE', $model, null, $model->getAttributes());
    }

    /**
     * Khi cập nhật bản ghi
     */
    public function updated(Model $model): void
    {
        $this->ghiLog('UPDATE', $model, $model->getOriginal(), $model->getChanges());
    }

    /**
     * Khi xóa bản ghi
     */
    public function deleted(Model $model): void
    {
        $this->ghiLog('DELETE', $model, $model->getOriginal(), null);
    }

    /**
     * Hàm ghi log chính
     */
    private function ghiLog(string $hanhDong, Model $model, ?array $duLieuCu, ?array $duLieuMoi): void
    {
        // Bỏ qua chính bảng NhatKyHeThong (tránh đệ quy)
        if ($model instanceof NhatKyHeThong) {
            return;
        }

        // Lấy user đang đăng nhập (nếu có)
        $maTk = $this->getCurrentUserId();

        // Không log nếu không có user (VD: seed data, CLI)
        if (!$maTk) {
            return;
        }

        // Loại bỏ các cột nhạy cảm
        $duLieuCu  = $this->loaiBoNhayCam($duLieuCu);
        $duLieuMoi = $this->loaiBoNhayCam($duLieuMoi);

        // Rút gọn dữ liệu (tránh quá dài)
        $duLieuCu  = $this->rutGon($duLieuCu);
        $duLieuMoi = $this->rutGon($duLieuMoi);

        try {
            NhatKyHeThong::create([
                'ma_tk'         => $maTk,
                'hanh_dong'     => $hanhDong,
                'bang_tac_dong' => $model->getTable(),
                'du_lieu_cu'    => $duLieuCu,
                'du_lieu_moi'   => $duLieuMoi,
            ]);
        } catch (\Exception $e) {
            // Không làm crash app nếu ghi log thất bại
            \Log::warning('Không ghi được nhật ký: ' . $e->getMessage());
        }
    }

    /**
     * Lấy mã tài khoản của user hiện tại
     */
    private function getCurrentUserId(): ?int
    {
        try {
            $user = auth('api')->user();
            return $user?->ma_tk;
        } catch (\Exception $e) {
            return null;
        }
    }

    /**
     * Loại bỏ các trường nhạy cảm
     */
    private function loaiBoNhayCam(?array $data): ?array
    {
        if (!$data) return null;

        $nhayCam = ['mat_khau', 'remember_token', 'password', 'token'];
        foreach ($nhayCam as $field) {
            unset($data[$field]);
        }

        return $data;
    }

    /**
     * Rút gọn dữ liệu — tránh lưu quá dài
     */
    private function rutGon(?array $data): ?array
    {
        if (!$data) return null;

        // Giới hạn độ dài mỗi field text
        foreach ($data as $key => $value) {
            if (is_string($value) && strlen($value) > 500) {
                $data[$key] = substr($value, 0, 500) . '...';
            }
        }

        // Chỉ giữ tối đa 30 field
        if (count($data) > 30) {
            $data = array_slice($data, 0, 30, true);
        }

        return $data;
    }
}