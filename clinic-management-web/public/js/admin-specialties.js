/* ============================================================
   ADMIN SPECIALTIES — Quản lý chuyên khoa
   ============================================================ */

let editingSpecId = null;

document.addEventListener('DOMContentLoaded', () => {
  if (!auth.requireAuth(['QuanTri'])) return;
  auth.renderUserInfo();

  document.getElementById('searchInput').addEventListener('input', debounce(loadSpecs, 400));
  loadSpecs();
});

async function loadSpecs() {
  const q = document.getElementById('searchInput').value.trim();
  let url = '/chuyen-khoa';
  if (q) url += `?q=${encodeURIComponent(q)}`;

  const tbody = document.getElementById('specTable');
  tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted" style="padding:32px">Đang tải...</td></tr>';

  const res = await api.get(url);
  if (res.status !== 'success') {
    tbody.innerHTML = `<tr><td colspan="5" class="text-center text-danger">Lỗi: ${res.message}</td></tr>`;
    return;
  }

  const data = res.data || [];
  if (!data.length) {
    tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted" style="padding:32px">Không có chuyên khoa</td></tr>';
    return;
  }

  tbody.innerHTML = data.map(ck => `
    <tr>
      <td>${ck.ma_chuyen_khoa}</td>
      <td><b>${ck.ten_chuyen_khoa}</b></td>
      <td>${ck.mo_ta || '—'}</td>
      <td><span class="badge badge-info">${ck.bac_si_count || 0}</span></td>
      <td>
        <button class="btn btn-warning btn-sm" onclick="openEditSpecModal(${ck.ma_chuyen_khoa})">✏</button>
        <button class="btn btn-danger btn-sm" onclick="deleteSpec(${ck.ma_chuyen_khoa})">🗑</button>
      </td>
    </tr>
  `).join('');
}

function openSpecModal() {
  editingSpecId = null;
  document.getElementById('modalTitle').textContent = 'Thêm chuyên khoa';
  document.getElementById('f_ma_ck').value = '';
  document.getElementById('f_ten').value = '';
  document.getElementById('f_mo_ta').value = '';
  document.getElementById('specModal').classList.remove('hidden');
}

async function openEditSpecModal(id) {
  const res = await api.get(`/chuyen-khoa/${id}`);
  if (res.status !== 'success') return api.toast('Không tải được', 'error');

  const ck = res.data;
  editingSpecId = ck.ma_chuyen_khoa;
  document.getElementById('modalTitle').textContent = 'Sửa chuyên khoa';
  document.getElementById('f_ma_ck').value = ck.ma_chuyen_khoa;
  document.getElementById('f_ten').value = ck.ten_chuyen_khoa || '';
  document.getElementById('f_mo_ta').value = ck.mo_ta || '';
  document.getElementById('specModal').classList.remove('hidden');
}

function closeSpecModal() {
  document.getElementById('specModal').classList.add('hidden');
}

async function saveSpec() {
  const ten = document.getElementById('f_ten').value.trim();
  const moTa = document.getElementById('f_mo_ta').value.trim();

  if (!ten) return api.toast('Nhập tên chuyên khoa', 'error');

  const payload = { ten_chuyen_khoa: ten, mo_ta: moTa || null };

  const res = editingSpecId
    ? await api.put(`/chuyen-khoa/${editingSpecId}`, payload)
    : await api.post('/chuyen-khoa', payload);

  if (res.status === 'success') {
    api.toast(editingSpecId ? '✅ Cập nhật thành công' : '✅ Thêm thành công', 'success');
    closeSpecModal();
    loadSpecs();
  } else {
    api.toast(res.message, 'error');
  }
}

async function deleteSpec(id) {
  if (!confirm('Xóa chuyên khoa này?')) return;
  const res = await api.delete(`/chuyen-khoa/${id}`);
  if (res.status === 'success') {
    api.toast('Đã xóa', 'success');
    loadSpecs();
  } else api.toast(res.message, 'error');
}

function debounce(fn, wait) {
  let t;
  return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), wait); };
}