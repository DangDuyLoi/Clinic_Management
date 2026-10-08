/* ============================================================
   PATIENT RECORD — Phiên khám bệnh (nâng cao)
   ============================================================ */

let maLich = null;
let maPhienKham = null;
let maBenhNhan = null;
let dsThuoc = [];
let dsDichVu = [];
let dsChiTietDonThuoc = [];

document.addEventListener('DOMContentLoaded', async () => {
  if (!auth.requireAuth(['BacSi', 'QuanTri'])) return;
  auth.renderUserInfo();

  const urlParams = new URLSearchParams(window.location.search);
  maLich = urlParams.get('lich');

  if (!maLich) {
    alert('Thiếu tham số lịch khám');
    window.location.href = 'dashboard.html';
    return;
  }

  await loadCategories();
  await loadRecord();
});

/* ============================================================
   TABS
   ============================================================ */
function switchTab(tabName) {
  document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.tab === tabName);
  });
  document.querySelectorAll('.tab-content').forEach(el => {
    el.classList.toggle('hidden', el.id !== `tab-${tabName}`);
  });
}

/* ============================================================
   LOAD DANH MỤC
   ============================================================ */
async function loadCategories() {
  const [thuocRes, dvRes] = await Promise.all([
    api.get('/thuoc'),
    api.get('/dich-vu'),
  ]);

  if (thuocRes.status === 'success') {
    dsThuoc = thuocRes.data;
    document.getElementById('chonThuoc').innerHTML =
      '<option value="">-- Chọn thuốc --</option>' +
      dsThuoc.map(t => `<option value="${t.ma_thuoc}">${t.ten_thuoc} — ${api.formatMoney(t.don_gia)}/${t.don_vi_tinh || 'đv'}</option>`).join('');
  }

  if (dvRes.status === 'success') {
    dsDichVu = dvRes.data;
    document.getElementById('chonDichVu').innerHTML =
      '<option value="">-- Chọn dịch vụ --</option>' +
      dsDichVu.map(d => `<option value="${d.ma_dich_vu}">${d.ten_dich_vu} — ${api.formatMoney(d.don_gia)}</option>`).join('');
  }
}

/* ============================================================
   LOAD PHIÊN KHÁM
   ============================================================ */
async function loadRecord() {
  const res = await api.get(`/phien-kham/by-lich/${maLich}`);

  if (res.status !== 'success') {
    alert('Lỗi tải phiên khám: ' + res.message);
    return;
  }

  const { lich_kham, phien_kham } = res.data;
  maPhienKham = phien_kham.ma_phien_kham;
  maBenhNhan  = lich_kham.ma_bn;

  renderPatientInfo(lich_kham);

  // Điền chẩn đoán
  document.getElementById('chanDoanSoBo').value     = phien_kham.chan_doan_so_bo || '';
  document.getElementById('chanDoanCuoiCung').value = phien_kham.chan_doan_cuoi_cung || '';
  document.getElementById('ghiChuYTe').value        = phien_kham.ghi_chu_y_te || '';

  renderServices(phien_kham.chi_dinh || []);
  renderMedicines(phien_kham.don_thuoc?.chi_tiet || []);

  document.getElementById('loading').classList.add('hidden');
  document.getElementById('content').classList.remove('hidden');
}

