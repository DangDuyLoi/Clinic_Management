/* ============================================================
   PATIENTS — Quản lý bệnh nhân (Lễ tân)
   ============================================================ */

let currentPage = 1;
let lastPage = 1;
let editingId = null;

document.addEventListener('DOMContentLoaded', () => {
  if (!auth.requireAuth(['LeTan', 'QuanTri'])) return;
  auth.renderUserInfo();

  document.getElementById('searchInput').addEventListener('input', debounce(() => {
    currentPage = 1;
    loadPatients();
  }, 400));

  document.getElementById('filterGioiTinh').addEventListener('change', () => {
    currentPage = 1;
    loadPatients();
  });

  loadPatients();
});

/* ---------- LOAD DANH SÁCH ---------- */
async function loadPatients() {
  const q  = document.getElementById('searchInput').value.trim();
  const gt = document.getElementById('filterGioiTinh').value;

  let url = `/benh-nhan?page=${currentPage}&per_page=15`;
  if (q) url += `&q=${encodeURIComponent(q)}`;
  if (gt) url += `&gioi_tinh=${gt}`;

  const tbody = document.getElementById('patientTable');
  tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted" style="padding:32px">Đang tải...</td></tr>';

  const res = await api.get(url);

  if (res.status !== 'success') {
    tbody.innerHTML = `<tr><td colspan="7" class="text-center text-danger">Lỗi: ${res.message}</td></tr>`;
    return;
  }

  const paginator = res.data;
  const data = paginator.data || [];
  lastPage = paginator.last_page || 1;

  if (data.length === 0) {
    tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted" style="padding:32px">Không có bệnh nhân</td></tr>';
    document.getElementById('pagination').style.display = 'none';
    return;
  }

  tbody.innerHTML = data.map(bn => `
    <tr>
      <td>${bn.ma_bn}</td>
      <td><b>${bn.ho_ten}</b></td>
      <td>${bn.so_dien_thoai || '—'}</td>
      <td>${gioiTinhLabel(bn.gioi_tinh)}</td>
      <td>${bn.ngay_sinh ? api.formatDate(bn.ngay_sinh) : '—'}</td>
      <td>${bn.nhom_mau || '—'}</td>
      <td>
        <button class="btn btn-info btn-sm" onclick="viewDetail(${bn.ma_bn})">👁</button>
        <button class="btn btn-warning btn-sm" onclick="openEditModal(${bn.ma_bn})">✏</button>
        <button class="btn btn-danger btn-sm" onclick="deletePatient(${bn.ma_bn})">🗑</button>
      </td>
    </tr>
  `).join('');

  document.getElementById('pagination').style.display = 'flex';
  document.getElementById('pageInfo').textContent = `Trang ${paginator.current_page} / ${paginator.last_page} (Tổng ${paginator.total})`;
  document.getElementById('btnPrev').disabled = currentPage <= 1;
  document.getElementById('btnNext').disabled = currentPage >= lastPage;
}

function gioiTinhLabel(gt) {
  return { 'Nam': 'Nam', 'Nu': 'Nữ', 'Khac': 'Khác' }[gt] || '—';
}

function changePage(delta) {
  currentPage = Math.max(1, Math.min(lastPage, currentPage + delta));
  loadPatients();
}

/* ---------- MODAL THÊM / SỬA ---------- */
function openCreateModal() {
  editingId = null;
  document.getElementById('modalTitle').textContent = 'Thêm bệnh nhân';
  document.getElementById('btnSave').textContent = 'Lưu';
  ['f_ma_bn', 'f_ho_ten', 'f_so_dien_thoai', 'f_ngay_sinh', 'f_cccd',
   'f_email', 'f_dia_chi', 'f_di_ung', 'f_tien_su_benh'].forEach(id => {
    document.getElementById(id).value = '';
  });
  document.getElementById('f_gioi_tinh').value = '';
  document.getElementById('f_nhom_mau').value = '';
  document.getElementById('patientModal').classList.remove('hidden');
}

async function openEditModal(id) {
  const res = await api.get(`/benh-nhan/${id}`);
  if (res.status !== 'success') return api.toast('Không tải được thông tin', 'error');

  const bn = res.data;
  editingId = bn.ma_bn;
  document.getElementById('modalTitle').textContent = 'Sửa bệnh nhân';
  document.getElementById('f_ma_bn').value = bn.ma_bn;
  document.getElementById('f_ho_ten').value = bn.ho_ten || '';
  document.getElementById('f_so_dien_thoai').value = bn.so_dien_thoai || '';
  document.getElementById('f_ngay_sinh').value = bn.ngay_sinh ? bn.ngay_sinh.slice(0, 10) : '';
  document.getElementById('f_gioi_tinh').value = bn.gioi_tinh || '';
  document.getElementById('f_cccd').value = bn.cccd || '';
  document.getElementById('f_nhom_mau').value = bn.nhom_mau || '';
  document.getElementById('f_email').value = bn.email || '';
  document.getElementById('f_dia_chi').value = bn.dia_chi || '';
  document.getElementById('f_di_ung').value = bn.di_ung || '';
  document.getElementById('f_tien_su_benh').value = bn.tien_su_benh || '';
  document.getElementById('patientModal').classList.remove('hidden');
}

