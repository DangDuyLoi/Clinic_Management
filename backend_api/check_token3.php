<?php
$l = App\Models\LuotKham::find(13);
if (!$l) { echo "No luot kham 13\n"; exit; }
$h = DB::table('ho_so_benh_an')->where('ma_ho_so', $l->ma_ho_so)->first();
$b = DB::table('benh_nhan')->where('ma_benh_nhan', $h->ma_benh_nhan)->first();
echo "PHONE_IS: '" . $b->so_dien_thoai . "'\n";
$user = App\Models\User::whereIn('phone_number', [$b->so_dien_thoai, str_starts_with($b->so_dien_thoai, '+84') ? '0' . substr($b->so_dien_thoai, 3) : $b->so_dien_thoai, str_starts_with($b->so_dien_thoai, '0') ? '+84' . substr($b->so_dien_thoai, 1) : $b->so_dien_thoai])->first();
echo "USER FOUND? " . ($user ? "YES " . $user->phone_number : "NO") . "\n";
