/* ============================================================
   PATIENTS — Quản lý bệnh nhân (Lễ tân)
   ============================================================ */

let currentPage = 1;
let lastPage = 1;
let editingId = null;
let lockedYear = null;
let isCccdLockingProvince = false;

document.addEventListener('DOMContentLoaded', () => {
  // Lắng nghe sự kiện nhập CCCD
  const cccdInput = document.getElementById('f_cccd');
  if (cccdInput) {
    cccdInput.addEventListener('input', function() {
      const cccd = this.value.trim();

      const elQueQuan = document.getElementById('f_que_quan');
      const elNgaySinh = document.getElementById('f_ngay_sinh');


      if (cccd.length < 12) {
        lockedYear = null;
        isCccdLockingProvince = false;
        if (elNgaySinh) {
          elNgaySinh.removeAttribute('max');
          elNgaySinh.removeAttribute('min');
        }
        
        if (elQueQuan) {
          elQueQuan.disabled = false;
          elQueQuan.value = '';
        }
        return;
      }

      // Nếu nhập đủ 12 số -> Tự động bóc tách năm sinh
      if (cccd.length === 12 && /^\d+$/.test(cccd)) {
        const genderCenturyCode = parseInt(cccd[3]);
        const centuryBase = 1900 + (Math.floor(genderCenturyCode / 2) * 100);
        const yearLast2Digits = parseInt(cccd.substring(4, 6));
        const expectedYear = centuryBase + yearLast2Digits;
        
        lockedYear = expectedYear;

        const dateInput = document.getElementById('f_ngay_sinh');
        let currentMonth = '01';
        let currentDay = '01';
        
        if (elNgaySinh) {
          let currentMonth = '01';
          let currentDay = '01';
          if (elNgaySinh.value) {
            const parts = elNgaySinh.value.split('-');
            currentMonth = parts[1];
            currentDay = parts[2];
          }
          elNgaySinh.value = `${expectedYear}-${currentMonth}-${currentDay}`;
        }

        const oldProvinceCode = cccd.substring(0, 3);
          const provinceMapping = { 
            '001':'01','002':'08','004':'04','006':'19','008':'08','010':'15','011':'11','012':'12','014':'14','015':'15','017':'25','019':'19','020':'20','022':'22','024':'24','025':'25','026':'25','027':'24','030':'31','031':'31','033':'33','034':'33','035':'37','036':'37','037':'37','038':'38','040':'40','042':'42','044':'44','045':'44','046':'46','048':'48','049':'48','051':'51','052':'52','054':'66','056':'56','058':'56','060':'68','062':'51','064':'52','066':'66','067':'68','068':'68','070':'75','072':'80','074':'79','075':'75','077':'79','079':'79','080':'80','082':'82','083':'86','084':'86','086':'86','087':'82','089':'91','091':'91','092':'92','093':'92','094':'92','095':'96','096':'96'
          };

          const newProvinceCode = provinceMapping[oldProvinceCode];

          if (newProvinceCode && elQueQuan) {
            const optionToSelect = Array.from(elQueQuan.options).find(opt => opt.getAttribute('data-ma') === newProvinceCode);
            if (optionToSelect) {
              elQueQuan.value = optionToSelect.value;
              elQueQuan.disabled = true;
              isCccdLockingProvince = true;
            }
          }
        }
      }
    );
  }

  // Lắng nghe sự kiện thay đổi ngày sinh để chặn sửa Năm
  const dateInput = document.getElementById('f_ngay_sinh');
  if (dateInput) {
    dateInput.addEventListener('change', function() {
      if (lockedYear) {
        const parts = this.value.split('-'); // Định dạng YYYY-MM-DD
        if (parts[0] !== lockedYear.toString()) {
          api.toast(`Năm sinh đã bị khóa theo CCCD (${lockedYear}). Chỉ được phép sửa Ngày và Tháng.`, 'warning');
          // Ép buộc trả lại năm đúng
          parts[0] = lockedYear;
          this.value = parts.join('-');
        }
      }
    });
  }
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
  loadTinhThanh();
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
      <td>${bn.ma_benh_nhan || '—'}</td>
      <td><b>${bn.ho_ten}</b></td>
      <td>${bn.so_dien_thoai || '—'}</td>
      <td>${gioiTinhLabel(bn.gioi_tinh)}</td>
      <td>${bn.ngay_sinh ? api.formatDate(bn.ngay_sinh) : '—'}</td>
      <td>
        <button class="btn btn-info btn-sm" onclick="viewDetail(${bn.ma_benh_nhan})">👁</button>
        <button class="btn btn-warning btn-sm" onclick="openEditModal(${bn.ma_benh_nhan})">✏</button>
        <button class="btn btn-danger btn-sm" onclick="deletePatient(${bn.ma_benh_nhan})">🗑</button>
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
  lockedYear = null;

  document.getElementById('modalTitle').textContent = 'Thêm bệnh nhân';
  document.getElementById('btnSave').textContent = 'Lưu';

  ['f_ma_bn', 'f_ho_ten', 'f_so_dien_thoai', 'f_ngay_sinh', 'f_cccd',
   'f_email', 'f_dia_chi', 'f_di_ung', 'f_tien_su_benh','f_ma_bhyt'].forEach(id => {
    const el = document.getElementById(id);
    if(el){
      el.value = '';
    }
  });
  document.getElementById('f_gioi_tinh').value = '';
  document.getElementById('f_nhom_mau').value = '';
  document.getElementById('patientModal').classList.remove('hidden');
  document.getElementById('f_que_quan').value = '';
  document.getElementById('f_que_quan').disabled = false;
  isCccdLockingProvince = false;
}

async function openEditModal(id) {
  const res = await api.get(`/benh-nhan/${id}`);
  if (res.status !== 'success') return api.toast('Không tải được thông tin', 'error');

  const bn = res.data;
  editingId = bn.ma_benh_nhan;
  document.getElementById('modalTitle').textContent = 'Sửa bệnh nhân';
  document.getElementById('f_ma_bn').value = bn.ma_benh_nhan;
  document.getElementById('f_ho_ten').value = bn.ho_ten || '';
  document.getElementById('f_so_dien_thoai').value = bn.so_dien_thoai || '';
  if (bn.ngay_sinh) {
    const dateObj = new Date(bn.ngay_sinh);
    // Lấy ngày theo múi giờ máy tính (GMT+7)
    const yyyy = dateObj.getFullYear();
    const mm = String(dateObj.getMonth() + 1).padStart(2, '0');
    const dd = String(dateObj.getDate()).padStart(2, '0');
    document.getElementById('f_ngay_sinh').value = `${yyyy}-${mm}-${dd}`;
} else {
    document.getElementById('f_ngay_sinh').value = '';
}
  document.getElementById('f_gioi_tinh').value = (bn.gioi_tinh === 1 || bn.gioi_tinh === '1') ? 'Nam' : ((bn.gioi_tinh === 0 || bn.gioi_tinh === '0') ? 'Nu' : '');
  document.getElementById('f_cccd').value = bn.cccd || '';
  document.getElementById('f_nhom_mau').value = bn.nhom_mau || '';
  document.getElementById('f_email').value = bn.email || '';
  document.getElementById('f_dia_chi').value = bn.dia_chi || '';
  document.getElementById('f_di_ung').value = bn.di_ung || '';
  document.getElementById('f_tien_su_benh').value = bn.tien_su_benh || '';
  document.getElementById('patientModal').classList.remove('hidden');
  document.getElementById('f_ma_bhyt').value = bn.ma_bhyt || '';
  if (bn.cccd && bn.cccd.length === 12) {
    lockedYear = new Date(bn.ngay_sinh).getFullYear();
  } else {
    lockedYear = null;
  }
  document.getElementById('f_que_quan').value = bn.que_quan || '';
// Nếu bệnh nhân đã có CCCD hợp lệ thì khóa ô quê quán lại
  if (bn.cccd && bn.cccd.length === 12) {
      document.getElementById('f_que_quan').disabled = true;
      isCccdLockingProvince = true;
  } else {
      document.getElementById('f_que_quan').disabled = false;
      isCccdLockingProvince = false;
  }
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
    ma_bhyt: document.getElementById('f_ma_bhyt').value.trim() || null,
    que_quan: document.getElementById('f_que_quan').value || null,

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
  const hs = bn.ho_so_benh_an || {};
  const dsLich = (bn.lich_kham || []).slice(0, 5);
  let gioiTinhText = '—';
  if (bn.gioi_tinh === 1 || bn.gioi_tinh === '1') gioiTinhText = 'Nam';
  else if (bn.gioi_tinh === 0 || bn.gioi_tinh === '0') gioiTinhText = 'Nữ';

  body.innerHTML = `
    <div class="grid grid-2 mb-2">
      <div><b>Họ tên:</b> ${bn.ho_ten}</div>
      <div><b>SĐT:</b> ${bn.so_dien_thoai || '—'}</div>
      <div><b>Ngày sinh:</b> ${bn.ngay_sinh ? api.formatDate(bn.ngay_sinh) : '—'}</div>
      <div><b>Giới tính:</b> ${gioiTinhText}</div>
      <div><b>CCCD:</b> ${hs.cccd ||bn.cccd || '—'}</div>
      <div><b>Nhóm máu:</b> ${hs.nhom_mau ||bn.nhom_mau || '—'}</div>
      <div><b>Mã BHYT:</b> ${bn.ma_bhyt || hs.ma_bhyt || '—'}</div>
      <div><b>Email:</b> ${hs.email ||bn.email || '—'}</div>
      <div><b>Địa chỉ:</b> ${bn.dia_chi || '—'}</div>
    </div>
    <div class="form-group"><label>Dị ứng:</label> ${hs.di_ung ||bn.di_ung || 'Không có'}</div>
    <div class="form-group"><label>Tiền sử bệnh:</label> ${hs.tien_su_benh ||bn.tien_su_benh || 'Không có'}</div>
    <hr>
    <h4>10 lịch khám gần nhất</h4>
    ${dsLich.length ? `
      <table>
        <thead><tr><th>Ngày</th><th>Giờ</th><th>Bác sĩ</th><th>Trạng thái</th></tr></thead>
        <tbody>
          ${dsLich.map(l => {
            const tg = l.thoi_gian_den_kham ? new Date(l.thoi_gian_den_kham) : null;
            const ngay = tg ? tg.toLocaleDateString('vi-VN') : '—';
            const gio = tg ? tg.toLocaleTimeString('vi-VN', {hour: '2-digit', minute:'2-digit'}) : '—';
            
            let trangThaiText = l.trang_thai;
            if (trangThaiText === 'cho_thanh_toan') trangThaiText = 'Chờ thanh toán';
            else if (trangThaiText === 'da_thanh_toan') trangThaiText = 'Đã thanh toán';
            else if (trangThaiText === 'cho_kham') trangThaiText = 'Chờ khám';
            else if (trangThaiText === 'dang_kham') trangThaiText = 'Đang khám';
            else if (trangThaiText === 'hoan_thanh') trangThaiText = 'Hoàn thành';
            else if (trangThaiText === 'huy') trangThaiText = 'Đã hủy';
            else if (trangThaiText === 'hoan_tat_hoa_don') trangThaiText = 'Chờ thu tiền HĐ';

            return `
            <tr>
              <td>${ngay}</td>
              <td>${gio}</td>
              <td>${l.bac_si?.ho_ten || '—'}</td>
              <td>${trangThaiText}</td>
            </tr>
          `}).join('')}
        </tbody>
      </table>
    ` : '<p class="text-muted">Chưa có lịch khám</p>'}
  `;
}

function debounce(fn, wait) {
  let t;
  return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), wait); };
}
async function loadTinhThanh() {
    const res = await api.get('/tinh-thanh');
    if (res.status === 'success') {
        dsTinhThanh = res.data;
        const select = document.getElementById('f_que_quan');
        if (select) {
            select.innerHTML = '<option value="">-- Chọn Tỉnh/Thành phố --</option>' +
                dsTinhThanh.map(t => `<option value="${t.ten_tinh}" data-ma="${t.ma_tinh}">${t.ten_tinh}</option>`).join('');
        }
    }
}