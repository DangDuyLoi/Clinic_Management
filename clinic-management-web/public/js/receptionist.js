/* ============================================================
   RECEPTIONIST — Logic Lễ tân
   ============================================================ */

/* ---------- KHỞI TẠO ---------- */
document.addEventListener('DOMContentLoaded', () => {
  // Bảo vệ trang — chỉ LeTan hoặc QuanTri
  if (!auth.requireAuth(['LeTan', 'QuanTri'])) return;

  // Hiển thị user ở header
  auth.renderUserInfo();

  // Set ngày mặc định = hôm nay
  const dateInput = document.getElementById('filterDate');
  if (dateInput) {
    dateInput.value = todayStr();
    dateInput.addEventListener('change', loadAppointments);
  }

  const statusSelect = document.getElementById('filterStatus');
  if (statusSelect) {
    statusSelect.addEventListener('change', loadAppointments);
  }

  // Load dữ liệu
  loadDashboard();
  loadAppointments();
});

/* ---------- HELPERS ---------- */
function todayStr() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
}

function statusBadgeClass(status) {
  return {
    'ChoXacNhan': 'badge-wait',
    'ChoDenKham': 'badge-wait',
    'ChoKham':    'badge-doing',
    'DangKham':   'badge-doing',
    'HoanThanh':  'badge-done',
    'DaHuy':      'badge-cancel',
  }[status] || 'badge-wait';
}

function statusLabel(status) {
  return {
    'ChoXacNhan': 'Chờ xác nhận',
    'ChoDenKham': 'Chờ đến khám',
    'ChoKham':    'Chờ khám',
    'DangKham':   'Đang khám',
    'HoanThanh':  'Hoàn thành',
    'DaHuy':      'Đã hủy',
  }[status] || status;
}

/* ---------- DASHBOARD STATS ---------- */
async function loadDashboard() {
  const date = document.getElementById('filterDate')?.value || todayStr();

  const res = await api.get(`/lich-kham?ngay=${date}&per_page=100`);

  if (res.status !== 'success') {
    console.error('Load dashboard failed:', res.message);
    return;
  }

  const data = res.data?.data || [];

  const total     = data.length;
  const waiting   = data.filter(l => ['ChoXacNhan', 'ChoDenKham', 'ChoKham'].includes(l.trang_thai)).length;
  const done      = data.filter(l => l.trang_thai === 'HoanThanh').length;
  const cancelled = data.filter(l => l.trang_thai === 'DaHuy').length;

  document.getElementById('totalToday').textContent     = total;
  document.getElementById('waitingCount').textContent   = waiting;
  document.getElementById('doneCount').textContent      = done;
  document.getElementById('cancelledCount').textContent = cancelled;
}

/* ---------- DANH SÁCH LỊCH KHÁM ---------- */
async function loadAppointments() {
  const date   = document.getElementById('filterDate')?.value || todayStr();
  const status = document.getElementById('filterStatus')?.value || '';
  const tbody  = document.getElementById('appointmentTable');

  tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted" style="padding:32px">Đang tải...</td></tr>';

  let endpoint = `/lich-kham?ngay=${date}&per_page=100`;
  if (status) endpoint += `&trang_thai=${status}`;

  const res = await api.get(endpoint);

  if (res.status !== 'success') {
    tbody.innerHTML = `<tr><td colspan="6" class="text-center text-danger" style="padding:32px">
      Lỗi: ${res.message}
    </td></tr>`;
    return;
  }

  const data = res.data?.data || [];

  if (data.length === 0) {
    tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted" style="padding:32px">Không có lịch khám</td></tr>';
    return;
  }

  tbody.innerHTML = data.map((item, i) => {
    const cls = statusBadgeClass(item.trang_thai);
    const canCheckIn = ['ChoXacNhan', 'ChoDenKham'].includes(item.trang_thai);
    const canCancel  = !['HoanThanh', 'DaHuy'].includes(item.trang_thai);

    const hoTenBn = item.benh_nhan?.ho_ten || '—';
    const sdtBn   = item.benh_nhan?.so_dien_thoai || '';
    const hoTenBs = item.bac_si?.ho_ten || '—';
    const gioBd   = item.khung_gio?.gio_bat_dau?.slice(0, 5) || '—';
    const gioKt   = item.khung_gio?.gio_ket_thuc?.slice(0, 5) || '—';

    return `
      <tr>
        <td>${i + 1}</td>
        <td>
          <b>${hoTenBn}</b>
          ${sdtBn ? `<small>${sdtBn}</small>` : ''}
        </td>
        <td>${hoTenBs}</td>
        <td>${gioBd} - ${gioKt}</td>
        <td><span class="badge ${cls}">${statusLabel(item.trang_thai)}</span></td>
        <td>
          ${canCheckIn
            ? `<button class="btn btn-success btn-sm" onclick="checkIn(${item.ma_lich_dat})">✓ Check-in</button>`
            : ''}
          ${canCancel
            ? `<button class="btn btn-danger btn-sm" onclick="cancelAppt(${item.ma_lich_dat})">✕ Hủy</button>`
            : ''}
        </td>
      </tr>
    `;
  }).join('');
}

/* ---------- CHECK-IN ---------- */
async function checkIn(id) {
  if (!confirm('Xác nhận check-in bệnh nhân này?')) return;

  const res = await api.put(`/lich-kham/${id}/checkin`);

  if (res.status === 'success') {
    api.toast('✅ Check-in thành công!', 'success');
    loadAppointments();
    loadDashboard();
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