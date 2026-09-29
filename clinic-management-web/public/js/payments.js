/* ============================================================
   PAYMENTS — Quản lý thanh toán (Lễ tân)
   ============================================================ */
let qrCountdownTimer = null;     // Interval đếm ngược
const QR_DURATION = 300;         // Thời gian QR sống (giây) — 5 phút
let qrCountdownValue = QR_DURATION;      // Số giây còn lại
let qrRefreshCount = 0;          // Số lần đã reset (để log)
let currentPaymentMethod = null;

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

  // Ẩn cả 2 QR
  const vnpaySec = document.getElementById('vnpayQRSection');
  const momoSec = document.getElementById('momoQRSection');
  if (vnpaySec) vnpaySec.style.display = 'none';
  if (momoSec) momoSec.style.display = 'none';

  // Reset biến
  currentPaymentMethod = null;
  qrRefreshCount = 0;

  // Hiện modal
  document.getElementById('payModal').classList.remove('hidden');
}

function closePayModal() {
  // ⭐ Dừng timer QR
  stopQRCountdown();
  qrRefreshCount = 0;
  currentPaymentMethod = null;

  document.getElementById('payModal').classList.add('hidden');

// Reset VNPay QR
  const vnpaySec = document.getElementById('vnpayQRSection');
  const vnpayImg = document.getElementById('vnpayQRImage');
  if (vnpaySec) vnpaySec.style.display = 'none';
  if (vnpayImg) vnpayImg.src = '';

  // Reset Momo QR
  const momoSec = document.getElementById('momoQRSection');
  const momoImg = document.getElementById('momoQRImage');
  if (momoSec) momoSec.style.display = 'none';
  if (momoImg) momoImg.src = '';

  document.getElementById('pay_phuong_thuc').value = 'TienMat';

  window.currentInvoice = null;
}

