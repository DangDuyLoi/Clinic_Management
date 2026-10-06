<?php
$vnp_TmnCode = "EMECLOTV";
$vnp_HashSecret = "DDRHKNYLVCLJGUWGLYOBANHQMQZDJZQI";
$vnp_Url = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
$vnp_Returnurl = "clinicapp://vnpay-return";
$vnp_TxnRef = "20261006182500";
$vnp_OrderInfo = "Thanh toan vien phi";
$vnp_OrderType = "other";
$vnp_Amount = 15000000;
$vnp_Locale = "vn";
$vnp_IpAddr = "127.0.0.1";

$inputData = array(
    "vnp_Version" => "2.1.0",
    "vnp_TmnCode" => $vnp_TmnCode,
    "vnp_Amount" => $vnp_Amount,
    "vnp_Command" => "pay",
    "vnp_CreateDate" => "20261006182500",
    "vnp_CurrCode" => "VND",
    "vnp_IpAddr" => $vnp_IpAddr,
    "vnp_Locale" => $vnp_Locale,
    "vnp_OrderInfo" => $vnp_OrderInfo,
    "vnp_OrderType" => $vnp_OrderType,
    "vnp_ReturnUrl" => $vnp_Returnurl,
    "vnp_TxnRef" => $vnp_TxnRef,
    "vnp_ExpireDate"=> "20261006184000"
);

ksort($inputData);
$query = "";
$i = 0;
$hashdata = "";
foreach ($inputData as $key => $value) {
    if ($i == 1) {
        $hashdata .= '&' . rawurlencode($key) . "=" . rawurlencode($value);
    } else {
        $hashdata .= rawurlencode($key) . "=" . rawurlencode($value);
        $i = 1;
    }
    $query .= urlencode($key) . "=" . urlencode($value) . '&';
}

$vnp_Url = $vnp_Url . "?" . $query;
if (isset($vnp_HashSecret)) {
    $vnpSecureHash =   hash_hmac('sha512', $hashdata, $vnp_HashSecret);
    $vnp_Url .= 'vnp_SecureHash=' . $vnpSecureHash;
}
echo "PHP HashData: " . $hashdata . "\n";
echo "PHP SecureHash: " . $vnpSecureHash . "\n";
?>
