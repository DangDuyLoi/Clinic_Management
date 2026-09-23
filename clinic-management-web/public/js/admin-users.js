/* ============================================================
   ADMIN USERS — Quản lý tài khoản
   ============================================================ */

let usersPage = 1;
let usersLastPage = 1;
let editingUserId = null;

document.addEventListener('DOMContentLoaded', () => {
  if (!auth.requireAuth(['QuanTri'])) return;
  auth.renderUserInfo();

  document.getElementById('searchInput').addEventListener('input', debounce(() => {
    usersPage = 1;
    loadUsers();
  }, 400));

  document.getElementById('filterRole').addEventListener('change', () => {
    usersPage = 1;
    loadUsers();
  });

  loadUsers();
});

async function loadUsers() {
  const q = document.getElementById('searchInput').value.trim();
  const role = document.getElementById('filterRole').value;

  let url = `/admin/users?page=${usersPage}&per_page=15`;
  if (q) url += `&q=${encodeURIComponent(q)}`;
  if (role) url += `&vai_tro=${role}`;

  const tbody = document.getElementById('userTable');
  tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted" style="padding:32px">Đang tải...</td></tr>';

  const res = await api.get(url);

  if (res.status !== 'success') {
    tbody.innerHTML = `<tr><td colspan="6" class="text-center text-danger">Lỗi: ${res.message}</td></tr>`;
    return;
  }

  const paginator = res.data;
  const data = paginator.data || [];
  usersLastPage = paginator.last_page || 1;

  if (data.length === 0) {
    tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted" style="padding:32px">Không có tài khoản</td></tr>';
    document.getElementById('pagination').style.display = 'none';
    return;
  }

  tbody.innerHTML = data.map(u => {
    const statusBadge = u.trang_thai
      ? '<span class="badge badge-done">Hoạt động</span>'
      : '<span class="badge badge-cancel">Đã khóa</span>';

    return `
      <tr>
        <td>${u.ma_tk}</td>
        <td><b>${u.ten_dang_nhap}</b></td>
        <td>${auth.roleLabel(u.vai_tro)}</td>
        <td>${statusBadge}</td>
        <td>${api.formatDate(u.ngay_tao)}</td>
        <td>
          <button class="btn btn-warning btn-sm" onclick="toggleLock(${u.ma_tk}, ${u.trang_thai})">
            ${u.trang_thai ? '🔒 Khóa' : '🔓 Mở'}
          </button>
          <button class="btn btn-info btn-sm" onclick="openEditUserModal(${u.ma_tk})">✏</button>
          ${u.vai_tro !== 'QuanTri'
            ? `<button class="btn btn-danger btn-sm" onclick="deleteUser(${u.ma_tk})">🗑</button>`
            : ''}
        </td>
      </tr>
    `;
  }).join('');

  document.getElementById('pagination').style.display = 'flex';
  document.getElementById('pageInfo').textContent = `Trang ${paginator.current_page} / ${paginator.last_page} (Tổng ${paginator.total})`;
  document.getElementById('btnPrev').disabled = usersPage <= 1;
  document.getElementById('btnNext').disabled = usersPage >= usersLastPage;
}

function changePage(delta) {
  usersPage = Math.max(1, Math.min(usersLastPage, usersPage + delta));
  loadUsers();
}

/* ---------- MODAL ---------- */
function openUserModal() {
  editingUserId = null;
  document.getElementById('modalTitle').textContent = 'Thêm tài khoản';
  document.getElementById('f_ma_tk').value = '';
  document.getElementById('f_ten_dang_nhap').value = '';
  document.getElementById('f_mat_khau').value = '';
  document.getElementById('f_vai_tro').value = 'LeTan';
  document.getElementById('pwdHint').style.display = 'inline';
  document.getElementById('pwdHintText').textContent = 'Mật khẩu tối thiểu 6 ký tự';
  document.getElementById('trangThaiGroup').style.display = 'none';
  document.getElementById('userModal').classList.remove('hidden');
}

async function openEditUserModal(id) {
  const res = await api.get(`/admin/users/${id}`);
  if (res.status !== 'success') return api.toast('Không tải được user', 'error');

  const u = res.data;
  editingUserId = u.ma_tk;
  document.getElementById('modalTitle').textContent = 'Sửa tài khoản';
  document.getElementById('f_ma_tk').value = u.ma_tk;
  document.getElementById('f_ten_dang_nhap').value = u.ten_dang_nhap || '';
  document.getElementById('f_mat_khau').value = '';
  document.getElementById('f_vai_tro').value = u.vai_tro || 'LeTan';
  document.getElementById('pwdHint').style.display = 'none';
  document.getElementById('pwdHintText').textContent = 'Để trống nếu không đổi mật khẩu';
  document.getElementById('trangThaiGroup').style.display = 'block';
  document.getElementById('f_trang_thai').value = u.trang_thai ? '1' : '0';
  document.getElementById('userModal').classList.remove('hidden');
}

function closeUserModal() {
  document.getElementById('userModal').classList.add('hidden');
}

async function saveUser() {
  const ten = document.getElementById('f_ten_dang_nhap').value.trim();
  const mk = document.getElementById('f_mat_khau').value;
  const vt = document.getElementById('f_vai_tro').value;

  if (!ten) return api.toast('Nhập tên đăng nhập', 'error');

  if (editingUserId) {
    const payload = { ten_dang_nhap: ten, vai_tro: vt };
    if (mk) {
      if (mk.length < 6) return api.toast('Mật khẩu tối thiểu 6 ký tự', 'error');
      payload.mat_khau = mk;
    }
    payload.trang_thai = document.getElementById('f_trang_thai').value === '1';

    const res = await api.put(`/admin/users/${editingUserId}`, payload);
    if (res.status === 'success') {
      api.toast('✅ Cập nhật thành công', 'success');
      closeUserModal();
      loadUsers();
    } else api.toast(res.message, 'error');
  } else {
    if (mk.length < 6) return api.toast('Mật khẩu tối thiểu 6 ký tự', 'error');
    const res = await api.post('/admin/users', { ten_dang_nhap: ten, mat_khau: mk, vai_tro: vt });
    if (res.status === 'success') {
      api.toast('✅ Tạo tài khoản thành công', 'success');
      closeUserModal();
      loadUsers();
    } else api.toast(res.message, 'error');
  }
}

async function toggleLock(id, current) {
  const res = await api.put(`/admin/users/${id}/lock`, { trang_thai: !current });
  if (res.status === 'success') {
    api.toast(res.message, 'success');
    loadUsers();
  } else api.toast(res.message, 'error');
}

async function deleteUser(id) {
  if (!confirm('Bạn chắc chắn muốn xóa tài khoản này?')) return;
  const res = await api.delete(`/admin/users/${id}`);
  if (res.status === 'success') {
    api.toast('Đã xóa tài khoản', 'success');
    loadUsers();
  } else api.toast(res.message, 'error');
}

function debounce(fn, wait) {
  let t;
  return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), wait); };
}