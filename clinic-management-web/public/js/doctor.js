/* ============================================================
   DOCTOR — Logic Bác sĩ
   ============================================================ */

let currentMaBs = null;

document.addEventListener('DOMContentLoaded', async () => {
  if (!auth.requireAuth(['BacSi', 'QuanTri'])) return;
  auth.renderUserInfo();

  // Chờ lấy được mã bác sĩ trước khi load lịch
  await resolveMaBacSi();

  const dateInput = document.getElementById('filterDate');
  if (dateInput) {
    dateInput.value = todayStr();
    dateInput.addEventListener('change', loadToday);
  }

  if (document.getElementById('patientTable')) {
    loadToday();
  }
});

/* ---------- MAP MA_TK → MA_BS ---------- */
async function resolveMaBacSi() {
  const user = auth.currentUser();
  if (!user) return;

  const res = await api.get('/bac-si');
  if (res.status !== 'success') return;

  // So sánh chính xác ma_tk (dạng số) để tìm ra ma_bs
  const found = res.data.find(bs => Number(bs.ma_tk) === Number(user.ma_tk));
  if (found) {
    currentMaBs = found.ma_bs; 
    console.log('Đã tìm thấy Bác sĩ:', found.ho_ten, '| ma_bs =', currentMaBs);
    const greetingEl = document.getElementById('greetingText');
    if (greetingEl) {
      greetingEl.textContent = `Xin chào, ${found.ho_ten}!`;
    }
  } else {
    console.warn('Không tìm thấy thông tin bác sĩ cho tài khoản này!');
  }
}

function todayStr() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
}

function statusBadgeClass(status) {
  return {
    'cho_thanh_toan': 'badge-warning',
    'da_thanh_toan':  'badge-info',
    'cho_kham':       'badge-doing',
    'dang_kham':      'badge-doing',
    'hoan_tat_hoa_don': 'badge-warning',
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
    'hoan_tat_hoa_don': 'Chờ thu tiền HĐ',
    'hoan_thanh':     'Hoàn thành',
    'huy':            'Đã hủy',
  }[status] || status;
}

/* ---------- LOAD LỊCH HÔM NAY ---------- */
async function loadToday() {
  const tbody = document.getElementById('patientTable');
  if (!tbody) return;
  
  const date = document.getElementById('filterDate')?.value || todayStr();
  tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted" style="padding:32px">Đang tải...</td></tr>';

  let url = `/lich-kham?ngay=${date}&per_page=100`;
  // Nếu không tìm thấy mã bác sĩ, không gọi API để tránh hiển thị sai dữ liệu
  if (!currentMaBs) {
    tbody.innerHTML = '<tr><td colspan="5" class="text-center text-danger">Lỗi: Không xác định được tài khoản Bác sĩ.</td></tr>';
    return;
  }
  url += `&ma_bac_si=${currentMaBs}`;

  const res = await api.get(url);

  if (res.status !== 'success') {
    tbody.innerHTML = `<tr><td colspan="5" class="text-center text-danger">Lỗi: ${res.message}</td></tr>`;
    return;
  }

  const data = res.data?.data || [];

  document.getElementById('totalToday').textContent    = data.length;
  document.getElementById('waitingCount').textContent  = data.filter(l => ['cho_thanh_toan', 'cho_kham'].includes(l.trang_thai)).length;
  document.getElementById('doingCount').textContent    = data.filter(l => l.trang_thai === 'dang_kham').length;
  document.getElementById('doneCount').textContent     = data.filter(l => l.trang_thai === 'hoan_thanh').length;

  if (data.length === 0) {
    tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted" style="padding:32px">Không có bệnh nhân</td></tr>';
    return;
  }

  tbody.innerHTML = data.map((item, i) => {
    const bn = item.ho_so?.benh_nhan || {};
    const cls = statusBadgeClass(item.trang_thai);

    const thoiGian = item.thoi_gian_den_kham ? new Date(item.thoi_gian_den_kham) : null;
    const gioKham = thoiGian ? thoiGian.toLocaleTimeString('vi-VN', {hour: '2-digit', minute:'2-digit'}) : '—';
    
    const gioiTinhText = bn.gioi_tinh === 1 ? 'Nam' : (bn.gioi_tinh === 0 ? 'Nữ' : '');

    const canOpen = ['cho_kham', 'dang_kham'].includes(item.trang_thai);

    return `
      <tr>
        <td>${i+1}</td>
        <td>
          <b>${bn.ho_ten || '—'}</b>
          <small>${bn.ngay_sinh ? 'NS: ' + api.formatDate(bn.ngay_sinh) : ''} ${gioiTinhText ? '· ' + gioiTinhText : ''}</small>
        </td>
        <td><b>${gioKham}</b></td>
        <td><span class="badge ${cls}">${statusLabel(item.trang_thai)}</span></td>
        <td>
          ${canOpen
            ? `<button class="btn btn-primary btn-sm" onclick="openRecord(${item.ma_luot_kham})">📝 Khám</button>`
            : (['cho_thanh_toan', 'hoan_thanh', 'huy'].includes(item.trang_thai) 
                ? `<span class="text-muted" style="font-size:12px">—</span>` 
                : `<span class="text-muted" style="font-size:12px">Chờ check-in</span>`)}
        </td>
      </tr>
    `;
  }).join('');
}

function openRecord(maLuotKham) {
  window.location.href = `patient-record.html?lich=${maLuotKham}`;
}

/* Polling */
let doctorRealtimeInterval = null;
function startDoctorPolling() {
  if (doctorRealtimeInterval) clearInterval(doctorRealtimeInterval);
  doctorRealtimeInterval = setInterval(async () => {
    if (document.hidden) return;
    try {
      if (document.getElementById('patientTable')) await loadToday();
    } catch (e) {}
  }, 20000);
}
document.addEventListener('DOMContentLoaded', () => { setTimeout(startDoctorPolling, 3000); });
document.addEventListener('visibilitychange', () => { if (!document.hidden && document.getElementById('patientTable')) loadToday(); });