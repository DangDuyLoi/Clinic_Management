/* ============================================================
   ADMIN MEDICINES — Quản lý danh mục thuốc
   ============================================================ */

let editingMedicineId = null;
let allMedicines = [];

document.addEventListener('DOMContentLoaded', () => {
  if (!auth.requireAuth(['QuanTri'])) return;
  auth.renderUserInfo();

  document.getElementById('searchInput')
    .addEventListener('input', debounce(applyFilter, 300));

  document.getElementById('filterStock')
    .addEventListener('change', applyFilter);

  loadMedicines();
});

/* ---------- LOAD DANH SÁCH THUỐC ---------- */
async function loadMedicines() {
  const tbody = document.getElementById('medicineTable');
  tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted" style="padding:32px">Đang tải...</td></tr>';

  const res = await api.get('/thuoc');

  if (res.status !== 'success') {
    tbody.innerHTML = `<tr><td colspan="6" class="text-center text-danger" style="padding:32px">
      Lỗi: ${res.message}
    </td></tr>`;
    return;
  }

  allMedicines = res.data || [];
  updateStats();
  applyFilter();
}

/* ---------- THỐNG KÊ ---------- */
function updateStats() {
  const total = allMedicines.length;
  const inStock = allMedicines.filter(t => t.so_luong_ton > 10).length;
  const lowStock = allMedicines.filter(t => t.so_luong_ton <= 10).length;

  document.getElementById('totalMedicines').textContent = total;
  document.getElementById('inStockCount').textContent   = inStock;
  document.getElementById('lowStockCount').textContent  = lowStock;
}

/* ---------- LỌC + TÌM KIẾM ---------- */
function applyFilter() {
  const q = document.getElementById('searchInput').value.trim().toLowerCase();
  const stockFilter = document.getElementById('filterStock').value;

  let list = allMedicines;

  if (q) {
    list = list.filter(t => (t.ten_thuoc || '').toLowerCase().includes(q));
  }

  if (stockFilter === 'in_stock') {
    list = list.filter(t => t.so_luong_ton > 10);
  } else if (stockFilter === 'low_stock') {
    list = list.filter(t => t.so_luong_ton <= 10);
  }

  renderTable(list);
}

/* ---------- RENDER BẢNG ---------- */
function renderTable(list) {
  const tbody = document.getElementById('medicineTable');

  if (!list.length) {
    tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted" style="padding:32px">Không có thuốc nào</td></tr>';
    return;
  }

  tbody.innerHTML = list.map(t => {
    const stockBadge = t.so_luong_ton > 10
      ? `<span class="badge badge-done">${t.so_luong_ton}</span>`
      : t.so_luong_ton > 0
        ? `<span class="badge badge-wait">${t.so_luong_ton}</span>`
        : `<span class="badge badge-cancel">Hết hàng</span>`;

    return `
      <tr>
        <td><b>${t.ma_thuoc}</b></td>
        <td><b>${t.ten_thuoc}</b></td>
        <td>${t.don_vi_tinh || '—'}</td>
        <td><span class="text-primary">${api.formatMoney(t.don_gia)}</span></td>
        <td>${stockBadge}</td>
        <td>
          <button class="btn btn-info btn-sm" onclick="viewMedicine(${t.ma_thuoc})" title="Xem">👁</button>
          <button class="btn btn-warning btn-sm" onclick="openEditMedicineModal(${t.ma_thuoc})" title="Sửa">✏</button>
          <button class="btn btn-success btn-sm" onclick="restockMedicine(${t.ma_thuoc})" title="Nhập thêm kho">📦</button>
          <button class="btn btn-danger btn-sm" onclick="deleteMedicine(${t.ma_thuoc})" title="Xóa">🗑</button>
        </td>
      </tr>
    `;
  }).join('');
}

/* ---------- MODAL THÊM ---------- */
function openMedicineModal() {
  editingMedicineId = null;
  document.getElementById('modalTitle').textContent = 'Thêm thuốc mới';
  document.getElementById('f_ma_thuoc').value = '';
  document.getElementById('f_ten_thuoc').value = '';
  document.getElementById('f_don_vi_tinh').value = '';
  document.getElementById('f_don_gia').value = '';
  document.getElementById('f_so_luong_ton').value = '0';
  document.getElementById('medicineModal').classList.remove('hidden');
  document.getElementById('f_ten_thuoc').focus();
}

