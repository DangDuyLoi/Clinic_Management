let invoicesMap = {};

document.addEventListener('DOMContentLoaded', () => {
  if (!auth.requireAuth(['LeTan', 'QuanTri'])) return;
  auth.renderUserInfo();

  const statusSelect = document.getElementById('filterStatus');
  if (statusSelect) statusSelect.addEventListener('change', loadBills);

  loadBills();
  loadStats();
});

/* ---------- LOAD DANH SÁCH ---------- */
async function loadBills() {
  const tbody = document.getElementById('invoiceTable');
  tbody.innerHTML = '<tr><td colspan="9" class="text-center text-muted" style="padding:32px">Đang tải...</td></tr>';

  const filterEl = document.getElementById('filterStatus');
  const statusFilter = filterEl ? filterEl.value : '';
  
  let allBills = [];

  // 1. LẤY LƯỢT KHÁM CHỜ THU 150K (Chưa vào khám)
  if (!statusFilter || statusFilter === 'ChuaThanhToan') {
    const resLK = await api.get(`/lich-kham?trang_thai=cho_thanh_toan&per_page=100`);
    if (resLK.status === 'success') {
      const luotKhams = resLK.data?.data || [];
      allBills = allBills.concat(luotKhams.map(lk => {
        const bn = lk.ho_so?.benh_nhan || {};
        
        const giaKham = 150000;
        let tienBhytTra = 0;
        let tienBenhNhanTra = giaKham;
        let hinhThuc = lk.hinh_thuc_kham || 'DichVu';

        if (hinhThuc === 'BHYT' && bn.ma_bhyt) {
            let mucHuong = 80; 
            if (giaKham < 379500) mucHuong = 100;
            else {
                const kyTu3 = bn.ma_bhyt.substring(2, 3);
                if (kyTu3 === '1' || kyTu3 === '2') mucHuong = 100;
                else if (kyTu3 === '3') mucHuong = 95;
                else if (kyTu3 === '4') mucHuong = 80;
            }
            tienBhytTra = giaKham * (mucHuong / 100);
            tienBenhNhanTra = giaKham - tienBhytTra;
        }

        return {
          key: `luot_kham_${lk.ma_luot_kham}`,
          raw_id: lk.ma_luot_kham,
          loai: 'luot_kham',
          ten_benh_nhan: bn.ho_ten || 'Khách vãng lai',
          so_dien_thoai: bn.so_dien_thoai || '',
          tien_kham: giaKham,
          tien_dich_vu: 0,
          tien_thuoc: 0,
          tong_cong: giaKham,
          tien_bhyt_tra: tienBhytTra,
          tien_benh_nhan_tra: tienBenhNhanTra, 
          hinh_thuc_kham: hinhThuc,
          trang_thai: 'Chờ thanh toán (Phí khám)',
          raw_status: 'cho_thanh_toan'
        };
      }));
    }
  }

  // 2. LẤY HÓA ĐƠN DỊCH VỤ/THUỐC (Không lọc theo ngày để tránh bị ẩn)
  let hdUrl = `/hoa-don?per_page=100`;
  if (statusFilter) hdUrl += `&trang_thai=${statusFilter}`;
  
  const resHD = await api.get(hdUrl);
  if (resHD.status === 'success') {
    const hoaDons = resHD.data?.data || [];
    allBills = allBills.concat(hoaDons.map(hd => {
      const bn = hd.phien_kham?.lich_kham?.ho_so?.benh_nhan || {};
      const tongCong = Number(hd.tong_cong) || 0;
      const bhytTra = Number(hd.tien_bhyt_tra) || 0;
      const benhNhanTra = hd.tien_benh_nhan_tra !== null && hd.tien_benh_nhan_tra !== undefined 
                            ? Number(hd.tien_benh_nhan_tra) 
                            : tongCong; 
      return {
        key: `hoa_don_${hd.ma_hoa_don}`,
        raw_id: hd.ma_hoa_don,
        loai: 'hoa_don',
        ten_benh_nhan: bn.ho_ten || 'Khách vãng lai',
        so_dien_thoai: bn.so_dien_thoai || '',
        tien_kham: 0, // Hóa đơn này không cộng 150k
        tien_dich_vu: hd.tien_dich_vu || 0,
        tien_thuoc: hd.tien_thuoc || 0,
        tong_cong: hd.tong_cong || 0,
        tien_bhyt_tra: hd.tien_bhyt_tra || 0,
        tien_benh_nhan_tra: (hd.tien_benh_nhan_tra !== null && hd.tien_benh_nhan_tra !== undefined) ? Number(hd.tien_benh_nhan_tra) : Number(hd.tong_cong),
        hinh_thuc_kham: hd.tien_bhyt_tra > 0 ? 'BHYT' : 'DichVu',
        trang_thai: hd.trang_thai === 'ChuaThanhToan' ? 'Chờ thanh toán (Hóa đơn)' : 'Đã thanh toán',
        raw_status: hd.trang_thai
      };
    }));
  }

  invoicesMap = {};
  allBills.forEach(hd => { invoicesMap[hd.key] = hd; });

  if (allBills.length === 0) {
    tbody.innerHTML = '<tr><td colspan="9" class="text-center text-muted" style="padding:32px">Không có hóa đơn</td></tr>';
    return;
  }

  tbody.innerHTML = allBills.map(hd => {
    const isPending = hd.raw_status === 'cho_thanh_toan' || hd.raw_status === 'ChuaThanhToan';
    const badgeClass = isPending ? 'badge-wait' : 'badge-done';
    
    const loaiBadge = hd.loai === 'luot_kham' 
      ? '<span class="badge" style="background:#fff3cd;color:#856404;">Phí khám</span>' 
      : '<span class="badge" style="background:#e2e3e5;color:#383d41;">Hóa đơn</span>';

    return `
      <tr data-key="${hd.key}">
        <td><b>#${hd.raw_id}</b><br>${loaiBadge}</td>
        <td>${hd.ten_benh_nhan}<br><small>${hd.so_dien_thoai}</small></td>
        <td>${hd.hinh_thuc_kham === 'BHYT' ? '<span class="badge bg-success text-white">BHYT</span>' : 'Dịch vụ'}</td>
        <td>${api.formatMoney(hd.tien_kham)}</td>
        <td>${api.formatMoney(hd.tien_dich_vu)}</td>
        <td>${api.formatMoney(hd.tien_thuoc)}</td>
        <td><b class="text-primary">${api.formatMoney(hd.tien_benh_nhan_tra)}</b></td>
        <td><span class="badge ${badgeClass}">${hd.trang_thai}</span></td>
        <td>${isPending ? `<button class="btn btn-success btn-sm" onclick="openPayModal('${hd.key}')">💳 Thu tiền</button>` : ''}</td>
      </tr>
    `;
  }).join('');
}

