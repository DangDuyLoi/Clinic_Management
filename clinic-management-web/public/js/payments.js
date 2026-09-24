/* ============================================================
   PAYMENTS — Quản lý thanh toán (Lễ tân)
   ============================================================ */
let qrCountdownTimer = null;     // Interval đếm ngược
const QR_DURATION = 300;         // Thời gian QR sống (giây) — 5 phút
let qrCountdownValue = QR_DURATION;      // Số giây còn lại
let qrRefreshCount = 0;          // Số lần đã reset (để log)
document.addEventListener('DOMContentLoaded', () => {
  if (!auth.requireAuth(['LeTan', 'QuanTri'])) return;
  auth.renderUserInfo();

  const dateInput = document.getElementById('filterDate');
  if (dateInput) {
    dateInput.value = todayStr();
    dateInput.addEventListener('change', loadInvoices);
  }

  document.getElementById('filterStatus').addEventListener('change', loadInvoices);

  loadInvoices();
  loadStats();
});

/* ---------- LOAD DANH SÁCH ---------- */
async function loadInvoices() {
  const status = document.getElementById('filterStatus').value;
  const date   = document.getElementById('filterDate').value;

  let url = '/hoa-don?per_page=100';

  if (status === 'ChuaThanhToan') {
    // Không filter ngày → thấy tất cả hóa đơn chưa thanh toán
    url += `&trang_thai=${status}`;
  } else if (status) {
    url += `&trang_thai=${status}`;
    if (date) url += `&ngay=${date}`;
  } else if (date) {
    url += `&ngay=${date}`;
  }

  const tbody = document.getElementById('invoiceTable');
  tbody.innerHTML = '<tr><td colspan="8" class="text-center text-muted" style="padding:32px">Đang tải...</td></tr>';

  const res = await api.get(url);

  if (res.status !== 'success') {
    tbody.innerHTML = `<tr><td colspan="8" class="text-center text-danger">Lỗi: ${res.message}</td></tr>`;
    return;
  }

  const data = res.data?.data || [];

  if (data.length === 0) {
    tbody.innerHTML = '<tr><td colspan="8" class="text-center text-muted" style="padding:32px">Không có hóa đơn</td></tr>';
    return;
  }

  tbody.innerHTML = data.map(hd => {
    const bn = hd.phien_kham?.lich_kham?.benh_nhan;
    const cls = statusBadgeClassHD(hd.trang_thai);
    const canPay = hd.trang_thai === 'ChuaThanhToan';

    return `
      <tr>
        <td><b>#${hd.ma_hoa_don}</b></td>
        <td>${bn?.ho_ten || '—'}<br><small>${bn?.so_dien_thoai || ''}</small></td>
        <td>${api.formatMoney(hd.tien_kham_benh)}</td>
        <td>${api.formatMoney(hd.tien_dich_vu)}</td>
        <td>${api.formatMoney(hd.tien_thuoc)}</td>
        <td><b class="text-primary">${api.formatMoney(hd.tong_cong)}</b></td>
        <td><span class="badge ${cls}">${statusLabelHD(hd.trang_thai)}</span></td>
        <td>
          ${canPay ? `<button class="btn btn-success btn-sm" onclick="openPayModal(${hd.ma_hoa_don}, ${hd.tong_cong})">💳 Thanh toán</button>` : ''}
          ${canPay ? `<button class="btn btn-danger btn-sm" onclick="cancelInvoice(${hd.ma_hoa_don})">✕</button>` : ''}
        </td>
      </tr>
    `;
  }).join('');
}

function statusBadgeClassHD(s) {
  return {
    'ChuaThanhToan': 'badge-wait',
    'DaThanhToan':   'badge-done',
    'DaHuy':         'badge-cancel',
  }[s] || 'badge-wait';
}

function statusLabelHD(s) {
  return {
    'ChuaThanhToan': 'Chưa thanh toán',
    'DaThanhToan':   'Đã thanh toán',
    'DaHuy':         'Đã hủy',
  }[s] || s;
}

/* ---------- THỐNG KÊ ---------- */
async function loadStats() {
  const today = todayStr();

  const res = await api.get(`/hoa-don?ngay=${today}&per_page=100`);
  if (res.status !== 'success') return;

  const data = res.data?.data || [];

  const chuaTT = data.filter(h => h.trang_thai === 'ChuaThanhToan').length;
  const daTT   = data.filter(h => h.trang_thai === 'DaThanhToan').length;
  const doanhThu = data
    .filter(h => h.trang_thai === 'DaThanhToan')
    .reduce((sum, h) => sum + parseFloat(h.tong_cong || 0), 0);

  document.getElementById('chuaTT').textContent   = chuaTT;
  document.getElementById('daTT').textContent     = daTT;
  document.getElementById('doanhThu').textContent = api.formatMoney(doanhThu);
}

