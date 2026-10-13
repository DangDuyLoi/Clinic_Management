<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $isSuccess ? 'Thanh toán thành công' : 'Thanh toán thất bại' }} — HUIT Care</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Plus Jakarta Sans', sans-serif;
        }
        body {
            background: linear-gradient(135deg, #f0f7ff 0%, #e8f0fe 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            color: #1e293b;
        }
        .card {
            background: #ffffff;
            border-radius: 24px;
            box-shadow: 0 20px 40px rgba(15, 23, 42, 0.08);
            max-width: 420px;
            width: 100%;
            padding: 36px 28px;
            text-align: center;
            animation: fadeIn 0.4s ease-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(12px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .icon-circle {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
        }
        .success-circle {
            background: #e6f9f0;
            color: #059669;
        }
        .failed-circle {
            background: #fee2e2;
            color: #dc2626;
        }
        .icon-circle svg {
            width: 44px;
            height: 44px;
        }
        h1 {
            font-size: 22px;
            font-weight: 700;
            margin-bottom: 8px;
            color: #0f172a;
        }
        .subtitle {
            font-size: 14px;
            color: #64748b;
            margin-bottom: 24px;
            line-height: 1.5;
        }
        .info-box {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            padding: 16px;
            margin-bottom: 24px;
            text-align: left;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            font-size: 14px;
            border-bottom: 1px dashed #e2e8f0;
        }
        .info-row:last-child {
            border-bottom: none;
        }
        .info-label {
            color: #64748b;
        }
        .info-val {
            font-weight: 600;
            color: #0f172a;
        }
        .amount-val {
            color: #0284c7;
            font-size: 16px;
        }
        .btn-action {
            display: block;
            width: 100%;
            padding: 14px;
            border-radius: 14px;
            font-size: 15px;
            font-weight: 600;
            text-decoration: none;
            border: none;
            cursor: pointer;
            transition: all 0.2s;
            margin-bottom: 10px;
        }
        .btn-primary {
            background: #0284c7;
            color: #ffffff;
            box-shadow: 0 4px 14px rgba(2, 132, 199, 0.3);
        }
        .btn-primary:hover {
            background: #0369a1;
        }
        .btn-secondary {
            background: #f1f5f9;
            color: #475569;
        }
        .btn-secondary:hover {
            background: #e2e8f0;
        }
        .hint {
            font-size: 12px;
            color: #94a3b8;
            margin-top: 14px;
            line-height: 1.4;
        }
    </style>
</head>
<body>
    <div class="card">
        @if($isSuccess)
            <div class="icon-circle success-circle">
                <svg fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path>
                </svg>
            </div>
            <h1>Thanh toán thành công!</h1>
            <p class="subtitle">Lượt khám của bạn đã được thanh toán hoàn tất. Mã QR check-in đã sẵn sàng trên ứng dụng.</p>

            <div class="info-box">
                <div class="info-row">
                    <span class="info-label">Mã lượt khám:</span>
                    <span class="info-val">#{{ $maLuotKham }}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Số tiền:</span>
                    <span class="info-val amount-val">{{ number_format($amount, 0, ',', '.') }} VNĐ</span>
                </div>
                @if(!empty($transactionNo))
                <div class="info-row">
                    <span class="info-label">Mã giao dịch VNPay:</span>
                    <span class="info-val">{{ $transactionNo }}</span>
                </div>
                @endif
                <div class="info-row">
                    <span class="info-label">Trạng thái:</span>
                    <span class="info-val" style="color:#059669">Đã thanh toán</span>
                </div>
            </div>

            <a href="clinicapp://payment-result?status=success&ma_luot_kham={{ $maLuotKham }}" class="btn-action btn-primary" id="openAppBtn">
                📱 Quay lại ứng dụng
            </a>
            <p class="hint">Ứng dụng sẽ tự động cập nhật khi bạn mở lại màn hình. Bạn có thể đóng tab này.</p>
        @else
            <div class="icon-circle failed-circle">
                <svg fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
            </div>
            <h1>Thanh toán không thành công</h1>
            <p class="subtitle">Giao dịch đã bị hủy hoặc xảy ra lỗi trong quá trình xử lý (Mã lỗi: {{ $responseCode ?? 'Unknown' }}).</p>

            <div class="info-box">
                @if(!empty($maLuotKham))
                <div class="info-row">
                    <span class="info-label">Mã lượt khám:</span>
                    <span class="info-val">#{{ $maLuotKham }}</span>
                </div>
                @endif
                <div class="info-row">
                    <span class="info-label">Trạng thái:</span>
                    <span class="info-val" style="color:#dc2626">Chưa hoàn tất</span>
                </div>
            </div>

            <a href="clinicapp://payment-result?status=failed&ma_luot_kham={{ $maLuotKham }}" class="btn-action btn-secondary" id="openAppBtn">
                Quay lại ứng dụng thử lại
            </a>
            <p class="hint">Vui lòng quay lại ứng dụng để thực hiện lại thanh toán.</p>
        @endif
    </div>

    <script>
        // Tự động kích hoạt deep link về app sau 1.5 giây
        setTimeout(function() {
            var deepLink = document.getElementById('openAppBtn');
            if (deepLink && deepLink.href) {
                window.location.href = deepLink.href;
            }
        }, 1500);
    </script>
</body>
</html>