function renderPatientInfo(lich) {
  const bn = lich.benh_nhan || {};
  document.getElementById('patientInfo').innerHTML = `
    <div><b>Họ tên:</b> ${bn.ho_ten || '—'}</div>
    <div><b>SĐT:</b> ${bn.so_dien_thoai || '—'}</div>
    <div><b>Ngày sinh:</b> ${bn.ngay_sinh ? api.formatDate(bn.ngay_sinh) : '—'}</div>
    <div><b>Giới tính:</b> ${bn.gioi_tinh === 'Nam' ? 'Nam' : bn.gioi_tinh === 'Nu' ? 'Nữ' : '—'}</div>
    <div><b>Nhóm máu:</b> ${bn.nhom_mau || '—'}</div>
    <div><b>CCCD:</b> ${bn.cccd || '—'}</div>
    <div style="grid-column: span 2"><b>Địa chỉ:</b> ${bn.dia_chi || '—'}</div>
    <div style="grid-column: span 4;background:#fff3cd;padding:10px;border-radius:6px;margin-top:8px">
      <b>⚠️ Dị ứng:</b> ${bn.di_ung || 'Không có'}
    </div>
    <div style="grid-column: span 4;background:#e7f1ff;padding:10px;border-radius:6px">
      <b>📋 Tiền sử bệnh:</b> ${bn.tien_su_benh || 'Không có'}
    </div>
  `;
}

/* ============================================================
   LỊCH SỬ KHÁM
   ============================================================ */
async function showPatientHistory() {
  const modal = document.getElementById('historyModal');
  const content = document.getElementById('historyContent');

  modal.classList.remove('hidden');
  content.innerHTML = '<div class="text-center" style="padding:40px"><span class="spinner spinner-dark spinner-lg"></span><p class="mt-2 text-muted">Đang tải lịch sử...</p></div>';

  const res = await api.get(`/benh-nhan/${maBenhNhan}/lich-su-kham`);

  if (res.status !== 'success') {
    content.innerHTML = `<p class="text-danger">Lỗi: ${res.message}</p>`;
    return;
  }

  const d = res.data;
  const bn = d.benh_nhan;
  const lichSu = d.lich_su || [];

  let html = `
    <div style="background:#f8f9fa;padding:14px;border-radius:8px;margin-bottom:16px">
      <div class="grid grid-2" style="gap:8px;font-size:14px">
        <div><b>Họ tên:</b> ${bn.ho_ten}</div>
        <div><b>SĐT:</b> ${bn.so_dien_thoai || '—'}</div>
        <div><b>Ngày sinh:</b> ${bn.ngay_sinh ? api.formatDate(bn.ngay_sinh) : '—'}</div>
        <div><b>Nhóm máu:</b> ${bn.nhom_mau || '—'}</div>
      </div>
      <div style="margin-top:10px;padding-top:10px;border-top:1px solid #dee2e6">
        <div><b>⚠️ Dị ứng:</b> ${bn.di_ung || 'Không'}</div>
        <div><b>📋 Tiền sử:</b> ${bn.tien_su_benh || 'Không'}</div>
      </div>
      <div style="margin-top:10px;padding-top:10px;border-top:1px solid #dee2e6">
        <b>📊 Tổng số lần khám:</b> <span class="badge badge-info">${d.tong_lan_kham} lần</span>
      </div>
    </div>

    <h4 style="margin-bottom:12px">📅 Lịch sử các lần khám:</h4>
  `;

  if (!lichSu.length) {
    html += '<p class="text-muted text-center" style="padding:20px">Chưa có lần khám nào</p>';
  } else {
    lichSu.forEach((pk, idx) => {
      const lk = pk.lich_kham || {};
      const bs = lk.bac_si || {};
      const ck = bs.chuyen_khoa || {};
      const donThuoc = pk.don_thuoc;

      html += `
        <div style="border:1px solid #dee2e6;border-radius:8px;padding:14px;margin-bottom:12px">
          <div style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:8px">
            <div>
              <b style="font-size:15px;color:#0d6efd">Lần khám #${lichSu.length - idx}</b>
              <div style="font-size:13px;color:#6c757d;margin-top:4px">
                📅 ${lk.ngay_kham ? api.formatDate(lk.ngay_kham) : '—'} 
                · 👨‍⚕️ ${bs.ho_ten || '—'} 
                · 🏥 ${ck.ten_chuyen_khoa || '—'}
              </div>
            </div>
            <span class="badge badge-done">${pk.trang_thai}</span>
          </div>

          <div style="margin-top:10px">
            <div><b>Chẩn đoán:</b> ${pk.chan_doan_cuoi_cung || pk.chan_doan_so_bo || '—'}</div>
            ${pk.ghi_chu_y_te ? `<div style="margin-top:4px"><b>Ghi chú:</b> ${pk.ghi_chu_y_te}</div>` : ''}
          </div>

          ${pk.chi_dinh && pk.chi_dinh.length > 0 ? `
            <div style="margin-top:8px">
              <b>Chỉ định (${pk.chi_dinh.length}):</b>
              <ul style="margin-left:20px;font-size:13px">
                ${pk.chi_dinh.map(cd => `<li>${cd.dich_vu?.ten_dich_vu || '—'} ${cd.ket_qua_chi_tiet ? `<i>— ${cd.ket_qua_chi_tiet}</i>` : ''}</li>`).join('')}
              </ul>
            </div>
          ` : ''}

          ${donThuoc && donThuoc.chi_tiet && donThuoc.chi_tiet.length > 0 ? `
            <div style="margin-top:8px">
              <b>Đơn thuốc (${donThuoc.chi_tiet.length} loại):</b>
              <ul style="margin-left:20px;font-size:13px">
                ${donThuoc.chi_tiet.map(ct => `<li>${ct.thuoc?.ten_thuoc || '—'} — SL: ${ct.so_luong} — ${ct.lieu_luong}</li>`).join('')}
              </ul>
              <div style="text-align:right;margin-top:6px"><b>Tổng: ${api.formatMoney(donThuoc.tong_tien)}</b></div>
            </div>
          ` : ''}
        </div>
      `;
    });
  }

  content.innerHTML = html;
}

