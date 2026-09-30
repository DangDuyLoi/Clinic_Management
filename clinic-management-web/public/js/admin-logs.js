/* ============================================================
   ADMIN LOGS — Nhật ký hệ thống
   ============================================================ */

let logsPage = 1;
let logsLastPage = 1;

document.addEventListener('DOMContentLoaded', () => {
  if (!auth.requireAuth(['QuanTri'])) return;
  auth.renderUserInfo();

  document.getElementById('filterTable').addEventListener('change', () => { logsPage = 1; loadLogs(); });
  document.getElementById('filterAction').addEventListener('change', () => { logsPage = 1; loadLogs(); });

  loadLogs();
});

async function loadLogs() {
  const bang = document.getElementById('filterTable').value;
  const action = document.getElementById('filterAction').value;

  let url = `/nhat-ky?page=${logsPage}&per_page=30`;
  if (bang) url += `&bang_tac_dong=${bang}`;
  if (action) url += `&hanh_dong=${action}`;

  const tbody = document.getElementById('logTable');
  tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted" style="padding:32px">Đang tải...</td></tr>';

  const res = await api.get(url);

  if (res.status !== 'success') {
    tbody.innerHTML = `<tr><td colspan="6" class="text-center text-danger">Lỗi: ${res.message}</td></tr>`;
    return;
  }

  const paginator = res.data;
  const data = paginator.data || [];
  logsLastPage = paginator.last_page || 1;

  if (!data.length) {
    tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted" style="padding:32px">Chưa có nhật ký</td></tr>';
    document.getElementById('pagination').style.display = 'none';
    return;
  }

  tbody.innerHTML = data.map(nk => {
    const actionCls = {
      'CREATE': 'badge-done',
      'UPDATE': 'badge-doing',
      'DELETE': 'badge-cancel',
    }[nk.hanh_dong] || 'badge-wait';

    return `
      <tr>
        <td>${nk.ma_nhat_ky}</td>
        <td>${api.formatDateTime(nk.thoi_gian)}</td>
        <td>${nk.tai_khoan?.ten_dang_nhap || '—'}</td>
        <td><span class="badge ${actionCls}">${nk.hanh_dong}</span></td>
        <td>${nk.bang_tac_dong}</td>
        <td><button class="btn btn-info btn-sm" onclick='showLogDetail(${JSON.stringify(nk).replace(/'/g, "&#39;")})'>👁 Xem</button></td>
      </tr>
    `;
  }).join('');

  document.getElementById('pagination').style.display = 'flex';
  document.getElementById('pageInfo').textContent = `Trang ${paginator.current_page} / ${paginator.last_page} (Tổng ${paginator.total})`;
}

function changePage(delta) {
  logsPage = Math.max(1, Math.min(logsLastPage, logsPage + delta));
  loadLogs();
}

function showLogDetail(nk) {
  const body = document.getElementById('logDetail');
  body.innerHTML = `
    <div class="grid grid-2 mb-2">
      <div><b>ID:</b> ${nk.ma_nhat_ky}</div>
      <div><b>Hành động:</b> ${nk.hanh_dong}</div>
      <div><b>Bảng:</b> ${nk.bang_tac_dong}</div>
      <div><b>Người dùng:</b> ${nk.tai_khoan?.ten_dang_nhap || 'Hệ thống'}</div>
      <div style="grid-column: span 2"><b>Thời gian:</b> ${api.formatDateTime(nk.thoi_gian)}</div>
    </div>
    <div class="form-group">
      <label>Dữ liệu cũ:</label>
      <pre style="background:#f8f9fa;padding:12px;border-radius:6px;font-size:12px;overflow:auto">${nk.du_lieu_cu ? JSON.stringify(nk.du_lieu_cu, null, 2) : '(không có)'}</pre>
    </div>
    <div class="form-group">
      <label>Dữ liệu mới:</label>
      <pre style="background:#f8f9fa;padding:12px;border-radius:6px;font-size:12px;overflow:auto">${nk.du_lieu_moi ? JSON.stringify(nk.du_lieu_moi, null, 2) : '(không có)'}</pre>
    </div>
  `;
  document.getElementById('logModal').classList.remove('hidden');
}