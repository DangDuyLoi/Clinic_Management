/* ============================================================
   CẤU HÌNH HỆ THỐNG — Dùng chung cho toàn bộ frontend
   ============================================================ */

const CONFIG = {
  /* ---------- URL Backend ---------- */
  API_BASE: 'http://localhost:8000/api',

  /* ---------- Local Storage Keys ---------- */
  TOKEN_KEY: 'clinic_token',
  USER_KEY: 'clinic_user',
  TOKEN_EXPIRY_KEY: 'clinic_token_expiry',

  /* ---------- Timeout request (ms) ---------- */
  REQUEST_TIMEOUT: 15000,

  /* ---------- Trang chủ theo vai trò sau đăng nhập ---------- */
  ROLE_HOME: {
    'QuanTri':  '/views/admin/dashboard.html',
    'BacSi':    '/views/doctor/dashboard.html',
    'LeTan':    '/views/receptionist/dashboard.html',
    'BenhNhan': '/views/patient/dashboard.html'
  },

  /* ---------- Nhãn tiếng Việt cho vai trò ---------- */
  ROLE_LABEL: {
    'QuanTri':  'Quản trị viên',
    'BacSi':    'Bác sĩ',
    'LeTan':    'Lễ tân',
    'BenhNhan': 'Bệnh nhân'
  }
};