/* ---------- MODAL THANH TOÁN ---------- */
function openPayModal(id, tongCong) {
  // Lưu thông tin vào biến toàn cục
  window.currentInvoice = {
    id: id,
    amount: parseFloat(tongCong) || 0,
  };

  document.getElementById('pay_hoa_don_id').value = id;

  // Hiển thị thông tin hóa đơn
  document.getElementById('payInfo').innerHTML = `
    <div class="card" style="background:#f8f9fa;margin:0">
      <div class="d-flex flex-between align-center">
        <span>Hóa đơn <b>#${id}</b></span>
        <span style="font-size:20px;font-weight:700;color:#0d6efd">
          ${api.formatMoney(tongCong)}
        </span>
      </div>
    </div>
  `;

  // Reset về Tiền mặt
  document.getElementById('pay_phuong_thuc').value = 'TienMat';

  // Ẩn QR
  document.getElementById('vnpayQRSection').style.display = 'none';

  // Hiện modal
  document.getElementById('payModal').classList.remove('hidden');
}

function closePayModal() {
  // ⭐ Dừng timer QR
  stopQRCountdown();
  qrRefreshCount = 0;

  document.getElementById('payModal').classList.add('hidden');
  document.getElementById('vnpayQRSection').style.display = 'none';
  document.getElementById('vnpayQRImage').src = '';
  document.getElementById('pay_phuong_thuc').value = 'TienMat';
  window.currentInvoice = null;
}

async function confirmPay() {
  const id = document.getElementById('pay_hoa_don_id').value;
  const pt = document.getElementById('pay_phuong_thuc').value;
  stopQRCountdown();
  // Nếu VNPay → yêu cầu xác nhận thêm (giả lập khách đã quét QR)
  if (pt === 'VNPay') {
    const confirmed = confirm(
      '💳 Xác nhận khách đã thanh toán qua VNPay?\n\n' +
      'Sau khi xác nhận, hệ thống sẽ đánh dấu hóa đơn là ĐÃ THANH TOÁN.'
    );
    if (!confirmed) return;
  }

  const btn = document.getElementById('btnConfirmPay');
  btn.disabled = true;
  btn.innerHTML = '<span class="spinner"></span> Đang xử lý...';

  const res = await api.put(`/hoa-don/${id}/pay`, { phuong_thuc: pt });

  if (res.status === 'success') {
    let msg = '✅ Xác nhận thanh toán thành công!';
    if (pt === 'VNPay') {
      msg = '✅ Thanh toán VNPay thành công! Hóa đơn đã được đánh dấu hoàn thành.';
    }
    api.toast(msg, 'success', 4000);

    closePayModal();
    loadInvoices();
    loadStats();
  } else {
    api.toast(res.message || 'Lỗi thanh toán', 'error');
  }

  btn.disabled = false;
  btn.innerHTML = '✓ Xác nhận thanh toán';
}

/* ---------- HỦY HÓA ĐƠN ---------- */
async function cancelInvoice(id) {
  if (!confirm('Bạn chắc chắn muốn hủy hóa đơn này?')) return;

  const res = await api.put(`/hoa-don/${id}/cancel`);
  if (res.status === 'success') {
    api.toast('Đã hủy hóa đơn', 'success');
    loadInvoices();
    loadStats();
  } else {
    api.toast(res.message || 'Không thể hủy', 'error');
  }
}

function todayStr() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
}
/* ============================================================
   XỬ LÝ ĐỔI PHƯƠNG THỨC THANH TOÁN
   ============================================================ */
function onPaymentMethodChange() {
  const method = document.getElementById('pay_phuong_thuc').value;
  const qrSection = document.getElementById('vnpayQRSection');

  if (method === 'VNPay') {
    showVNPayQR();                  // Tạo QR + bắt đầu timer
    qrSection.style.display = 'block';
  } else {
    // ⭐ Dừng timer khi đổi sang phương thức khác
    stopQRCountdown();
    qrSection.style.display = 'none';
    qrRefreshCount = 0;
  }
}

/* ============================================================
   HIỂN THỊ QR VNPAY (GIẢ LẬP)
   ============================================================ */
/* ============================================================
   HIỂN THỊ QR VNPAY — CÓ AUTO RESET MỖI 60 GIÂY
   ============================================================ */
function showVNPayQR() {
  refreshVNPayQR(false);          // Tạo QR lần đầu (không log)
  startQRCountdown();             // Bắt đầu đếm ngược
}

