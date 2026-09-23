/* ============================================================
   LOGIN PAGE — Logic xử lý trang đăng nhập
   ============================================================ */

document.addEventListener('DOMContentLoaded', () => {

  /* 1. Nếu đã đăng nhập → chuyển thẳng về trang chủ vai trò */
  if (auth.isAuthenticated()) {
    auth.redirectToHome();
    return;
  }

  /* 2. Gắn sự kiện submit form */
  const form = document.getElementById('loginForm');
  if (form) {
    form.addEventListener('submit', handleLogin);
  }

  /* 3. Gắn sự kiện toggle hiện/ẩn mật khẩu */
  const toggleBtn = document.getElementById('togglePassword');
  if (toggleBtn) {
    toggleBtn.addEventListener('click', togglePasswordVisibility);
  }

  /* 4. Tự động focus vào ô username */
  document.getElementById('ten_dang_nhap')?.focus();
});

/* ---------- XỬ LÝ SUBMIT FORM ---------- */
async function handleLogin(e) {
  e.preventDefault();

  const btn      = document.getElementById('btnLogin');
  const errEl    = document.getElementById('errorMsg');
  const username = document.getElementById('ten_dang_nhap').value.trim();
  const password = document.getElementById('mat_khau').value;

  /* Ẩn lỗi cũ */
  errEl.hidden = true;

  /* Validate input */
  if (!username || !password) {
    showError('Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu');
    return;
  }

  if (username.length < 3) {
    showError('Tên đăng nhập phải có ít nhất 3 ký tự');
    return;
  }

  /* Disable nút + hiển thị spinner */
  btn.disabled = true;
  btn.innerHTML = '<span class="spinner"></span> Đang đăng nhập...';

  /* Gọi API đăng nhập */
  const result = await auth.login(username, password);

  if (result.success) {
    /* Thành công → toast + redirect */
    api.toast('Đăng nhập thành công!', 'success', 1200);
    setTimeout(() => auth.redirectToHome(), 800);
  } else {
    /* Thất bại → hiện lỗi, khôi phục nút */
    showError(result.message);
    btn.disabled = false;
    btn.textContent = 'Đăng nhập';
    document.getElementById('mat_khau').focus();
    document.getElementById('mat_khau').select();
  }
}

/* ---------- HIỆN LỖI ---------- */
function showError(msg) {
  const errEl = document.getElementById('errorMsg');
  errEl.textContent = '⚠️ ' + msg;
  errEl.hidden = false;
}

/* ---------- TOGGLE PASSWORD VISIBILITY ---------- */
function togglePasswordVisibility() {
  const input = document.getElementById('mat_khau');
  const btn   = document.getElementById('togglePassword');

  if (input.type === 'password') {
    input.type = 'text';
    btn.textContent = '➖';
    btn.classList.add('active');
  } else {
    input.type = 'password';
    btn.textContent = '👁️';
    btn.classList.remove('active');
  }

  /* Giữ focus ở ô mật khẩu */
  input.focus();
}