function loadInvoices() { loadBills(); }

async function loadStats() {
  const today = new Date();
  const todayStr = `${today.getFullYear()}-${String(today.getMonth()+1).padStart(2,'0')}-${String(today.getDate()).padStart(2,'0')}`;

  const res = await api.get(`/hoa-don?per_page=200`);
  if (res.status !== 'success') return;
  const data = res.data?.data || [];

  const chuaTT = data.filter(h => h.trang_thai === 'ChuaThanhToan').length;
  const daTT   = data.filter(h => h.trang_thai === 'DaThanhToan').length;
  const doanhThu = data
    .filter(h => h.trang_thai === 'DaThanhToan' && h.ngay_thanh_toan && h.ngay_thanh_toan.startsWith(todayStr))
    .reduce((sum, h) => sum + parseFloat(h.tong_cong || 0), 0);

  document.getElementById('chuaTT').textContent   = chuaTT;
  document.getElementById('daTT').textContent     = daTT;
  document.getElementById('doanhThu').textContent = api.formatMoney(doanhThu);
}

/* ---------- MODAL THANH TOÁN (Giữ nguyên như cũ) ---------- */
function openPayModal(key) {
  const hd = invoicesMap[key];
  if (!hd) return api.toast('Không tìm thấy dữ liệu!', 'error');

  window.currentInvoice = { key: hd.key, loai: hd.loai, id: hd.raw_id, amount: hd.tien_benh_nhan_tra };
  document.getElementById('pay_hoa_don_id').value = hd.key;

  document.getElementById('payInfo').innerHTML = `
    <div class="card" style="background:#fff;margin:0; border:1px solid #dee2e6; box-shadow:none;">
      <div style="padding:10px 12px; background:#f8f9fa; font-weight:bold; border-bottom:1px solid #dee2e6; border-radius: 8px 8px 0 0;">
        Chi tiết ${hd.loai === 'luot_kham' ? 'phí khám' : 'hóa đơn'} #${hd.raw_id}
      </div>
      <div style="padding:12px;">
        ${hd.loai === 'luot_kham' ? `
          <div style="display:flex; justify-content:space-between; margin-bottom:6px; font-size:14px;">
            <span>Tiền khám bệnh:</span> <b>${api.formatMoney(hd.tien_kham)}</b>
          </div>
        ` : `
          <div style="display:flex; justify-content:space-between; margin-bottom:6px; font-size:14px;">
            <span>Tiền dịch vụ:</span> <b>${api.formatMoney(hd.tien_dich_vu)}</b>
          </div>
          <div style="display:flex; justify-content:space-between; margin-bottom:6px; font-size:14px;">
            <span>Tiền thuốc:</span> <b>${api.formatMoney(hd.tien_thuoc)}</b>
          </div>
        `}
        <div style="display:flex; justify-content:space-between; margin-top:8px; padding-top:8px; border-top:1px dashed #ccc; font-size:15px; font-weight:bold;">
          <span>Tổng cộng:</span> <span style="color:#0d6efd">${api.formatMoney(hd.tong_cong)}</span>
        </div>
        ${hd.hinh_thuc_kham === 'BHYT' ? `
          <div style="display:flex; justify-content:space-between; margin-top:6px; font-size:14px; font-weight:bold; color:#2e7d32;">
            <span>BHYT chi trả:</span> <span>- ${api.formatMoney(hd.tien_bhyt_tra)}</span>
          </div>
        ` : ''}
        <div style="display:flex; justify-content:space-between; margin-top:8px; padding-top:8px; border-top:2px solid #dc3545; font-size:16px; font-weight:bold; color:#dc3545;">
          <span>Bệnh nhân thực trả:</span> <span>${api.formatMoney(hd.tien_benh_nhan_tra)}</span>
        </div>
      </div>
    </div>
  `;

  document.getElementById('pay_phuong_thuc').value = 'TienMat';
  document.getElementById('vnpayQRSection').style.display = 'none';
  document.getElementById('momoQRSection').style.display = 'none';
  document.getElementById('payModal').classList.remove('hidden');
}

