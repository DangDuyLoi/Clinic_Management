/* ============================================================
   ADMIN SERVICES — Quản lý dịch vụ
   ============================================================ */

let editingServiceId = null;

document.addEventListener('DOMContentLoaded', () => {
  if (!auth.requireAuth(['QuanTri'])) return;
  auth.renderUserInfo();

  document.getElementById('searchInput').addEventListener('input', debounce(loadServices, 400));
  loadServices();
});

async function loadServices() {
  const q = document.getElementById('searchInput').value.trim();
  let url = '/dich-vu';
  if (q) url += `?q=${encodeURIComponent(q)}`;

  const tbody = document.getElementById('serviceTable');
  tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted" style="padding:32px">Đang tải...</td></tr>';

  const res = await api.get(url);
  if (res.status !== 'success') {
    tbody.innerHTML = `<tr><td colspan="5" class="text-center text-danger">Lỗi: ${res.message}</td></tr>`;
    return;
  }

  const data = res.data || [];
  if (!data.length) {
    tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted" style="padding:32px">Không có dịch vụ</td></tr>';
    return;
  }

  tbody.innerHTML = data.map(dv => `
    <tr>
      <td>${dv.ma_dich_vu}</td>
      <td><b>${dv.ten_dich_vu}</b></td>
      <td><b class="text-primary">${api.formatMoney(dv.don_gia)}</b></td>
      <td>${dv.mo_ta || '—'}</td>
      <td>
        <button class="btn btn-warning btn-sm" onclick="openEditServiceModal(${dv.ma_dich_vu})">✏</button>
        <button class="btn btn-danger btn-sm" onclick="deleteService(${dv.ma_dich_vu})">🗑</button>
      </td>
    </tr>
  `).join('');
}

function openServiceModal() {
  editingServiceId = null;
  document.getElementById('modalTitle').textContent = 'Thêm dịch vụ';
  document.getElementById('f_ma_dv').value = '';
  document.getElementById('f_ten').value = '';
  document.getElementById('f_gia').value = '';
  document.getElementById('f_mo_ta').value = '';
  document.getElementById('serviceModal').classList.remove('hidden');
}

async function openEditServiceModal(id) {
  const res = await api.get(`/dich-vu/${id}`);
  if (res.status !== 'success') return api.toast('Không tải được', 'error');

  const dv = res.data;
  editingServiceId = dv.ma_dich_vu;
  document.getElementById('modalTitle').textContent = 'Sửa dịch vụ';
  document.getElementById('f_ma_dv').value = dv.ma_dich_vu;
  document.getElementById('f_ten').value = dv.ten_dich_vu || '';
  document.getElementById('f_gia').value = dv.don_gia || 0;
  document.getElementById('f_mo_ta').value = dv.mo_ta || '';
  document.getElementById('serviceModal').classList.remove('hidden');
}

function closeServiceModal() {
  document.getElementById('serviceModal').classList.add('hidden');
}

async function saveService() {
  const ten = document.getElementById('f_ten').value.trim();
  const gia = parseFloat(document.getElementById('f_gia').value);
  const moTa = document.getElementById('f_mo_ta').value.trim();

  if (!ten) return api.toast('Nhập tên dịch vụ', 'error');
  if (isNaN(gia) || gia < 0) return api.toast('Đơn giá không hợp lệ', 'error');

  const payload = { ten_dich_vu: ten, don_gia: gia, mo_ta: moTa || null };

  const res = editingServiceId
    ? await api.put(`/dich-vu/${editingServiceId}`, payload)
    : await api.post('/dich-vu', payload);

  if (res.status === 'success') {
    api.toast(editingServiceId ? '✅ Cập nhật thành công' : '✅ Thêm thành công', 'success');
    closeServiceModal();
    loadServices();
  } else api.toast(res.message, 'error');
}

async function deleteService(id) {
  if (!confirm('Xóa dịch vụ này?')) return;
  const res = await api.delete(`/dich-vu/${id}`);
  if (res.status === 'success') {
    api.toast('Đã xóa', 'success');
    loadServices();
  } else api.toast(res.message, 'error');
}

function debounce(fn, wait) {
  let t;
  return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), wait); };
}