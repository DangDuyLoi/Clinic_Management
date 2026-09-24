/* ============================================================
   DOCTOR — Logic Bác sĩ
   ============================================================ */

let currentMaBs = null;

document.addEventListener('DOMContentLoaded', async () => {
  if (!auth.requireAuth(['BacSi', 'QuanTri'])) return;
  auth.renderUserInfo();

  // Lấy mã bác sĩ từ thông tin user
  // (backend trả về user.ma_tk; cần map sang ma_bs)
  await resolveMaBacSi();

  const dateInput = document.getElementById('filterDate');
  if (dateInput) {
    dateInput.value = todayStr();
    dateInput.addEventListener('change', loadToday);
  }

  loadToday();
});

/* ---------- MAP MA_TK → MA_BS ---------- */
async function resolveMaBacSi() {
  const user = auth.currentUser();
  if (!user) return;

  // Gọi /bac-si để lấy danh sách và tìm bác sĩ khớp ma_tk
  const res = await api.get('/bac-si');
  if (res.status !== 'success') return;

  const found = res.data.find(bs => bs.ma_tk === user.ma_tk);
  if (found) {
    currentMaBs = found.ma_bs;
    console.log('Bác sĩ:', found.ho_ten, '| ma_bs =', currentMaBs);
  }
}

function todayStr() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
}

function statusBadgeClass(status) {
  return {
    'ChoXacNhan': 'badge-wait',
    'ChoKham':    'badge-doing',
    'DangKham':   'badge-doing',
    'ChoThanhToan': 'badge-info',
    'HoanThanh':  'badge-done',
    'DaHuy':      'badge-cancel',
  }[status] || 'badge-wait';
}

function statusLabel(status) {
  return {
    'ChoXacNhan': 'Chờ xác nhận',
    'ChoKham':    'Chờ khám',
    'DangKham':   'Đang khám',
    'ChoThanhToan': 'Chờ thanh toán',
    'HoanThanh':  'Hoàn thành',
    'DaHuy':      'Đã hủy',
  }[status] || status;
}

/* ---------- LOAD LỊCH HÔM NAY ---------- */
async function loadToday() {
  const date = document.getElementById('filterDate')?.value || todayStr();
  const tbody = document.getElementById('patientTable');
  tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted" style="padding:32px">Đang tải...</td></tr>';

  let url = `/lich-kham?ngay=${date}&per_page=100`;
  if (currentMaBs) url += `&ma_bs=${currentMaBs}`;

  const res = await api.get(url);

  if (res.status !== 'success') {
    tbody.innerHTML = `<tr><td colspan="5" class="text-center text-danger">Lỗi: ${res.message}</td></tr>`;
    return;
  }

  const data = res.data?.data || [];

  // Cập nhật thống kê
  document.getElementById('totalToday').textContent    = data.length;
  document.getElementById('waitingCount').textContent  = data.filter(l => ['ChoXacNhan', 'ChoKham'].includes(l.trang_thai)).length;
  document.getElementById('doingCount').textContent    = data.filter(l => l.trang_thai === 'DangKham').length;
  document.getElementById('doneCount').textContent     = data.filter(l => l.trang_thai === 'HoanThanh').length;

  if (data.length === 0) {
    tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted" style="padding:32px">Không có bệnh nhân</td></tr>';
    return;
  }

  tbody.innerHTML = data.map((item, i) => {
    const bn = item.benh_nhan;
    const gio = item.khung_gio;
    const cls = statusBadgeClass(item.trang_thai);

    // Bác sĩ chỉ mở phiên khám khi bệnh nhân đã check-in (trạng thái ChoKham hoặc DangKham)
    const canOpen = ['ChoKham', 'DangKham'].includes(item.trang_thai);

    return `
      <tr>
        <td>${i+1}</td>
        <td>
          <b>${bn?.ho_ten || '—'}</b>
          <small>${bn?.ngay_sinh ? 'NS: ' + api.formatDate(bn.ngay_sinh) : ''} · ${bn?.gioi_tinh || ''}</small>
        </td>
        <td><b>${gio?.gio_bat_dau?.slice(0,5) || '—'} - ${gio?.gio_ket_thuc?.slice(0,5) || '—'}</b></td>
        <td><span class="badge ${cls}">${statusLabel(item.trang_thai)}</span></td>
        <td>
          ${canOpen
            ? `<button class="btn btn-primary btn-sm" onclick="openRecord(${item.ma_lich_dat})">📝 Khám</button>`
            : `<span class="text-muted" style="font-size:12px">Chờ check-in</span>`}
        </td>
      </tr>
    `;
  }).join('');
}

function openRecord(maLich) {
  window.location.href = `patient-record.html?lich=${maLich}`;
}