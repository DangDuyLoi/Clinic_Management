/* ============================================================
   NOTIFICATION SYSTEM — Chuông thông báo
   ============================================================ */

let notificationInterval = null;
let lastUnreadCount = 0;
let notificationsCache = [];

document.addEventListener('DOMContentLoaded', () => {
    // Chỉ chạy nếu đã đăng nhập
    if (!auth.isAuthenticated()) return;

    // Chờ 2s cho các file khác load xong
    setTimeout(() => {
        initNotificationBell();
        startNotificationPolling();
    }, 2000);
});

/* ============================================================
   KHỞI TẠO CHUÔNG
   ============================================================ */
function initNotificationBell() {
    const userInfo = document.querySelector('.user-info');
    if (!userInfo) {
        console.warn('⚠️ Không tìm thấy .user-info để gắn chuông');
        return;
    }

    // ⭐ Tạo wrapper bao quanh bell + user-info (fix chuông nằm giữa)
    const headerActions = document.createElement('div');
    headerActions.className = 'header-actions';
    userInfo.parentNode.insertBefore(headerActions, userInfo);
    headerActions.appendChild(userInfo);   // Di chuyển user-info vào wrapper

    // Tạo notification wrapper
    const notiWrap = document.createElement('div');
    notiWrap.className = 'notification-wrapper';
    notiWrap.id = 'notificationWrapper';
    notiWrap.innerHTML = `
        <button class="notification-bell" id="notificationBell" title="Thông báo">
            🔔
            <span class="notification-badge hidden" id="notificationBadge">0</span>
        </button>
        <div class="notification-dropdown hidden" id="notificationDropdown">
            <div class="notification-header">
                <h4>🔔 Thông báo</h4>
                <button class="mark-all" onclick="markAllAsRead()">Đánh dấu tất cả đã đọc</button>
            </div>
            <div class="notification-list" id="notificationList">
                <div class="notification-empty">
                    <div class="icon-empty">🔕</div>
                    <div>Chưa có thông báo nào</div>
                </div>
            </div>
        </div>
    `;

    // Chèn bell TRƯỚC user-info, cùng trong wrapper
    headerActions.insertBefore(notiWrap, userInfo);

    // Sự kiện click vào bell
    document.getElementById('notificationBell').addEventListener('click', (e) => {
        e.stopPropagation();
        toggleDropdown();
    });

    // Click ra ngoài → đóng dropdown
    document.addEventListener('click', (e) => {
        const wrapper = document.getElementById('notificationWrapper');
        if (wrapper && !wrapper.contains(e.target)) {
            document.getElementById('notificationDropdown')?.classList.add('hidden');
        }
    });

    console.log('✅ Notification bell đã khởi tạo');
}

/* ============================================================
   TOGGLE DROPDOWN
   ============================================================ */
function toggleDropdown() {
    const dropdown = document.getElementById('notificationDropdown');
    const isHidden = dropdown.classList.contains('hidden');

    if (isHidden) {
        dropdown.classList.remove('hidden');
        loadNotifications();
    } else {
        dropdown.classList.add('hidden');
    }
}

/* ============================================================
   LOAD DANH SÁCH THÔNG BÁO
   ============================================================ */
async function loadNotifications() {
    const listEl = document.getElementById('notificationList');

    const res = await api.get('/thong-bao');

    if (res.status !== 'success') {
        console.error('Lỗi load noti:', res.message);
        return;
    }

    const data = res.data.danh_sach || [];
    notificationsCache = data;

    if (!data.length) {
        listEl.innerHTML = `
            <div class="notification-empty">
                <div class="icon-empty">🔕</div>
                <div>Chưa có thông báo nào</div>
            </div>`;
        return;
    }

    const icons = {
        'dat_lich': '📅',
        'check_in': '🔔',
        'thanh_toan': '💰',
        'hoan_thanh': '✅',
        'he_thong': 'ℹ️',
    };

    listEl.innerHTML = data.map(tb => `
        <div class="notification-item ${tb.da_doc ? '' : 'unread'}"
             onclick="handleNotificationClick(${tb.ma_thong_bao}, ${tb.duong_dan ? `'${tb.duong_dan}'` : 'null'})">
            <div class="icon">${icons[tb.loai] || 'ℹ️'}</div>
            <div class="content">
                <div class="title">${tb.tieu_de}</div>
                <div class="desc">${tb.noi_dung || ''}</div>
                <div class="time">${formatTime(tb.thoi_gian)}</div>
            </div>
        </div>
    `).join('');
}