function closePayModal() {
  document.getElementById('payModal').classList.add('hidden');
  window.currentInvoice = null;
}

async function confirmPay() {
  const key = document.getElementById('pay_hoa_don_id').value;
  const pt = document.getElementById('pay_phuong_thuc').value;
  const hd = invoicesMap[key];
  
  if (!hd) return api.toast('Không tìm thấy dữ liệu', 'error');

  if (pt === 'VNPay') {
    if (hd.loai === 'hoa_don') {
      window.currentInvoice = hd;
      return redirectToVNPay(hd.raw_id);
    } else {
      return api.toast('Lượt khám chưa có hóa đơn, không thể dùng VNPay!', 'warning', 4000);
    }
  }

  const btn = document.getElementById('btnConfirmPay');
  btn.disabled = true;
  btn.innerHTML = '<span class="spinner"></span> Đang xử lý...';

  try {
    let res;
    if (hd.loai === 'hoa_don') {
      res = await api.put(`/hoa-don/${hd.raw_id}/pay`, { phuong_thuc: pt });
    } else {
      res = await api.put(`/lich-kham/${hd.raw_id}/pay`, { phuong_thuc: pt });
    }

    if (res.status === 'success') {
      api.toast('✅ Xác nhận thanh toán thành công!', 'success', 3000);
      closePayModal();
      loadBills(); 
      loadStats();
    } else {
      api.toast(res.message || 'Lỗi thanh toán', 'error');
    }
  } catch (error) {
    api.toast('Không thể kết nối đến server', 'error');
  } finally {
    btn.disabled = false;
    btn.innerHTML = '✓ Xác nhận thanh toán';
  }
}