function closeHistoryModal() {
  document.getElementById('historyModal').classList.add('hidden');
}

/* ============================================================
   CHỈ ĐỊNH DỊCH VỤ
   ============================================================ */
function renderServices(list) {
  const tbody = document.getElementById('serviceList');
  if (!list.length) {
    tbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted" style="padding:20px">Chưa có chỉ định</td></tr>';
    return;
  }
  tbody.innerHTML = list.map(cd => `
    <tr>
      <td>${cd.dich_vu?.ten_dich_vu || '—'}</td>
      <td>${api.formatMoney(cd.dich_vu?.don_gia)}</td>
      <td><span class="badge badge-wait">${cd.trang_thai}</span></td>
      <td>
        <button class="btn btn-danger btn-sm" onclick="removeService(${cd.ma_chi_dinh})">🗑</button>
      </td>
    </tr>
  `).join('');
}

async function addService() {
  const maDv = document.getElementById('chonDichVu').value;
  if (!maDv) return api.toast('Vui lòng chọn dịch vụ', 'error');

  const res = await api.post(`/phien-kham/${maPhienKham}/chi-dinh`, {
    ma_dich_vu: parseInt(maDv)
  });

  if (res.status === 'success') {
    api.toast('✅ Đã thêm chỉ định', 'success');
    document.getElementById('chonDichVu').value = '';
    await loadRecord();
  } else {
    api.toast(res.message, 'error');
  }
}

async function removeService(id) {
  if (!confirm('Xóa chỉ định này?')) return;
  const res = await api.delete(`/phien-kham/chi-dinh/${id}`);
  if (res.status === 'success') {
    api.toast('Đã xóa', 'success');
    await loadRecord();
  }
}

/* ============================================================
   KÊ ĐƠN THUỐC
   ============================================================ */
function renderMedicines(chiTiet) {
  dsChiTietDonThuoc = chiTiet.map(ct => ({
    ma_thuoc: ct.ma_thuoc,
    ten_thuoc: ct.thuoc?.ten_thuoc || '',
    so_luong: ct.so_luong,
    lieu_luong: ct.lieu_luong,
    thanh_tien: ct.thanh_tien,
  }));
  renderMedicineTable();
}

