/* ============================================================
   ADMIN DOCTORS — Quản lý bác sĩ
   ============================================================ */

let editingDoctorId = null;
let dsChuyenKhoaForDoctor = [];

document.addEventListener('DOMContentLoaded', async () => {
  if (!auth.requireAuth(['QuanTri'])) return;
  auth.renderUserInfo();

  await loadChuyenKhoaOptions();

  document.getElementById('searchInput').addEventListener('input', debounce(loadDoctors, 400));
  document.getElementById('filterCK').addEventListener('change', loadDoctors);

  loadDoctors();
});

async function loadChuyenKhoaOptions() {
  const res = await api.get('/chuyen-khoa');
  if (res.status !== 'success') return;
  dsChuyenKhoaForDoctor = res.data;

  document.getElementById('filterCK').innerHTML =
    '<option value="">Tất cả chuyên khoa</option>' +
    res.data.map(ck => `<option value="${ck.ma_chuyen_khoa}">${ck.ten_chuyen_khoa}</option>`).join('');

  document.getElementById('f_ma_chuyen_khoa').innerHTML =
    '<option value="">-- Chọn --</option>' +
    res.data.map(ck => `<option value="${ck.ma_chuyen_khoa}">${ck.ten_chuyen_khoa}</option>`).join('');
}

async function loadDoctors() {
  const q = document.getElementById('searchInput').value.trim();
  const ck = document.getElementById('filterCK').value;

  let url = '/bac-si';
  const params = [];
  if (q) params.push(`q=${encodeURIComponent(q)}`);
  if (ck) params.push(`chuyen_khoa=${ck}`);
  if (params.length) url += '?' + params.join('&');

  const tbody = document.getElementById('doctorTable');
  tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted" style="padding:32px">Đang tải...</td></tr>';

  const res = await api.get(url);
  if (res.status !== 'success') {
    tbody.innerHTML = `<tr><td colspan="6" class="text-center text-danger">Lỗi: ${res.message}</td></tr>`;
    return;
  }

  const data = res.data || [];
  if (!data.length) {
    tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted" style="padding:32px">Không có bác sĩ</td></tr>';
    return;
  }

  tbody.innerHTML = data.map(bs => `
    <tr>
      <td>${bs.ma_bs}</td>
      <td><b>${bs.ho_ten}</b></td>
      <td>${bs.chuyen_khoa?.ten_chuyen_khoa || '—'}</td>
      <td>${bs.trinh_do || '—'}</td>
      <td>${bs.luot_kham_toi_da_moi_ca}</td>
      <td>
        <button class="btn btn-warning btn-sm" onclick="openEditDoctorModal(${bs.ma_bs})">✏</button>
        <button class="btn btn-danger btn-sm" onclick="deleteDoctor(${bs.ma_bs})">🗑</button>
      </td>
    </tr>
  `).join('');
}

/* ---------- MODAL ---------- */
function openDoctorModal() {
  editingDoctorId = null;
  document.getElementById('modalTitle').textContent = 'Thêm bác sĩ';
  document.getElementById('f_ma_bs').value = '';
  document.getElementById('f_ten_dang_nhap').value = '';
  document.getElementById('f_mat_khau').value = '';
  document.getElementById('f_ho_ten').value = '';
  document.getElementById('f_ma_chuyen_khoa').value = '';
  document.getElementById('f_luot').value = '20';
  document.getElementById('f_trinh_do').value = '';
  document.getElementById('accountSection').style.display = 'block';
  document.getElementById('doctorModal').classList.remove('hidden');
}

async function openEditDoctorModal(id) {
  const res = await api.get(`/bac-si/${id}`);
  if (res.status !== 'success') return api.toast('Không tải được bác sĩ', 'error');

  const bs = res.data;
  editingDoctorId = bs.ma_bs;
  document.getElementById('modalTitle').textContent = 'Sửa bác sĩ';
  document.getElementById('f_ma_bs').value = bs.ma_bs;
  document.getElementById('f_ho_ten').value = bs.ho_ten || '';
  document.getElementById('f_ma_chuyen_khoa').value = bs.ma_chuyen_khoa || '';
  document.getElementById('f_luot').value = bs.luot_kham_toi_da_moi_ca || 20;
  document.getElementById('f_trinh_do').value = bs.trinh_do || '';
  document.getElementById('accountSection').style.display = 'none';  // Không sửa TK ở đây
  document.getElementById('doctorModal').classList.remove('hidden');
}

function closeDoctorModal() {
  document.getElementById('doctorModal').classList.add('hidden');
}

async function saveDoctor() {
  const hoTen = document.getElementById('f_ho_ten').value.trim();
  const maCK = document.getElementById('f_ma_chuyen_khoa').value;
  const luot = parseInt(document.getElementById('f_luot').value) || 20;
  const trinhDo = document.getElementById('f_trinh_do').value.trim();

  if (!hoTen) return api.toast('Nhập họ tên', 'error');
  if (!maCK) return api.toast('Chọn chuyên khoa', 'error');

  const btn = document.getElementById('btnSaveDoctor');
  btn.disabled = true;
  btn.innerHTML = '<span class="spinner"></span> Đang lưu...';

  if (editingDoctorId) {
    const payload = {
      ho_ten: hoTen,
      ma_chuyen_khoa: parseInt(maCK),
      luot_kham_toi_da_moi_ca: luot,
      trinh_do: trinhDo || null,
    };
    const res = await api.put(`/bac-si/${editingDoctorId}`, payload);
    if (res.status === 'success') {
      api.toast('✅ Cập nhật thành công', 'success');
      closeDoctorModal();
      loadDoctors();
    } else api.toast(res.message, 'error');
  } else {
    const tenDn = document.getElementById('f_ten_dang_nhap').value.trim();
    const mk = document.getElementById('f_mat_khau').value;

    if (!tenDn) { btn.disabled = false; btn.textContent = 'Lưu'; return api.toast('Nhập tên đăng nhập', 'error'); }
    if (!mk || mk.length < 6) { btn.disabled = false; btn.textContent = 'Lưu'; return api.toast('Mật khẩu >= 6 ký tự', 'error'); }

    const payload = {
      ten_dang_nhap: tenDn,
      mat_khau: mk,
      ho_ten: hoTen,
      ma_chuyen_khoa: parseInt(maCK),
      luot_kham_toi_da_moi_ca: luot,
      trinh_do: trinhDo || null,
    };
    const res = await api.post('/bac-si', payload);
    if (res.status === 'success') {
      api.toast('✅ Tạo bác sĩ thành công', 'success');
      closeDoctorModal();
      loadDoctors();
    } else api.toast(res.message, 'error');
  }

  btn.disabled = false;
  btn.textContent = 'Lưu';
}

async function deleteDoctor(id) {
  if (!confirm('Xóa bác sĩ này? Tài khoản liên quan cũng sẽ bị xóa.')) return;
  const res = await api.delete(`/bac-si/${id}`);
  if (res.status === 'success') {
    api.toast('Đã xóa bác sĩ', 'success');
    loadDoctors();
  } else api.toast(res.message, 'error');
}

function debounce(fn, wait) {
  let t;
  return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), wait); };
}