function closeModal() {
  document.getElementById('patientModal').classList.add('hidden');
}

/* ---------- LƯU ---------- */
async function savePatient() {
  const payload = {
    ho_ten: document.getElementById('f_ho_ten').value.trim(),
    so_dien_thoai: document.getElementById('f_so_dien_thoai').value.trim(),
    ngay_sinh: document.getElementById('f_ngay_sinh').value || null,
    gioi_tinh: document.getElementById('f_gioi_tinh').value || null,
    cccd: document.getElementById('f_cccd').value.trim() || null,
    nhom_mau: document.getElementById('f_nhom_mau').value || null,
    email: document.getElementById('f_email').value.trim() || null,
    dia_chi: document.getElementById('f_dia_chi').value.trim() || null,
    di_ung: document.getElementById('f_di_ung').value.trim() || null,
    tien_su_benh: document.getElementById('f_tien_su_benh').value.trim() || null,
  };

  if (!payload.ho_ten) return api.toast('Vui lòng nhập họ tên', 'error');
  if (!payload.so_dien_thoai) return api.toast('Vui lòng nhập SĐT', 'error');

  const btn = document.getElementById('btnSave');
  btn.disabled = true;
  btn.innerHTML = '<span class="spinner"></span> Đang lưu...';

  let res;
  if (editingId) {
    res = await api.put(`/benh-nhan/${editingId}`, payload);
  } else {
    res = await api.post('/benh-nhan', payload);
  }

  if (res.status === 'success') {
    api.toast(editingId ? 'Đã cập nhật' : 'Đã thêm bệnh nhân', 'success');
    closeModal();
    loadPatients();
  } else {
    api.toast(res.message || 'Lỗi lưu dữ liệu', 'error');
  }

  btn.disabled = false;
  btn.textContent = 'Lưu';
}

/* ---------- XÓA ---------- */
async function deletePatient(id) {
  if (!confirm('Bạn chắc chắn muốn xóa bệnh nhân này?')) return;

  const res = await api.delete(`/benh-nhan/${id}`);
  if (res.status === 'success') {
    api.toast('Đã xóa bệnh nhân', 'success');
    loadPatients();
  } else {
    api.toast(res.message || 'Không thể xóa', 'error');
  }
}

/* ---------- CHI TIẾT ---------- */
async function viewDetail(id) {
  const body = document.getElementById('detailBody');
  body.innerHTML = 'Đang tải...';
  document.getElementById('detailModal').classList.remove('hidden');

  const res = await api.get(`/benh-nhan/${id}`);
  if (res.status !== 'success') {
    body.innerHTML = `<p class="text-danger">Lỗi: ${res.message}</p>`;
    return;
  }

  const bn = res.data;
  const dsLich = (bn.lich_kham || []).slice(0, 5);

  body.innerHTML = `
    <div class="grid grid-2 mb-2">
      <div><b>Họ tên:</b> ${bn.ho_ten}</div>
      <div><b>SĐT:</b> ${bn.so_dien_thoai || '—'}</div>
      <div><b>Ngày sinh:</b> ${bn.ngay_sinh ? api.formatDate(bn.ngay_sinh) : '—'}</div>
      <div><b>Giới tính:</b> ${gioiTinhLabel(bn.gioi_tinh)}</div>
      <div><b>CCCD:</b> ${bn.cccd || '—'}</div>
      <div><b>Nhóm máu:</b> ${bn.nhom_mau || '—'}</div>
      <div><b>Email:</b> ${bn.email || '—'}</div>
      <div><b>Địa chỉ:</b> ${bn.dia_chi || '—'}</div>
    </div>
    <div class="form-group"><label>Dị ứng:</label> ${bn.di_ung || 'Không có'}</div>
    <div class="form-group"><label>Tiền sử bệnh:</label> ${bn.tien_su_benh || 'Không có'}</div>
    <hr>
    <h4>10 lịch khám gần nhất</h4>
    ${dsLich.length ? `
      <table>
        <thead><tr><th>Ngày</th><th>Giờ</th><th>Bác sĩ</th><th>Trạng thái</th></tr></thead>
        <tbody>
          ${dsLich.map(l => `
            <tr>
              <td>${l.ngay_kham}</td>
              <td>${l.khung_gio?.gio_bat_dau?.slice(0,5) || '—'}</td>
              <td>${l.bac_si?.ho_ten || '—'}</td>
              <td>${l.trang_thai}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    ` : '<p class="text-muted">Chưa có lịch khám</p>'}
  `;
}

function debounce(fn, wait) {
  let t;
  return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), wait); };
}