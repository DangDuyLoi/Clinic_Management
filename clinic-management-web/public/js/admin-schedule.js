/* ============================================================
   ADMIN SCHEDULE — Cấu hình lịch khám
   ============================================================ */

let editingCaId = null;
let editingKgId = null;
let dsCa = [];

document.addEventListener('DOMContentLoaded', async () => {
  if (!auth.requireAuth(['QuanTri'])) return;
  auth.renderUserInfo();

  await loadCa();
  await loadKhungGio();
  await loadBacSi();
});

/* ============================================================
   CA LÀM VIỆC
   ============================================================ */
async function loadCa() {
  const tbody = document.getElementById('caTable');
  tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted">Đang tải...</td></tr>';

  const res = await api.get('/ca-lam-viec');
  if (res.status !== 'success') {
    tbody.innerHTML = `<tr><td colspan="5" class="text-center text-danger">Lỗi: ${res.message}</td></tr>`;
    return;
  }

  dsCa = res.data || [];

  // Update dropdown ca trong modal khung giờ
  document.getElementById('f_kg_ca').innerHTML =
    '<option value="">-- Chọn ca --</option>' +
    dsCa.map(c => `<option value="${c.ma_ca}">${c.ten_ca} (${c.gio_bat_dau.slice(0,5)} - ${c.gio_ket_thuc.slice(0,5)})</option>`).join('');

  if (!dsCa.length) {
    tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted" style="padding:32px">Chưa có ca nào</td></tr>';
    return;
  }

  tbody.innerHTML = dsCa.map(c => `
    <tr>
      <td>${c.ma_ca}</td>
      <td><b>${c.ten_ca}</b></td>
      <td>${c.gio_bat_dau.slice(0,5)} - ${c.gio_ket_thuc.slice(0,5)}</td>
      <td><span class="badge badge-info">${c.khung_gio_count || 0}</span></td>
      <td>
        <button class="btn btn-warning btn-sm" onclick="editCa(${c.ma_ca})">✏</button>
        <button class="btn btn-danger btn-sm" onclick="deleteCa(${c.ma_ca})">🗑</button>
      </td>
    </tr>
  `).join('');
}

function openCaModal() {
  editingCaId = null;
  document.getElementById('caModalTitle').textContent = 'Thêm ca làm việc';
  document.getElementById('f_ca_ma').value = '';
  document.getElementById('f_ca_ten').value = '';
  document.getElementById('f_ca_bd').value = '07:30';
  document.getElementById('f_ca_kt').value = '11:30';
  document.getElementById('f_ca_max').value = '100';
  document.getElementById('caModal').classList.remove('hidden');
}

async function editCa(id) {
  const res = await api.get(`/ca-lam-viec/${id}`);
  if (res.status !== 'success') return api.toast('Không tải được', 'error');

  const c = res.data;
  editingCaId = c.ma_ca;
  document.getElementById('caModalTitle').textContent = 'Sửa ca làm việc';
  document.getElementById('f_ca_ma').value = c.ma_ca;
  document.getElementById('f_ca_ten').value = c.ten_ca || '';
  document.getElementById('f_ca_bd').value = c.gio_bat_dau.slice(0,5);
  document.getElementById('f_ca_kt').value = c.gio_ket_thuc.slice(0,5);
  document.getElementById('f_ca_max').value = c.luot_kham_toi_da || 100;
  document.getElementById('caModal').classList.remove('hidden');
}

function closeCaModal() {
  document.getElementById('caModal').classList.add('hidden');
}

async function saveCa() {
  const payload = {
    ten_ca:       document.getElementById('f_ca_ten').value.trim(),
    gio_bat_dau:  document.getElementById('f_ca_bd').value + ':00',
    gio_ket_thuc: document.getElementById('f_ca_kt').value + ':00',
    luot_kham_toi_da: parseInt(document.getElementById('f_ca_max').value) || 100,
  };

  if (!payload.ten_ca) return api.toast('Nhập tên ca', 'error');

  const res = editingCaId
    ? await api.put(`/ca-lam-viec/${editingCaId}`, payload)
    : await api.post('/ca-lam-viec', payload);

  if (res.status === 'success') {
    api.toast(editingCaId ? '✅ Cập nhật thành công' : '✅ Thêm thành công', 'success');
    closeCaModal();
    loadCa();
  } else {
    api.toast(res.message, 'error');
  }
}

async function deleteCa(id) {
  if (!confirm('Xóa ca này?')) return;
  const res = await api.delete(`/ca-lam-viec/${id}`);
  if (res.status === 'success') {
    api.toast('Đã xóa', 'success');
    loadCa();
  } else {
    api.toast(res.message, 'error');
  }
}

/* ============================================================
   KHUNG GIỜ
   ============================================================ */