/* ---------- MODAL SỬA ---------- */
async function openEditMedicineModal(id) {
  const res = await api.get(`/thuoc/${id}`);
  if (res.status !== 'success') return api.toast('Không tải được thông tin thuốc', 'error');

  const t = res.data;
  editingMedicineId = t.ma_thuoc;
  document.getElementById('modalTitle').textContent = 'Sửa thuốc';
  document.getElementById('f_ma_thuoc').value = t.ma_thuoc;
  document.getElementById('f_ten_thuoc').value = t.ten_thuoc || '';
  document.getElementById('f_don_vi_tinh').value = t.don_vi_tinh || '';
  document.getElementById('f_don_gia').value = t.don_gia || 0;
  document.getElementById('f_so_luong_ton').value = t.so_luong_ton || 0;
  document.getElementById('medicineModal').classList.remove('hidden');
}

function closeMedicineModal() {
  document.getElementById('medicineModal').classList.add('hidden');
}

/* ---------- LƯU (THÊM / SỬA) ---------- */
async function saveMedicine() {
  const tenThuoc = document.getElementById('f_ten_thuoc').value.trim();
  const donVi = document.getElementById('f_don_vi_tinh').value || null;
  const donGia = parseFloat(document.getElementById('f_don_gia').value);
  const soLuong = parseInt(document.getElementById('f_so_luong_ton').value) || 0;

  // Validate
  if (!tenThuoc) return api.toast('Vui lòng nhập tên thuốc', 'error');
  if (isNaN(donGia) || donGia < 0) return api.toast('Đơn giá không hợp lệ', 'error');
  if (soLuong < 0) return api.toast('Số lượng tồn không hợp lệ', 'error');

  const payload = {
    ten_thuoc: tenThuoc,
    don_vi_tinh: donVi,
    don_gia: donGia,
    so_luong_ton: soLuong,
  };

  const btn = document.getElementById('btnSave');
  btn.disabled = true;
  btn.innerHTML = '<span class="spinner"></span> Đang lưu...';

  let res;
  if (editingMedicineId) {
    res = await api.put(`/thuoc/${editingMedicineId}`, payload);
  } else {
    res = await api.post('/thuoc', payload);
  }

  if (res.status === 'success') {
    api.toast(editingMedicineId ? '✅ Cập nhật thành công' : '✅ Thêm thuốc thành công', 'success');
    closeMedicineModal();
    loadMedicines();
  } else {
    api.toast(res.message || 'Lỗi lưu dữ liệu', 'error');
  }

  btn.disabled = false;
  btn.textContent = 'Lưu';
}

/* ---------- XÓA ---------- */
async function deleteMedicine(id) {
  const t = allMedicines.find(x => x.ma_thuoc === id);
  const tenThuoc = t ? t.ten_thuoc : `#${id}`;

  if (!confirm(`Bạn chắc chắn muốn xóa thuốc "${tenThuoc}"?`)) return;

  const res = await api.delete(`/thuoc/${id}`);

  if (res.status === 'success') {
    api.toast('Đã xóa thuốc', 'success');
    loadMedicines();
  } else {
    api.toast(res.message || 'Không thể xóa (thuốc đã dùng trong đơn)', 'error');
  }
}

/* ---------- XEM CHI TIẾT ---------- */
async function viewMedicine(id) {
  const res = await api.get(`/thuoc/${id}`);
  if (res.status !== 'success') return api.toast('Không tải được', 'error');

  const t = res.data;
  alert(
    `📋 THÔNG TIN THUỐC\n` +
    `───────────────────\n` +
    `Mã thuốc     : ${t.ma_thuoc}\n` +
    `Tên thuốc    : ${t.ten_thuoc}\n` +
    `Đơn vị tính  : ${t.don_vi_tinh || '—'}\n` +
    `Đơn giá      : ${api.formatMoney(t.don_gia)}\n` +
    `Tồn kho      : ${t.so_luong_ton}`
  );
}

/* ---------- DEBOUNCE ---------- */
function debounce(fn, wait) {
  let t;
  return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), wait); };
}
/* ---------- NHẬP THÊM KHO ---------- */
async function restockMedicine(id) {
  const t = allMedicines.find(x => x.ma_thuoc === id);
  if (!t) return api.toast('Không tìm thấy thuốc', 'error');

  const them = parseInt(prompt(
    `Nhập thêm số lượng cho "${t.ten_thuoc}"\n` +
    `Tồn kho hiện tại: ${t.so_luong_ton} ${t.don_vi_tinh || ''}\n\n` +
    `Số lượng nhập thêm:`,
    '100'
  ));

  if (!them || them < 1) return;

  const payload = {
    so_luong_ton: t.so_luong_ton + them,
  };

  const res = await api.put(`/thuoc/${id}`, payload);

  if (res.status === 'success') {
    api.toast(`📦 Đã nhập thêm ${them}. Tồn kho mới: ${t.so_luong_ton + them}`, 'success');
    loadMedicines();
  } else {
    api.toast(res.message, 'error');
  }
}