/* ---------- CHUYỂN HƯỚNG VNPAY SANDBOX THẬT ---------- */
async function redirectToVNPay(hoaDonId) {
  const btn = document.getElementById('btnConfirmPay');
  btn.disabled = true;
  btn.innerHTML = '<span class="spinner"></span> Đang kết nối VNPay...';

  try {
    const res = await api.post(`/vnpay/create-payment/${hoaDonId}`);
    const paymentUrl = res.payment_url || (res.data && res.data.payment_url);

    if (paymentUrl) {
      api.toast('Đang chuyển hướng sang cổng VNPay...', 'info');
      window.location.href = paymentUrl;
    } else {
      api.toast('Không lấy được link thanh toán VNPay', 'error');
    }
  } catch (error) {
    console.error(error);
    api.toast('Lỗi kết nối VNPay', 'error');
  } finally {
    btn.disabled = false;
    btn.innerHTML = '✓ Xác nhận thanh toán';
  }
}
/* ---------- XỬ LÝ ĐỔI PHƯƠNG THỨC THANH TOÁN ---------- */
let qrCountdownTimer = null;
const QR_DURATION = 300; // 5 phút
let qrCountdownValue = QR_DURATION;

function onPaymentMethodChange() {
  const method = document.getElementById('pay_phuong_thuc').value;
  const vnpaySec = document.getElementById('vnpayQRSection');
  const momoSec = document.getElementById('momoQRSection');
  
  // Ẩn cả 2 vùng QR trước
  if (vnpaySec) vnpaySec.style.display = 'none';
  if (momoSec) momoSec.style.display = 'none';
  
  // Dừng đếm ngược nếu có
  stopQRCountdown();

  if (method === 'VNPay') {
    if (vnpaySec) vnpaySec.style.display = 'block';
  } else if (method === 'Momo') {
    if (momoSec) momoSec.style.display = 'block';
    generateMomoQR();      // Tạo QR
    startQRCountdown();    // Bắt đầu đếm ngược
  }
}

// Hàm tạo mã QR và điền thông tin
function generateMomoQR() {
  const inv = window.currentInvoice;
  if (!inv) return;

  const invoiceCode = `HD${String(inv.id).padStart(6, '0')}`;
  const amount = inv.amount || 0;
  const content = `Thanh toan ${invoiceCode}`;
  
  // Điền thông tin vào các thẻ HTML
  const elCode = document.getElementById('momoInvoiceCode');
  const elAmount = document.getElementById('momoAmount');
  const elContent = document.getElementById('momoContent');
  
  if (elCode) elCode.textContent = invoiceCode;
  if (elAmount) elAmount.textContent = api.formatMoney(amount);
  if (elContent) elContent.textContent = content;

  // Tạo dữ liệu QR
  const qrData = JSON.stringify({
    wallet: 'MOMO_SANDBOX',
    invoice: invoiceCode,
    amount: amount,
    content: content
  });

  // Gọi API tạo ảnh QR
  const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(qrData)}`;
  const qrImg = document.getElementById('momoQRImage');
  if (qrImg) {
    qrImg.src = qrUrl;
    qrImg.alt = "QR Code Momo " + invoiceCode;
  }
}

// Hàm đếm ngược thời gian
function startQRCountdown() {
  stopQRCountdown();
  qrCountdownValue = QR_DURATION;
  updateCountdownUI();

  qrCountdownTimer = setInterval(() => {
    qrCountdownValue--;
    updateCountdownUI();

    if (qrCountdownValue <= 0) {
      generateMomoQR(); // Hết 5 phút tự động làm mới QR
      qrCountdownValue = QR_DURATION;
      updateCountdownUI();
    }
  }, 1000);
}

function stopQRCountdown() {
  if (qrCountdownTimer) {
    clearInterval(qrCountdownTimer);
    qrCountdownTimer = null;
  }
}

function updateCountdownUI() {
  const countdownEl = document.getElementById('momoCountdown');
  const progressEl = document.getElementById('momoProgressBar');
  
  if (countdownEl) {
    const min = Math.floor(qrCountdownValue / 60);
    const sec = qrCountdownValue % 60;
    countdownEl.textContent = `${min}:${String(sec).padStart(2, '0')}`;
  }
  
  if (progressEl) {
    const percent = (qrCountdownValue / QR_DURATION) * 100;
    progressEl.style.width = percent + '%';
  }
}