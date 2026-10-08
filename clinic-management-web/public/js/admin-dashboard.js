/* ============================================================
   ADMIN DASHBOARD — Biểu đồ & thống kê
   ============================================================ */

let revenueChart = null;
let doctorChart = null;
let specialtyChart = null;

let currentRange = { from: null, to: null };

/* ============================================================
   INIT
   ============================================================ */
document.addEventListener('DOMContentLoaded', () => {
  if (!auth.requireAuth(['QuanTri'])) return;
  auth.renderUserInfo();

  // Mặc định 30 ngày
  applyRange();
});

/* ============================================================
   XỬ LÝ CHỌN KHOẢNG THỜI GIAN
   ============================================================ */
function applyRange() {
  const val = document.getElementById('filterRange').value;

  if (val === 'custom') {
    document.getElementById('customRange').style.display = 'flex';
    return;
  }

  document.getElementById('customRange').style.display = 'none';

  const days = parseInt(val);
  const to = new Date();
  const from = new Date();
  from.setDate(from.getDate() - days + 1);

  currentRange.from = from.toISOString().slice(0, 10);
  currentRange.to   = to.toISOString().slice(0, 10);

  loadAll();
}

/* ============================================================
   LOAD TẤT CẢ
   ============================================================ */
async function loadAll() {
  const val = document.getElementById('filterRange').value;

  if (val === 'custom') {
    const fromInput = document.getElementById('fromDate').value;
    const toInput = document.getElementById('toDate').value;

    if (!fromInput || !toInput) {
      api.toast('Vui lòng chọn cả 2 ngày', 'error');
      return;
    }

    currentRange.from = fromInput;
    currentRange.to   = toInput;
  }

  console.log('📊 Loading dashboard:', currentRange);

  // Gọi song song
  await Promise.all([
    loadOverview(),
    loadRevenue(),
    loadDoctorPerformance(),
    loadSpecialtyStats()
  ]);
}

/* ============================================================
   1. OVERVIEW — 4 thẻ tổng quan
   ============================================================ */
async function loadOverview() {
  const res = await api.get(`/dashboard/overview?from=${currentRange.from}&to=${currentRange.to}`);

  if (res.status !== 'success') {
    console.error('Lỗi overview:', res.message);
    return;
  }

  const d = res.data;

  document.getElementById('tongLich').textContent = d.tong_lich || 0;
  document.getElementById('tyLeHoanThanh').textContent = (d.ty_le_hoan_thanh || 0) + '%';

  // Tổng doanh thu + hóa đơn sẽ được tính từ loadRevenue
}

/* ============================================================
   2. REVENUE — Biểu đồ doanh thu
   ============================================================ */
async function loadRevenue() {
  const groupBy = document.getElementById('revenueGroupBy').value;
  const res = await api.get(`/dashboard/revenue?from=${currentRange.from}&to=${currentRange.to}&group_by=${groupBy}`);

  if (res.status !== 'success') {
    console.error('Lỗi revenue:', res.message);
    return;
  }

  const d = res.data;

  // Cập nhật 2 thẻ đầu
  document.getElementById('tongDoanhThu').textContent = api.formatMoney(d.tong_doanh_thu);
  document.getElementById('tongHoaDon').textContent = d.tong_hoa_don;

  // Chuẩn bị data cho biểu đồ
  const labels = d.chi_tiet.map(x => {
    if (groupBy === 'month') {
      const [y, m] = x.thoi_gian.split('-');
      return `T${m}/${y}`;
    }
    return new Date(x.thoi_gian).toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit' });
  });

  const doanhThu = d.chi_tiet.map(x => parseFloat(x.doanh_thu || 0));
  const tienKham = d.chi_tiet.map(x => parseFloat(x.tien_kham || 0));
  const tienDichVu = d.chi_tiet.map(x => parseFloat(x.tien_dich_vu || 0));
  const tienThuoc = d.chi_tiet.map(x => parseFloat(x.tien_thuoc || 0));

  // Vẽ biểu đồ
  const ctx = document.getElementById('revenueChart');

  if (revenueChart) revenueChart.destroy();

  revenueChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [
        {
          label: 'Tiền khám',
          data: tienKham,
          backgroundColor: '#0d6efd',
          stack: 'tong',
        },
        {
          label: 'Tiền dịch vụ',
          data: tienDichVu,
          backgroundColor: '#198754',
          stack: 'tong',
        },
        {
          label: 'Tiền thuốc',
          data: tienThuoc,
          backgroundColor: '#ffc107',
          stack: 'tong',
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { position: 'top' },
        tooltip: {
          callbacks: {
            label: (ctx) => `${ctx.dataset.label}: ${api.formatMoney(ctx.raw)}`,
            footer: (items) => {
              const sum = items.reduce((s, i) => s + i.raw, 0);
              return 'Tổng: ' + api.formatMoney(sum);
            },
          },
        },
      },
      scales: {
        x: { stacked: true },
        y: {
          stacked: true,
          beginAtZero: true,
          ticks: {
            callback: (v) => (v / 1000).toLocaleString('vi-VN') + 'k',
          },
        },
      },
    },
  });

  console.log(`✅ Revenue chart: ${d.chi_tiet.length} điểm dữ liệu`);
}