/* Tạo QR mới (gọi mỗi khi hết countdown hoặc bấm nút) */
function refreshVNPayQR(isManual = false) {
  const inv = window.currentInvoice || {};
  if (!inv.id) return;

  qrRefreshCount++;

  const invoiceCode = `HD${String(inv.id).padStart(6, '0')}`;
  const amount = inv.amount || 0;
  const content = `Thanh toan ${invoiceCode}`;

  // ⭐ Tạo nonce ngẫu nhiên + timestamp mới mỗi lần reset
  const nonce = Math.random().toString(36).substring(2, 12).toUpperCase();
  const timestamp = Date.now();

  // Cập nhật thông tin hiển thị
  document.getElementById('vnpayInvoiceCode').textContent = invoiceCode;
  document.getElementById('vnpayAmount').textContent = api.formatMoney(amount);
  document.getElementById('vnpayContent').textContent = content;

  // Dữ liệu QR — có nonce + timestamp để mỗi lần khác nhau
  const qrData = JSON.stringify({
    bank: 'VNPAY_SANDBOX',
    invoice: invoiceCode,
    amount: amount,
    content: content,
    nonce: nonce,
    timestamp: timestamp,
    expiry: timestamp + (QR_DURATION * 1000),     // Hết hạn sau 60s
  });

  // URL QR — thêm &_t=timestamp để bypass cache browser
  const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(qrData)}&_t=${timestamp}`;

  const qrImg = document.getElementById('vnpayQRImage');

  // Hiệu ứng loading nhẹ trước khi đổi ảnh
  qrImg.style.opacity = '0.5';
  qrImg.onload = () => { qrImg.style.opacity = '1'; };
  qrImg.src = qrUrl;
  qrImg.classList.remove('qr-about-to-reset');
  // Thêm hiệu ứng xuất hiện
  qrImg.classList.add('qr-just-reset');
  setTimeout(() => qrImg.classList.remove('qr-just-reset'), 400);
  qrImg.alt = `QR thanh toán ${invoiceCode} - ${nonce}`;

  // Log để chứng minh QR đã đổi
  const method = isManual ? 'thủ công' : 'tự động';
  console.log(
    `🔄 [${method}] Đã tạo QR lần ${qrRefreshCount}\n` +
    `   Hóa đơn: ${invoiceCode}\n` +
    `   Số tiền: ${api.formatMoney(amount)}\n` +
    `   Nonce: ${nonce}\n` +
    `   Timestamp: ${new Date(timestamp).toLocaleTimeString('vi-VN')}`
  );
}

/* ============================================================
   COUNTDOWN TIMER — ĐẾM NGƯỢC 60 GIÂY
   ============================================================ */
function startQRCountdown() {
  // Xóa timer cũ nếu có
  stopQRCountdown();

  qrCountdownValue = QR_DURATION;
  updateQRCountdownUI();

  qrCountdownTimer = setInterval(() => {
    qrCountdownValue--;
    updateQRCountdownUI();

    if (qrCountdownValue <= 0) {
      refreshVNPayQR(false);
      qrCountdownValue = QR_DURATION;
      updateQRCountdownUI();
    }
  }, 1000);
}

/* Dừng timer */
function stopQRCountdown() {
  if (qrCountdownTimer) {
    clearInterval(qrCountdownTimer);
    qrCountdownTimer = null;
  }
}

/* Cập nhật UI countdown */
function updateQRCountdownUI() {
  const countdownEl = document.getElementById('qrCountdown');
  const progressEl = document.getElementById('qrProgressBar');
  const qrImg = document.getElementById('vnpayQRImage');

  // ⭐ Hiển thị dạng MM:SS khi > 60 giây
  if (countdownEl) {
    if (qrCountdownValue >= 60) {
      const min = Math.floor(qrCountdownValue / 60);
      const sec = qrCountdownValue % 60;
      countdownEl.textContent = `${min}:${String(sec).padStart(2, '0')}`;
    } else {
      countdownEl.textContent = qrCountdownValue;
    }

    // Đổi màu khi gần hết (ngưỡng dựa trên tổng thời gian)
    const warningThreshold = Math.floor(QR_DURATION * 0.17);   // ~17% cuối
    const cautionThreshold = Math.floor(QR_DURATION * 0.33);   // ~33% cuối

    if (qrCountdownValue <= warningThreshold) {
      countdownEl.style.color = '#dc3545';
      countdownEl.style.fontWeight = '700';
      qrImg.classList.add('qr-about-to-reset');
    } else if (qrCountdownValue <= cautionThreshold) {
      countdownEl.style.color = '#fd7e14';
      qrImg.classList.remove('qr-about-to-reset');
    } else {
      countdownEl.style.color = '#dc3545';
      countdownEl.style.fontWeight = '600';
      qrImg.classList.remove('qr-about-to-reset');
    }
  }

  // Progress bar — chia theo QR_DURATION thay vì 60
  if (progressEl) {
    const percent = (qrCountdownValue / QR_DURATION) * 100;
    progressEl.style.width = percent + '%';

    const warningThreshold = Math.floor(QR_DURATION * 0.17);
    const cautionThreshold = Math.floor(QR_DURATION * 0.33);

    if (qrCountdownValue <= warningThreshold) {
      progressEl.style.background = '#dc3545';
    } else if (qrCountdownValue <= cautionThreshold) {
      progressEl.style.background = '#fd7e14';
    } else {
      progressEl.style.background = '#0d6efd';
    }
  }
}