/* ============================================================
   CLICK VÀO THÔNG BÁO
   ============================================================ */
async function handleNotificationClick(maTb, duongDan) {
    // Đánh dấu đã đọc
    await api.put(`/thong-bao/${maTb}/read`);

    // Cập nhật UI
    const item = document.querySelector(`[onclick*="handleNotificationClick(${maTb},"]`);
    if (item) item.classList.remove('unread');

    // Điều hướng nếu có đường dẫn
    if (duongDan) {
        setTimeout(() => {
            window.location.href = duongDan;
        }, 300);
    }

    // Cập nhật badge
    updateBadge();
}

/* ============================================================
   ĐÁNH DẤU TẤT CẢ ĐÃ ĐỌC
   ============================================================ */
async function markAllAsRead() {
    const res = await api.put('/thong-bao/read-all');
    if (res.status === 'success') {
        api.toast('Đã đánh dấu tất cả đã đọc', 'success');
        document.querySelectorAll('.notification-item.unread').forEach(el => {
            el.classList.remove('unread');
        });
        updateBadge();
    }
}

/* ============================================================
   POLLING — Check noti mới mỗi 10s
   ============================================================ */
function startNotificationPolling() {
    if (notificationInterval) clearInterval(notificationInterval);

    // Load lần đầu
    checkNewNotifications();

    notificationInterval = setInterval(() => {
        if (document.hidden) return;
        checkNewNotifications();
    }, 10000); // 10 giây

    console.log('✅ Đã bật polling thông báo mỗi 10s');
}

async function checkNewNotifications() {
    const res = await api.get('/thong-bao/count');
    if (res.status !== 'success') return;

    const count = res.data.chua_doc || 0;

    // Cập nhật badge
    const badge = document.getElementById('notificationBadge');
    if (!badge) return;

    if (count > 0) {
        badge.textContent = count > 99 ? '99+' : count;
        badge.classList.remove('hidden');

        // Nếu có noti mới → animation rung + toast
        if (count > lastUnreadCount && lastUnreadCount > 0) {
            const diff = count - lastUnreadCount;
            const bell = document.getElementById('notificationBell');
            bell.classList.remove('has-new');
            void bell.offsetWidth; // Trigger reflow
            bell.classList.add('has-new');

            api.toast(`🔔 Bạn có ${diff} thông báo mới`, 'info', 3000);

            // Nếu dropdown đang mở → reload list
            const dropdown = document.getElementById('notificationDropdown');
            if (dropdown && !dropdown.classList.contains('hidden')) {
                loadNotifications();
            }
        }
    } else {
        badge.classList.add('hidden');
    }

    lastUnreadCount = count;
}

async function updateBadge() {
    await checkNewNotifications();
}

/* ============================================================
   FORMAT TIME (VD: "2 phút trước")
   ============================================================ */
function formatTime(dateStr) {
    if (!dateStr) return '';

    const now = new Date();
    const date = new Date(dateStr);
    const diff = Math.floor((now - date) / 1000); // giây

    if (diff < 60) return 'Vừa xong';
    if (diff < 3600) return `${Math.floor(diff / 60)} phút trước`;
    if (diff < 86400) return `${Math.floor(diff / 3600)} giờ trước`;
    if (diff < 604800) return `${Math.floor(diff / 86400)} ngày trước`;

    return date.toLocaleDateString('vi-VN');
}