function renderMedicineTable() {
  const tbody = document.getElementById('medicineList');
  if (!dsChiTietDonThuoc.length) {
    tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted" style="padding:20px">Chưa có thuốc</td></tr>';
    document.getElementById('tongTienThuoc').textContent = '0đ';
    return;
  }
  tbody.innerHTML = dsChiTietDonThuoc.map((ct, i) => `
    <tr>
      <td>${ct.ten_thuoc}</td>
      <td>${ct.so_luong}</td>
      <td>${ct.lieu_luong}</td>
      <td>${api.formatMoney(ct.thanh_tien)}</td>
      <td><button class="btn btn-danger btn-sm" onclick="removeMedicine(${i})">🗑</button></td>
    </tr>
  `).join('');

  const tong = dsChiTietDonThuoc.reduce((s, ct) => s + parseFloat(ct.thanh_tien || 0), 0);
  document.getElementById('tongTienThuoc').textContent = api.formatMoney(tong);
}

function addMedicine() {
  const maThuoc = document.getElementById('chonThuoc').value;
  if (!maThuoc) return api.toast('Vui lòng chọn thuốc', 'error');

  const thuoc = dsThuoc.find(t => t.ma_thuoc == maThuoc);
  if (!thuoc) return;

  const soLuong = parseInt(prompt('Số lượng:', '10'));
  if (!soLuong || soLuong < 1) return;

  const lieuLuong = prompt('Liều lượng (VD: Ngày uống 2 lần, mỗi lần 1 viên):', 'Ngày uống 1 viên sau ăn');
  if (!lieuLuong) return;

  const existing = dsChiTietDonThuoc.find(ct => ct.ma_thuoc == maThuoc);
  if (existing) {
    existing.so_luong += soLuong;
    existing.lieu_luong = lieuLuong;
    existing.thanh_tien = existing.so_luong * parseFloat(thuoc.don_gia);
  } else {
    dsChiTietDonThuoc.push({
      ma_thuoc: thuoc.ma_thuoc,
      ten_thuoc: thuoc.ten_thuoc,
      so_luong: soLuong,
      lieu_luong: lieuLuong,
      thanh_tien: soLuong * parseFloat(thuoc.don_gia),
    });
  }

  document.getElementById('chonThuoc').value = '';
  renderMedicineTable();
}

function removeMedicine(index) {
  dsChiTietDonThuoc.splice(index, 1);
  renderMedicineTable();
}

/* ============================================================
   LƯU CHẨN ĐOÁN
   ============================================================ */
async function saveDiagnosis() {
  const data = {
    chan_doan_so_bo: document.getElementById('chanDoanSoBo').value.trim(),
    chan_doan_cuoi_cung: document.getElementById('chanDoanCuoiCung').value.trim(),
    ghi_chu_y_te: document.getElementById('ghiChuYTe').value.trim(),
  };

  const res = await api.put(`/phien-kham/${maPhienKham}`, data);

  if (res.status === 'success') {
    api.toast('💾 Đã lưu chẩn đoán', 'success');
  } else {
    api.toast(res.message, 'error');
  }
}

/* ============================================================
   LƯU ĐƠN THUỐC
   ============================================================ */
async function savePrescription() {
  if (!dsChiTietDonThuoc.length) {
    return api.toast('Chưa có thuốc nào', 'error');
  }

  const payload = {
    ma_phien_kham: maPhienKham,
    chi_tiet: dsChiTietDonThuoc.map(ct => ({
      ma_thuoc: ct.ma_thuoc,
      so_luong: ct.so_luong,
      lieu_luong: ct.lieu_luong,
    })),
  };

  const res = await api.post('/don-thuoc', payload);

  if (res.status === 'success') {
    api.toast('💊 Đã lưu đơn thuốc', 'success');
    await loadRecord();
  } else {
    api.toast(res.message, 'error');
  }
}

