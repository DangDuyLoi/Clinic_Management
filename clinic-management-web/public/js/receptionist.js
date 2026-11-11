/* ============================================================
   RECEPTIONIST — Logic Lễ tân (Đã cập nhật DB mới)
   ============================================================ */

/* ---------- KHỞI TẠO ---------- */
document.addEventListener('DOMContentLoaded', () => {
  if (!auth.requireAuth(['LeTan', 'QuanTri'])) return;
  auth.renderUserInfo();
const user = auth.currentUser();
  const greetingEl = document.getElementById('greetingText');
  if (user && greetingEl) {
    const hoTen = user.ho_ten || user.ten_dang_nhap || 'Lễ tân';
    greetingEl.textContent = `Xin chào, ${hoTen}!`;
  }
  const dateInput = document.getElementById('filterDate');
  if (dateInput) {
    dateInput.value = todayStr();
    dateInput.addEventListener('change', loadAppointments);
  }

  const statusSelect = document.getElementById('filterStatus');
  if (statusSelect) {
    statusSelect.addEventListener('change', loadAppointments);
  }

  loadDashboard();
  loadAppointments();
});

/* ---------- HELPERS ---------- */
function todayStr() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
}

// Ánh xạ trạng thái chuẩn của Mobile (chữ thường)
function statusBadgeClass(status) {
  return {
    'cho_thanh_toan': 'badge-warning',
    'da_thanh_toan':  'badge-info',
    'cho_kham':       'badge-doing',
    'dang_kham':      'badge-doing',
    'hoan_thanh':     'badge-done',
    'huy':            'badge-cancel',
  }[status] || 'badge-wait';
}

function statusLabel(status) {
  return {
    'cho_thanh_toan': 'Chờ thanh toán',
    'da_thanh_toan':  'Đã thanh toán',
    'cho_kham':       'Chờ khám',
    'dang_kham':      'Đang khám',
    'hoan_thanh':     'Hoàn thành',
    'huy':            'Đã hủy',
  }[status] || status;
}

/* ---------- DASHBOARD STATS ---------- */
async function loadDashboard() {
  if (!document.getElementById('totalToday')) return; 
  const date = document.getElementById('filterDate')?.value || todayStr();

  const res = await api.get(`/lich-kham?ngay=${date}&per_page=100`);

  if (res.status !== 'success') {
    console.error('Load dashboard failed:', res.message);
    return;
  }

  const data = res.data?.data || [];

  const total     = data.length;
  const waiting   = data.filter(l => ['cho_thanh_toan', 'cho_kham'].includes(l.trang_thai)).length;
  const done      = data.filter(l => l.trang_thai === 'hoan_thanh').length;
  const cancelled = data.filter(l => l.trang_thai === 'huy').length;

  const totalEl   = document.getElementById('totalToday');
  const waitEl    = document.getElementById('waitingCount');
  const doneEl    = document.getElementById('doneCount');
  const cancelEl  = document.getElementById('cancelledCount');

  if (totalEl)  totalEl.textContent  = total;
  if (waitEl)   waitEl.textContent   = waiting;
  if (doneEl)   doneEl.textContent   = done;
  if (cancelEl) cancelEl.textContent = cancelled;
}