async function confirmPay() {
  const id = document.getElementById('pay_hoa_don_id').value;
  const pt = document.getElementById('pay_phuong_thuc').value;
  stopQRCountdown();
  // Nếu VNPay → yêu cầu xác nhận thêm (giả lập khách đã quét QR)
  if (pt === 'VNPay'|| pt === 'Momo') {
    const walletName = pt === 'VNPay' ? 'VNPay' : 'Momo';
    const emoji = pt === 'VNPay' ? '💳' : '📱';
    const confirmed = confirm(
      '${emoji} Xác nhận khách đã thanh toán qua ${walletName}?\n\n' +
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
    } else if (pt === 'Momo') {
      msg = '✅ Thanh toán Momo thành công! Hóa đơn đã được đánh dấu hoàn thành.';
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
   QR ĐA PHƯƠNG THỨC — VNPAY + MOMO
   ============================================================ */

/* ---------- XỬ LÝ ĐỔI PHƯƠNG THỨC ---------- */
function onPaymentMethodChange() {
  const method = document.getElementById('pay_phuong_thuc').value;

  // Ẩn cả 2 QR trước
  document.getElementById('vnpayQRSection').style.display = 'none';
  document.getElementById('momoQRSection').style.display = 'none';

  // Dừng timer nếu có
  stopQRCountdown();

  if (method === 'VNPay' || method === 'Momo') {
    // Lưu method hiện tại
    currentPaymentMethod = method;

    // Hiện QR tương ứng
    if (method === 'VNPay') {
      document.getElementById('vnpayQRSection').style.display = 'block';
    } else {
      document.getElementById('momoQRSection').style.display = 'block';
    }

    // Tạo QR + bắt đầu countdown
    refreshPaymentQR(false);
    startQRCountdown();
  } else {
    // Tiền mặt / Chuyển khoản → không cần QR
    currentPaymentMethod = null;
  }
}

/* ---------- TẠO / LÀM MỚI QR ---------- */
function refreshPaymentQR(isManual = false) {
  if (!currentPaymentMethod) return;

  const inv = window.currentInvoice || {};
  if (!inv.id) return;

  qrRefreshCount++;

  const invoiceCode = `HD${String(inv.id).padStart(6, '0')}`;
  const amount = inv.amount || 0;
  const content = `Thanh toan ${invoiceCode}`;

  // Tạo nonce + timestamp mỗi lần reset
  const nonce = Math.random().toString(36).substring(2, 12).toUpperCase();
  const timestamp = Date.now();

  // Cấu hình theo phương thức
  const config = {
    VNPay: {
      wallet: 'VNPAY_SANDBOX',
      invoiceCodeEl: 'vnpayInvoiceCode',
      amountEl: 'vnpayAmount',
      contentEl: 'vnpayContent',
      qrImgEl: 'vnpayQRImage',
      logoEmoji: '💳'
    },
    Momo: {
      wallet: 'MOMO_SANDBOX',
      invoiceCodeEl: 'momoInvoiceCode',
      amountEl: 'momoAmount',
      contentEl: 'momoContent',
      qrImgEl: 'momoQRImage',
      logoEmoji: '📱'
    }
  }[currentPaymentMethod];

  if (!config) return;

  // Cập nhật thông tin hiển thị
  document.getElementById(config.invoiceCodeEl).textContent = invoiceCode;
  document.getElementById(config.amountEl).textContent = api.formatMoney(amount);
  document.getElementById(config.contentEl).textContent = content;

  // Dữ liệu QR
  const qrData = JSON.stringify({
    wallet: config.wallet,
    invoice: invoiceCode,
    amount: amount,
    content: content,
    nonce: nonce,
    timestamp: timestamp,
    expiry: timestamp + (QR_DURATION * 1000),
  });

  const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(qrData)}&_t=${timestamp}`;

  const qrImg = document.getElementById(config.qrImgEl);
  qrImg.style.opacity = '0.5';
  qrImg.onload = () => { qrImg.style.opacity = '1'; };
  qrImg.src = qrUrl;
  qrImg.alt = `QR ${currentPaymentMethod} - ${invoiceCode} - ${nonce}`;

  // Xóa pulse cũ, thêm hiệu ứng reset
  qrImg.classList.remove('qr-about-to-reset');
  qrImg.classList.add('qr-just-reset');
  setTimeout(() => qrImg.classList.remove('qr-just-reset'), 400);

  // Log
  const method = isManual ? 'thủ công' : 'tự động';
  console.log(
    `🔄 [${currentPaymentMethod} - ${method}] QR #${qrRefreshCount}\n` +
    `   Hóa đơn: ${invoiceCode}\n` +
    `   Số tiền: ${api.formatMoney(amount)}\n` +
    `   Nonce: ${nonce}\n` +
    `   Timestamp: ${new Date(timestamp).toLocaleTimeString('vi-VN')}`
  );
}

/* ---------- COUNTDOWN TIMER (DÙNG CHUNG) ---------- */
function startQRCountdown() {
  stopQRCountdown();

  qrCountdownValue = QR_DURATION;
  updateQRCountdownUI();

  qrCountdownTimer = setInterval(() => {
    qrCountdownValue--;
    updateQRCountdownUI();

    if (qrCountdownValue <= 0) {
      refreshPaymentQR(false);
      qrCountdownValue = QR_DURATION;
      updateQRCountdownUI();
    }
  }, 1000);
}

function stopQRCountdown() {
  if (qrCountdownTimer) {
    clearInterval(qrCountdownTimer);
    qrCountdownTimer = null;
  }
}

/* ---------- CẬP NHẬT UI COUNTDOWN ---------- */
function updateQRCountdownUI() {
  if (!currentPaymentMethod) return;

  // Chọn element theo phương thức
  const prefix = currentPaymentMethod === 'VNPay' ? 'vnpay' : 'momo';
  const countdownEl = document.getElementById(`${prefix}Countdown`);
  const progressEl = document.getElementById(`${prefix}ProgressBar`);
  const qrImgEl = document.getElementById(`${prefix}QRImage`);

  if (!countdownEl) return;

  // Format MM:SS
  if (qrCountdownValue >= 60) {
    const min = Math.floor(qrCountdownValue / 60);
    const sec = qrCountdownValue % 60;
    countdownEl.textContent = `${min}:${String(sec).padStart(2, '0')}`;
  } else {
    countdownEl.textContent = qrCountdownValue;
  }

  // Ngưỡng cảnh báo
  const warningThreshold = Math.floor(QR_DURATION * 0.17);
  const cautionThreshold = Math.floor(QR_DURATION * 0.33);

  // Đổi màu số đếm
  if (qrCountdownValue <= warningThreshold) {
    countdownEl.style.color = '#dc3545';
    countdownEl.style.fontWeight = '700';
    qrImgEl?.classList.add('qr-about-to-reset');
  } else if (qrCountdownValue <= cautionThreshold) {
    countdownEl.style.color = '#fd7e14';
    qrImgEl?.classList.remove('qr-about-to-reset');
  } else {
    countdownEl.style.color = currentPaymentMethod === 'VNPay' ? '#0d6efd' : '#A50064';
    countdownEl.style.fontWeight = '600';
    qrImgEl?.classList.remove('qr-about-to-reset');
  }

  // Progress bar
  if (progressEl) {
    const percent = (qrCountdownValue / QR_DURATION) * 100;
    progressEl.style.width = percent + '%';

    if (qrCountdownValue <= warningThreshold) {
      progressEl.style.background = '#dc3545';
    } else if (qrCountdownValue <= cautionThreshold) {
      progressEl.style.background = '#fd7e14';
    } else {
      progressEl.style.background = currentPaymentMethod === 'VNPay' ? '#0d6efd' : '#A50064';
    }
  }
}