/* ============================================================
   IN ĐƠN THUỐC
   ============================================================ */
function printPrescription() {
  if (!dsChiTietDonThuoc.length) {
    return api.toast('Chưa có thuốc để in', 'error');
  }

  const bn = document.querySelector('#patientInfo').textContent;
  const chanDoan = document.getElementById('chanDoanCuoiCung').value;

  const printWindow = window.open('', '_blank', 'width=800,height=600');
  printWindow.document.write(`
    <html>
    <head>
      <title>Đơn thuốc</title>
      <style>
        body { font-family: Arial, sans-serif; padding: 30px; line-height: 1.6; }
        h1 { text-align: center; color: #198754; margin-bottom: 5px; }
        h2 { text-align: center; font-size: 16px; margin-bottom: 30px; color: #666; }
        .info { margin-bottom: 20px; }
        .info div { margin: 4px 0; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #333; padding: 8px; text-align: left; }
        th { background: #f0f0f0; }
        .footer { margin-top: 50px; text-align: right; }
        .signature { margin-top: 80px; display: flex; justify-content: space-around; }
      </style>
    </head>
    <body>
      <h1>PHÒNG KHÁM ĐA KHOA</h1>
      <h2>ĐƠN THUỐC</h2>

      <div class="info">
        <div><b>Chẩn đoán:</b> ${chanDoan || '—'}</div>
        <div><b>Ngày kê đơn:</b> ${new Date().toLocaleString('vi-VN')}</div>
      </div>

      <table>
        <thead>
          <tr>
            <th>STT</th>
            <th>Tên thuốc</th>
            <th>Số lượng</th>
            <th>Liều lượng</th>
            <th>Thành tiền</th>
          </tr>
        </thead>
        <tbody>
          ${dsChiTietDonThuoc.map((ct, i) => `
            <tr>
              <td>${i + 1}</td>
              <td>${ct.ten_thuoc}</td>
              <td>${ct.so_luong}</td>
              <td>${ct.lieu_luong}</td>
              <td>${api.formatMoney(ct.thanh_tien)}</td>
            </tr>
          `).join('')}
        </tbody>
        <tfoot>
          <tr>
            <td colspan="4" style="text-align:right"><b>TỔNG CỘNG:</b></td>
            <td><b>${api.formatMoney(dsChiTietDonThuoc.reduce((s, ct) => s + parseFloat(ct.thanh_tien || 0), 0))}</b></td>
          </tr>
        </tfoot>
      </table>

      <div class="signature">
        <div style="text-align:center">
          <b>Bệnh nhân</b>
          <div style="height:60px"></div>
          <i>(Ký, ghi rõ họ tên)</i>
        </div>
        <div style="text-align:center">
          <b>Bác sĩ điều trị</b>
          <div style="height:60px"></div>
          <i>(Ký, ghi rõ họ tên)</i>
        </div>
      </div>
    </body>
    </html>
  `);
  printWindow.document.close();
  printWindow.focus();
  setTimeout(() => printWindow.print(), 500);
}

/* ============================================================
   HOÀN THÀNH PHIÊN KHÁM
   ============================================================ */
async function saveDraft() {
  await saveDiagnosis();
  api.toast('💾 Đã lưu nháp', 'success');
}

async function finishExam() {
  if (!confirm('Xác nhận hoàn thành phiên khám? Sau khi hoàn thành không thể sửa.')) return;

  // Lưu chẩn đoán trước
  await saveDiagnosis();

  // Lưu đơn thuốc nếu có
  if (dsChiTietDonThuoc.length > 0) {
    await savePrescription();
  }

  const res = await api.post(`/phien-kham/${maPhienKham}/finish`);

  if (res.status === 'success') {
    api.toast('✅ Đã hoàn thành phiên khám!', 'success');
    setTimeout(() => window.location.href = 'dashboard.html', 1500);
  } else {
    api.toast(res.message, 'error');
  }
}