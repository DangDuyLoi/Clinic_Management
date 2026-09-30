/* ============================================================
   AUTH — Xử lý xác thực & phân quyền
   ============================================================ */

const auth = {

  /* ---------- ĐĂNG NHẬP ---------- */
  async login(ten_dang_nhap, mat_khau) {
    const res = await api.post('/auth/login', {
      ten_dang_nhap,
      mat_khau
    });

    if (res.status === 'success' && res.data?.token) {
      api.token = res.data.token;
      api.user  = res.data.user;

      /* Lưu thời điểm hết hạn (nếu backend trả về expires_in) */
      if (res.data.expires_in) {
        const expiry = Date.now() + res.data.expires_in * 1000;
        localStorage.setItem(CONFIG.TOKEN_EXPIRY_KEY, expiry);
      }

      return { success: true, user: res.data.user };
    }

    return {
      success: false,
      message: res.message || 'Tên đăng nhập hoặc mật khẩu không đúng'
    };
  },

  /* ---------- ĐĂNG XUẤT ---------- */
  async logout() {
    try {
      await api.post('/auth/logout');
    } catch (e) {
      /* Bỏ qua lỗi khi server không phản hồi */
    }
    api.clear();
    window.location.href = '/login.html';
  },

  /* ---------- GETTER ---------- */
  currentUser() {
    return api.user;
  },

  isAuthenticated() {
    return !!api.token && !!api.user;
  },

  role() {
    return api.user?.vai_tro || null;
  },

  /* ---------- BẢO VỆ TRANG ---------- */
  /* Gọi ở đầu mỗi trang nội bộ để kiểm tra đăng nhập + phân quyền */
  requireAuth(allowedRoles = []) {
    /* Chưa đăng nhập */
    if (!this.isAuthenticated()) {
      window.location.href = '/login.html';
      return false;
    }

    /* Đã đăng nhập nhưng không đúng vai trò */
    if (allowedRoles.length > 0 && !allowedRoles.includes(this.role())) {
      api.toast('Bạn không có quyền truy cập trang này', 'error');
      setTimeout(() => {
        const home = CONFIG.ROLE_HOME[this.role()] || '/login.html';
        window.location.href = home;
      }, 1500);
      return false;
    }

    return true;
  },

  /* ---------- ĐIỀU HƯỚNG ---------- */
  redirectToHome() {
    const home = CONFIG.ROLE_HOME[this.role()];
    window.location.href = home || '/login.html';
  },

  /* ---------- HIỂN THỊ USER Ở HEADER ---------- */
  renderUserInfo() {
    const el = document.querySelector('.user-info');
    if (!el || !api.user) return;

    const u = api.user;
    const ho_ten = u.ho_ten || u.ten_dang_nhap || 'Người dùng';

    el.innerHTML = `
      <span>👤 ${ho_ten}</span>
      <span class="role-badge">${this.roleLabel(u.vai_tro)}</span>
      <button class="btn btn-outline btn-sm" onclick="auth.logout()">
        Đăng xuất
      </button>
    `;
  },

  /* ---------- NHÃN VAI TRÒ ---------- */
  roleLabel(role) {
    return CONFIG.ROLE_LABEL[role] || role;
  }
};