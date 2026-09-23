/* ============================================================
   API WRAPPER — Gọi RESTful API + JWT
   ============================================================ */

const api = {

  /* ---------- TOKEN MANAGEMENT ---------- */

  get token() {
    return localStorage.getItem(CONFIG.TOKEN_KEY);
  },

  set token(value) {
    if (value) {
      localStorage.setItem(CONFIG.TOKEN_KEY, value);
    } else {
      localStorage.removeItem(CONFIG.TOKEN_KEY);
    }
  },

  get user() {
    const raw = localStorage.getItem(CONFIG.USER_KEY);
    try {
      return raw ? JSON.parse(raw) : null;
    } catch (e) {
      return null;
    }
  },

  set user(obj) {
    if (obj) {
      localStorage.setItem(CONFIG.USER_KEY, JSON.stringify(obj));
    } else {
      localStorage.removeItem(CONFIG.USER_KEY);
    }
  },

  /* Xóa toàn bộ dữ liệu phiên */
  clear() {
    localStorage.removeItem(CONFIG.TOKEN_KEY);
    localStorage.removeItem(CONFIG.USER_KEY);
    localStorage.removeItem(CONFIG.TOKEN_EXPIRY_KEY);
  },

  /* ---------- CORE REQUEST ---------- */

  async request(endpoint, method = 'GET', body = null, options = {}) {
    /* Xây URL đầy đủ */
    const url = endpoint.startsWith('http')
      ? endpoint
      : CONFIG.API_BASE + endpoint;

    /* Chuẩn bị headers */
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...(options.headers || {})
    };

    /* Đính kèm JWT nếu có */
    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    /* Timeout bằng AbortController */
    const controller = new AbortController();
    const timeoutId = setTimeout(
      () => controller.abort(),
      CONFIG.REQUEST_TIMEOUT
    );

    try {
      const response = await fetch(url, {
        method,
        headers,
        body: body ? JSON.stringify(body) : null,
        signal: controller.signal
      });

      clearTimeout(timeoutId);

      /* 401 — Hết phiên đăng nhập */
      if (response.status === 401) {
        this.clear();
        if (!window.location.pathname.endsWith('login.html')) {
          this.toast('Phiên đăng nhập đã hết hạn', 'error');
          setTimeout(() => window.location.href = '/login.html', 1200);
        }
        return { status: 'error', message: 'Unauthorized', httpCode: 401 };
      }

      /* 403 — Không có quyền */
      if (response.status === 403) {
        return {
          status: 'error',
          message: 'Bạn không có quyền truy cập chức năng này',
          httpCode: 403
        };
      }

      /* Parse JSON an toàn */
      const data = await response.json().catch(() => ({}));

      return {
        status: response.ok ? (data.status || 'success') : 'error',
        message: data.message || (response.ok ? 'Thành công' : 'Có lỗi xảy ra'),
        data: data.data !== undefined ? data.data : data,
        httpCode: response.status
      };

    } catch (error) {
      clearTimeout(timeoutId);

      if (error.name === 'AbortError') {
        return { status: 'error', message: 'Yêu cầu quá thời gian. Vui lòng thử lại.' };
      }
      return { status: 'error', message: 'Không kết nối được server: ' + error.message };
    }
  },

  /* ---------- SHORTCUT METHODS ---------- */
  get(endpoint, options)         { return this.request(endpoint, 'GET', null, options); },
  post(endpoint, body, options)  { return this.request(endpoint, 'POST', body, options); },
  put(endpoint, body, options)   { return this.request(endpoint, 'PUT', body, options); },
  patch(endpoint, body, options) { return this.request(endpoint, 'PATCH', body, options); },
  delete(endpoint, options)      { return this.request(endpoint, 'DELETE', null, options); },

  /* ---------- TOAST NOTIFICATION ---------- */
  toast(message, type = 'info', duration = 3000) {
    let container = document.querySelector('.toast-container');
    if (!container) {
      container = document.createElement('div');
      container.className = 'toast-container';
      document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    container.appendChild(toast);

    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transition = 'opacity 0.3s';
      setTimeout(() => toast.remove(), 300);
    }, duration);
  },

  /* ---------- FORMAT HELPERS ---------- */
  formatMoney(amount) {
    if (amount == null) return '0đ';
    return Number(amount).toLocaleString('vi-VN') + 'đ';
  },

  formatDate(dateStr) {
    if (!dateStr) return '';
    return new Date(dateStr).toLocaleDateString('vi-VN');
  },

  formatDateTime(dateStr) {
    if (!dateStr) return '';
    return new Date(dateStr).toLocaleString('vi-VN');
  }
};