/* ============================================================
   3. DOCTOR PERFORMANCE — Biểu đồ cột ngang
   ============================================================ */
async function loadDoctorPerformance() {
  const res = await api.get(`/dashboard/doctor-performance?from=${currentRange.from}&to=${currentRange.to}&limit=8`);

  if (res.status !== 'success') {
    console.error('Lỗi doctor performance:', res.message);
    return;
  }

  const d = res.data || [];

  // Biểu đồ
  const labels = d.map(x => x.ho_ten);
  const soLich = d.map(x => x.so_lich_hoan_thanh);

  const ctx = document.getElementById('doctorChart');

  if (doctorChart) doctorChart.destroy();

  doctorChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: 'Lịch hoàn thành',
        data: soLich,
        backgroundColor: '#0d6efd',
        borderRadius: 6,
      }],
    },
    options: {
      indexAxis: 'y',
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false },
      },
      scales: {
        x: { beginAtZero: true },
      },
    },
  });

  // Bảng xếp hạng
  renderRankingTable(d);
}

function renderRankingTable(list) {
  const tbody = document.getElementById('rankingTable');

  if (!list.length) {
    tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted" style="padding:20px">Chưa có dữ liệu</td></tr>';
    return;
  }

  tbody.innerHTML = list.map((bs, idx) => {
    const medal = idx === 0 ? '🥇' : idx === 1 ? '🥈' : idx === 2 ? '🥉' : `#${idx + 1}`;
    return `
      <tr>
        <td><b>${medal}</b></td>
        <td><b>${bs.ho_ten}</b></td>
        <td>${bs.chuyen_khoa?.ten_chuyen_khoa || '—'}</td>
        <td><span class="badge badge-done">${bs.so_lich_hoan_thanh}</span></td>
        <td>${bs.so_benh_nhan}</td>
        <td><b class="text-success">${api.formatMoney(bs.doanh_thu)}</b></td>
      </tr>
    `;
  }).join('');
}

/* ============================================================
   4. SPECIALTY STATS — Biểu đồ tròn
   ============================================================ */
async function loadSpecialtyStats() {
  const res = await api.get(`/dashboard/specialty-stats?from=${currentRange.from}&to=${currentRange.to}`);

  if (res.status !== 'success') {
    console.error('Lỗi specialty stats:', res.message);
    return;
  }

  const d = (res.data || []).filter(x => parseFloat(x.doanh_thu || 0) > 0);

  const labels = d.map(x => x.ten_chuyen_khoa);
  const doanhThu = d.map(x => parseFloat(x.doanh_thu || 0));

  // Màu sắc
  const colors = [
    '#0d6efd', '#198754', '#ffc107', '#dc3545',
    '#6f42c1', '#fd7e14', '#20c997', '#0dcaf0',
  ];

  const ctx = document.getElementById('specialtyChart');

  if (specialtyChart) specialtyChart.destroy();

  specialtyChart = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: labels,
      datasets: [{
        data: doanhThu,
        backgroundColor: colors.slice(0, d.length),
        borderWidth: 2,
        borderColor: '#fff',
      }],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { position: 'right', labels: { boxWidth: 12 } },
        tooltip: {
          callbacks: {
            label: (ctx) => {
              const total = ctx.dataset.data.reduce((s, v) => s + v, 0);
              const percent = ((ctx.raw / total) * 100).toFixed(1);
              return `${ctx.label}: ${api.formatMoney(ctx.raw)} (${percent}%)`;
            },
          },
        },
      },
    },
  });
}

/* ============================================================
   XUẤT BÁO CÁO EXCEL
   ============================================================ */
async function exportReport() {
  api.toast('Đang tạo báo cáo...', 'info');

  const url = `${CONFIG.API_BASE}/dashboard/export-excel?from=${currentRange.from}&to=${currentRange.to}&token=${api.token}`;

  // Tải file trực tiếp
  window.location.href = url;

  setTimeout(() => api.toast('✅ Đã tải báo cáo', 'success'), 1000);
}