/* ---------- DANH SÁCH LỊCH KHÁM ---------- */
async function loadAppointments() {
  const tbody = document.getElementById('appointmentTable');
  if (!tbody) return;

  const date   = document.getElementById('filterDate')?.value || todayStr();
  const status = document.getElementById('filterStatus')?.value || '';

  tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted" style="padding:32px">Đang tải...</td></tr>';

  let endpoint = `/lich-kham?ngay=${date}&per_page=100`;
  if (status) endpoint += `&trang_thai=${status}`;

  const res = await api.get(endpoint);

  if (res.status !== 'success') {
    tbody.innerHTML = `<tr><td colspan="6" class="text-center text-danger" style="padding:32px">Lỗi: ${res.message}</td></tr>`;
    return;
  }

  const data = res.data?.data || [];

  if (data.length === 0) {
    tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted" style="padding:32px">Không có lịch khám</td></tr>';
    return;
  }

  tbody.innerHTML = data.map((item, i) => {
    const cls = statusBadgeClass(item.trang_thai);
    
    const canCheckIn = ['da_thanh_toan'].includes(item.trang_thai); 
    const canCancel  = !['hoan_thanh', 'huy'].includes(item.trang_thai);
    const canPay     = item.trang_thai === 'hoan_tat_hoa_don';

    const hoTenBn = item.ho_so?.benh_nhan?.ho_ten || '—';
    const sdtBn   = item.ho_so?.benh_nhan?.so_dien_thoai || '';
    const hoTenBs = item.bac_si?.ho_ten || '—';
    
    const thoiGian = item.thoi_gian_den_kham ? new Date(item.thoi_gian_den_kham) : null;
    const gioKham = thoiGian ? thoiGian.toLocaleTimeString('vi-VN', {hour: '2-digit', minute:'2-digit'}) : '—';
    
    const maLuotKham = item.ma_luot_kham;

    return `
      <tr>
        <td>${i + 1}</td>
        <td>
          <b>${hoTenBn}</b>
          ${sdtBn ? `<small>${sdtBn}</small>` : ''}
        </td>
        <td>${hoTenBs}</td>
        <td><b>${gioKham}</b></td>
        <td><span class="badge ${cls}">${statusLabel(item.trang_thai)}</span></td>
        <td>
          ${canPay ? `<button class="btn btn-warning btn-sm" onclick="window.location.href='payments.html'">💳 Thanh toán</button>` : ''}
          ${canCheckIn ? `<button class="btn btn-success btn-sm" onclick="checkIn(${maLuotKham})">✓ Check-in</button>` : ''}
          ${canCancel ? `<button class="btn btn-danger btn-sm" onclick="cancelAppt(${maLuotKham})">✕ Hủy</button>` : ''}
        </td>
      </tr>
    `;
  }).join('');
}

/* ---------- CHECK-IN ---------- */
async function checkIn(id) {
  if (!id) {
    return api.toast('Không tìm thấy mã lượt khám!', 'error');
  }
  const res = await api.put(`/lich-kham/${id}/checkin`);

  if (res.status === 'success') {
    api.toast('✅ Check-in thành công!', 'success');

    if (typeof loadAppointments === 'function') loadAppointments();
    if (typeof loadDashboard === 'function') loadDashboard();
    if (typeof loadPendingList === 'function') loadPendingList();

  } else {
    api.toast(res.message || 'Check-in thất bại', 'error');
  }
}

/* ---------- HỦY LỊCH ---------- */
async function cancelAppt(id) {
  const ly_do = prompt('Lý do hủy lịch:');
  if (!ly_do) return;

  const res = await api.put(`/lich-kham/${id}/cancel`, { ly_do });

  if (res.status === 'success') {
    api.toast('Đã hủy lịch khám', 'success');
    loadAppointments();
    loadDashboard();
  } else {
    api.toast(res.message || 'Hủy lịch thất bại', 'error');
  }
}

/* ============================================================
   REALTIME POLLING — Tự động cập nhật mỗi 15 giây
   ============================================================ */
let realtimeInterval = null;

function startRealtimePolling() {
  if (realtimeInterval) clearInterval(realtimeInterval);

  realtimeInterval = setInterval(async () => {
    if (document.hidden) return;

    try {
      if (document.getElementById('appointmentTable')) {
        await loadDashboard();
        await loadAppointments();
        console.log('🔄 [Dashboard auto-refresh]', new Date().toLocaleTimeString('vi-VN'));
      } else if (document.getElementById('pendingTable')) {
        await loadPendingList();
        console.log('🔄 [Checkin auto-refresh]', new Date().toLocaleTimeString('vi-VN'));
      }
    } catch (e) {
      console.warn('Auto-refresh lỗi:', e);
    }
  }, 15000);

  console.log('✅ Đã bật auto-refresh mỗi 15s');
}

document.addEventListener('DOMContentLoaded', () => {
  setTimeout(startRealtimePolling, 3000);
});

document.addEventListener('visibilitychange', () => {
  if (!document.hidden) {
    console.log('👁 Tab active lại — reload ngay');
    if (document.getElementById('appointmentTable')) {
      loadDashboard();
      loadAppointments();
    } else if (document.getElementById('pendingTable')) {
      loadPendingList();
    }
  }
});

