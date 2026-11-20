<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $isSuccess ? 'Thanh toán thành công' : 'Thanh toán chưa thành công' }} — HUIT Care</title>
</head>
<body>
    <main>
        <h1>{{ $isSuccess ? 'Thanh toán thành công' : 'Thanh toán chưa thành công' }}</h1>
        <p>
            {{ $isSuccess
                ? 'Trạng thái đã được cập nhật. Bạn sẽ được chuyển về ứng dụng.'
                : 'Giao dịch chưa được xác nhận. Vui lòng quay lại ứng dụng để kiểm tra hoặc thử lại.' }}
        </p>
        @if (!$isSuccess && $responseCode !== '')
            <p>Mã phản hồi VNPay: {{ $responseCode }}</p>
        @endif
        <a id="openApp" href="{{ $deepLink }}">Mở lại ứng dụng HUIT Care</a>
    </main>
    <script>
        window.setTimeout(function () {
            window.location.href = document.getElementById('openApp').href;
        }, 500);
    </script>
</body>
</html>
