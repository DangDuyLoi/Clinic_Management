<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tiếp nhận bệnh nhân thành công — HUIT Care</title>
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
            background: linear-gradient(135deg, #f0fdf4 0%, #ecfdf5 100%);
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
            box-shadow: 0 20px 40px rgba(5, 150, 105, 0.12);
            max-width: 440px;
            width: 100%;
            padding: 36px 28px;
            text-align: center;
        }
        .icon-circle {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: #d1fae5;
            color: #059669;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
        }
        .icon-circle svg {
            width: 44px;
            height: 44px;
        }
        h1 {
            font-size: 22px;
            font-weight: 700;
            margin-bottom: 8px;
            color: #065f46;
        }
        .subtitle {
            font-size: 14px;
            color: #047857;
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
            padding: 9px 0;
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
        .badge {
            display: inline-block;
            background: #dbeafe;
            color: #1d4ed8;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .notification-alert {
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            border-radius: 12px;
            padding: 12px;
            font-size: 13px;
            color: #1e40af;
            display: flex;
            align-items: center;
            gap: 10px;
            text-align: left;
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="icon-circle">
            <svg fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path>
            </svg>
        </div>
        <h1>Tiếp Nhận Thành Công!</h1>
        <p class="subtitle">Bệnh nhân đã được check-in vào hàng đợi chờ khám của Bác sĩ.</p>

        <div class="info-box">
            <div class="info-row">
                <span class="info-label">Mã lượt khám:</span>
                <span class="info-val">#{{ $luotKham->ma_luot_kham }}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Bệnh nhân:</span>
                <span class="info-val">{{ $hoTen }}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Thời gian khám:</span>
                <span class="info-val">{{ $thoiGian }}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Trạng thái:</span>
                <span class="badge">Chờ khám</span>
            </div>
        </div>

        <div class="notification-alert">
            <span style="font-size: 20px;">🔔</span>
            <span>Đã gửi thông báo đẩy xác nhận đến điện thoại của bệnh nhân.</span>
        </div>
    </div>
</body>
</html>
