/* ============================================================
   PATIENT RECORD — Phiên khám bệnh
   ============================================================ */

let maLich = null;
let maPhienKham = null;
let dsThuoc = [];
let dsDichVu = [];
let dsChiTietDonThuoc = [];  // Danh sách thuốc đang kê

document.addEventListener('DOMContentLoaded', async () => {
  if (!auth.requireAuth(['BacSi', 'QuanTri'])) return;
  auth.renderUserInfo();

  // Lấy ma_lich từ URL
  const urlParams = new URLSearchParams(window.location.search);
  maLich = urlParams.get('lich');

  if (!maLich) {
    alert('Thiếu tham số lịch khám');
    window.location.href = 'dashboard.html';
    return;
  }

  await loadCategories();    // Load thuốc + dịch vụ
  await loadRecord();        // Load chi tiết phiên khám
});

/* ---------- LOAD DANH MỤC ---------- */
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

/* ---------- LOAD PHIÊN KHÁM ---------- */
async function loadRecord() {
  const res = await api.get(`/phien-kham/by-lich/${maLich}`);

  if (res.status !== 'success') {
    alert('Lỗi tải phiên khám: ' + res.message);
    return;
  }

  const { lich_kham, phien_kham } = res.data;
  maPhienKham = phien_kham.ma_phien_kham;

  // Hiển thị thông tin bệnh nhân
  renderPatientInfo(lich_kham);

  // Điền chẩn đoán
  document.getElementById('chanDoanSoBo').value     = phien_kham.chan_doan_so_bo || '';
  document.getElementById('chanDoanCuoiCung').value = phien_kham.chan_doan_cuoi_cung || '';
  document.getElementById('ghiChuYTe').value        = phien_kham.ghi_chu_y_te || '';

  // Render chỉ định + đơn thuốc
  renderServices(phien_kham.chi_dinh || []);
  renderMedicines(phien_kham.don_thuoc?.chi_tiet || []);

  // Hiện content
  document.getElementById('loading').classList.add('hidden');
  document.getElementById('content').classList.remove('hidden');
}

function renderPatientInfo(lich) {
  const bn = lich.benh_nhan || {};
  document.getElementById('patientInfo').innerHTML = `
    <div><b>Họ tên:</b> ${bn.ho_ten || '—'}</div>
    <div><b>SĐT:</b> ${bn.so_dien_thoai || '—'}</div>
    <div><b>Ngày sinh:</b> ${bn.ngay_sinh ? api.formatDate(bn.ngay_sinh) : '—'}</div>
    <div><b>Giới tính:</b> ${{'Nam':'Nam','Nu':'Nữ','Khac':'Khác'}[bn.gioi_tinh] || '—'}</div>
    <div><b>Nhóm máu:</b> ${bn.nhom_mau || '—'}</div>
    <div><b>Địa chỉ:</b> ${bn.dia_chi || '—'}</div>
    <div style="grid-column: span 3"><b>Dị ứng:</b> ${bn.di_ung || 'Không có'}</div>
    <div style="grid-column: span 3"><b>Tiền sử bệnh:</b> ${bn.tien_su_benh || 'Không có'}</div>
  `;
}

/* ---------- CHỈ ĐỊNH DỊCH VỤ ---------- */
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
    api.toast('Đã thêm chỉ định', 'success');
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

/* ---------- KÊ ĐƠN THUỐC ---------- */
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

  // ⭐ Cảnh báo nếu thuốc sắp hết
  const soLuongDaKe = dsChiTietDonThuoc
    .filter(ct => ct.ma_thuoc == maThuoc)
    .reduce((s, ct) => s + ct.so_luong, 0);

  const conLai = thuoc.so_luong_ton - soLuongDaKe;

  if (thuoc.so_luong_ton <= 0) {
    return api.toast(`Thuốc "${thuoc.ten_thuoc}" đã hết hàng`, 'error');
  }

  const soLuong = parseInt(prompt(
    `Số lượng (tồn kho còn: ${conLai}):`,
    '10'
  ));

  if (!soLuong || soLuong < 1) return;

  // ⭐ Chặn nếu vượt tồn kho
  if (soLuongDaKe + soLuong > thuoc.so_luong_ton) {
    return api.toast(
      `Không đủ tồn kho. Chỉ còn ${conLai} ${thuoc.don_vi_tinh || 'đơn vị'}`,
      'error'
    );
  }

  const lieuLuong = prompt(
    'Liều lượng (VD: Ngày uống 2 lần, mỗi lần 1 viên):',
    'Ngày uống 1 viên sau ăn'
  );
  if (!lieuLuong) return;

  // Nếu thuốc đã có trong đơn → cộng số lượng
  const existing = dsChiTietDonThuoc.find(ct => ct.ma_thuoc == maThuoc);
  if (existing) {
    existing.so_luong += soLuong;
    existing.lieu_luong = lieuLuong;
    existing.thanh_tien = existing.so_luong * parseFloat(thuoc.don_gia);
  } else {
    dsChiTietDonThuoc.push({
      ma_thuoc: thuoc.ma_thuoc,
      ten_thuoc: thuoc.ten_thuoc,
      don_vi_tinh: thuoc.don_vi_tinh,
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

/* ---------- LƯU CHẨN ĐOÁN ---------- */
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

/* ---------- LƯU ĐƠN THUỐC ---------- */
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
    api.toast('💊 Đã lưu đơn thuốc và trừ kho', 'success');

    // ⭐ RELOAD danh mục thuốc (để cập nhật tồn kho mới)
    const thuocRes = await api.get('/thuoc');
    if (thuocRes.status === 'success') {
      dsThuoc = thuocRes.data;
      document.getElementById('chonThuoc').innerHTML =
        '<option value="">-- Chọn thuốc --</option>' +
        dsThuoc.map(t => {
          const disabled = t.so_luong_ton <= 0 ? 'disabled' : '';
          const stockText = t.so_luong_ton <= 0
            ? ' [HẾT HÀNG]'
            : t.so_luong_ton <= 10
              ? ` [còn ${t.so_luong_ton}]`
              : '';
          return `<option value="${t.ma_thuoc}" ${disabled}>${t.ten_thuoc} — ${api.formatMoney(t.don_gia)}/${t.don_vi_tinh || 'đv'}${stockText}</option>`;
        }).join('');
    }

    await loadRecord();
  } else {
    api.toast(res.message, 'error');
  }
}

/* ---------- HOÀN THÀNH PHIÊN KHÁM ---------- */
async function finishExam() {
  if (!confirm('Xác nhận hoàn thành phiên khám? Sau khi hoàn thành không thể sửa.')) return;

  // Lưu chẩn đoán trước
  await saveDiagnosis();

  const res = await api.post(`/phien-kham/${maPhienKham}/finish`);

  if (res.status === 'success') {
    api.toast('✅ Đã hoàn thành phiên khám!', 'success');
    setTimeout(() => window.location.href = 'dashboard.html', 1500);
  } else {
    api.toast(res.message, 'error');
  }
}