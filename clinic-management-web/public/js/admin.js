/* ============================================================
   ADMIN — Logic Quản trị viên
   ============================================================ */

document.addEventListener('DOMContentLoaded', () => {
  if (!auth.requireAuth(['QuanTri'])) return;
  auth.renderUserInfo();

  // Chỉ chạy loadDashboard nếu có element tương ứng
  if (document.getElementById('totalUsers')) {
    loadDashboard();
  }
});

/* ---------- DASHBOARD ---------- */
async function loadDashboard() {
  const res = await api.get('/dashboard/admin');

  if (res.status !== 'success') {
    api.toast('Lỗi tải dashboard: ' + res.message, 'error');
    return;
  }

  const d = res.data;

  // Tổng quan
  document.getElementById('totalUsers').textContent    = d.total.users;
  document.getElementById('totalDoctors').textContent  = d.total.doctors;
  document.getElementById('totalPatients').textContent = d.total.patients;
  document.getElementById('totalSpecs').textContent    = d.total.specialties;

  // Hôm nay
  document.getElementById('apptToday').textContent    = d.today.appointments;
  document.getElementById('apptPending').textContent  = d.today.pending;
  document.getElementById('apptDone').textContent     = d.today.done;
  document.getElementById('revenueToday').textContent = api.formatMoney(d.today.revenue);

  // Top bác sĩ
  const tdEl = document.getElementById('topDoctors');
  if (d.top_doctors?.length) {
    tdEl.innerHTML = d.top_doctors.map((bs, i) => `
      <tr>
        <td><b>#${i+1}</b></td>
        <td>${bs.ho_ten}</td>
        <td><span class="badge badge-info">${bs.lich_kham_count}</span></td>
      </tr>
    `).join('');
  } else {
    tdEl.innerHTML = '<tr><td colspan="3" class="text-center text-muted">Chưa có dữ liệu</td></tr>';
  }

  // Chuyên khoa
  const tsEl = document.getElementById('topSpecialties');
  if (d.top_specialties?.length) {
    tsEl.innerHTML = d.top_specialties.map(ck => `
      <tr>
        <td>${ck.ten_chuyen_khoa}</td>
        <td><span class="badge badge-info">${ck.bac_si_count}</span></td>
      </tr>
    `).join('');
  } else {
    tsEl.innerHTML = '<tr><td colspan="2" class="text-center text-muted">Chưa có dữ liệu</td></tr>';
  }

  // Doanh thu 7 ngày
  const rvEl = document.getElementById('revenueTable');
  if (d.revenue_7_days?.length) {
    rvEl.innerHTML = d.revenue_7_days.map(r => `
      <tr>
        <td>${api.formatDate(r.ngay)}</td>
        <td>${r.so_hoa_don}</td>
        <td><b class="text-success">${api.formatMoney(r.doanh_thu)}</b></td>
      </tr>
    `).join('');
  } else {
    rvEl.innerHTML = '<tr><td colspan="3" class="text-center text-muted">Chưa có doanh thu</td></tr>';
  }
}