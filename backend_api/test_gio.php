<?php
$req = new Illuminate\Http\Request(['ma_bac_si' => 1, 'ngay_kham' => '2026-10-07']);
echo (new App\Http\Controllers\LuotKhamController)->layGioTrong($req)->getContent();