async function loadKhungGio() {
  const tbody = document.getElementById('kgTable');
  tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted">Đang tải...</td></tr>';

  const res = await api.get('/khung-gio');
  if (res.status !== 'success') {
    tbody.innerHTML = `<tr><td colspan="5" class="text-center text-danger">Lỗi: ${res.message}</td></tr>`;
    return;
  }

  const list = res.data || [];
  if (!list.length) {
    tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted" style="padding:32px">Chưa có khung giờ</td></tr>';
    return;
  }

  tbody.innerHTML = list.map(kg => `
    <tr>
      <td>${kg.ma_khung_gio}</td>
      <td>${kg.calam_viec?.ten_ca || '—'}</td>
      <td><b>${kg.gio_bat_dau.slice(0,5)} - ${kg.gio_ket_thuc.slice(0,5)}</b></td>
      <td><span class="badge badge-info">${kg.luot_kham_toi_da}</span></td>
      <td>
        <button class="btn btn-warning btn-sm" onclick="editKg(${kg.ma_khung_gio})">✏</button>
        <button class="btn btn-danger btn-sm" onclick="deleteKg(${kg.ma_khung_gio})">🗑</button>
      </td>
    </tr>
  `).join('');
}

function openKgModal() {
  editingKgId = null;
  document.getElementById('kgModalTitle').textContent = 'Thêm khung giờ';
  document.getElementById('f_kg_ma').value = '';
  document.getElementById('f_kg_ca').value = '';
  document.getElementById('f_kg_bd').value = '07:30';
  document.getElementById('f_kg_kt').value = '08:30';
  document.getElementById('f_kg_max').value = '5';
  document.getElementById('kgModal').classList.remove('hidden');
}

async function editKg(id) {
  const res = await api.get(`/khung-gio/${id}`);
  if (res.status !== 'success') return api.toast('Không tải được', 'error');

  const kg = res.data;
  editingKgId = kg.ma_khung_gio;
  document.getElementById('kgModalTitle').textContent = 'Sửa khung giờ';
  document.getElementById('f_kg_ma').value = kg.ma_khung_gio;
  document.getElementById('f_kg_ca').value = kg.ma_ca;
  document.getElementById('f_kg_bd').value = kg.gio_bat_dau.slice(0,5);
  document.getElementById('f_kg_kt').value = kg.gio_ket_thuc.slice(0,5);
  document.getElementById('f_kg_max').value = kg.luot_kham_toi_da || 5;
  document.getElementById('kgModal').classList.remove('hidden');
}

function closeKgModal() {
  document.getElementById('kgModal').classList.add('hidden');
}

async function saveKg() {
  const payload = {
    ma_ca:         parseInt(document.getElementById('f_kg_ca').value),
    gio_bat_dau:   document.getElementById('f_kg_bd').value + ':00',
    gio_ket_thuc:  document.getElementById('f_kg_kt').value + ':00',
    luot_kham_toi_da: parseInt(document.getElementById('f_kg_max').value) || 5,
  };

  if (!payload.ma_ca) return api.toast('Chọn ca làm việc', 'error');

  const res = editingKgId
    ? await api.put(`/khung-gio/${editingKgId}`, payload)
    : await api.post('/khung-gio', payload);

  if (res.status === 'success') {
    api.toast(editingKgId ? '✅ Cập nhật thành công' : '✅ Thêm thành công', 'success');
    closeKgModal();
    loadKhungGio();
    loadCa();
  } else {
    api.toast(res.message, 'error');
  }
}

async function deleteKg(id) {
  if (!confirm('Xóa khung giờ này?')) return;
  const res = await api.delete(`/khung-gio/${id}`);
  if (res.status === 'success') {
    api.toast('Đã xóa', 'success');
    loadKhungGio();
    loadCa();
  } else {
    api.toast(res.message, 'error');
  }
}

/* ============================================================
   MAX LƯỢT/CÁ THEO BÁC SĨ
   ============================================================ */
async function loadBacSi() {
  const tbody = document.getElementById('bsTable');
  tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted">Đang tải...</td></tr>';

  const res = await api.get('/bac-si');
  if (res.status !== 'success') {
    tbody.innerHTML = `<tr><td colspan="5" class="text-center text-danger">Lỗi: ${res.message}</td></tr>`;
    return;
  }

  const list = res.data || [];
  if (!list.length) {
    tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted" style="padding:32px">Chưa có bác sĩ</td></tr>';
    return;
  }

  tbody.innerHTML = list.map(bs => `
    <tr>
      <td>${bs.ma_bs}</td>
      <td><b>${bs.ho_ten}</b></td>
      <td>${bs.chuyen_khoa?.ten_chuyen_khoa || '—'}</td>
      <td>
        <input type="number" value="${bs.luot_kham_toi_da_moi_ca}"
               min="1" max="100"
               style="width:80px;padding:4px 8px;border:1px solid #dee2e6;border-radius:4px"
               onchange="updateMaxCa(${bs.ma_bs}, this.value)">
      </td>
      <td>
        <span id="save-${bs.ma_bs}" style="display:none;font-size:12px;color:#198754">✓ Đã lưu</span>
      </td>
    </tr>
  `).join('');
}

async function updateMaxCa(maBs, value) {
  const num = parseInt(value);
  if (isNaN(num) || num < 1 || num > 100) return api.toast('Giá trị phải từ 1-100', 'error');

  const res = await api.put(`/bac-si/${maBs}`, { luot_kham_toi_da_moi_ca: num });
  if (res.status === 'success') {
    const badge = document.getElementById(`save-${maBs}`);
    if (badge) {
      badge.style.display = 'inline';
      setTimeout(() => badge.style.display = 'none', 2000);
    }
    api.toast('✅ Đã cập nhật', 'success', 1500);
  } else {
    api.toast(res.message, 'error');
  }
}