import 'dart:async';
import 'package:flutter/material.dart';
import '../services/booking_api_service.dart';
import '../services/fcm_service.dart';

/// Widget theo dõi tiến trình hàng đợi khám theo thời gian thực (Live Queue Tracker)
/// Hiển thị:
/// - Số thứ tự của bạn: 18
/// - Hiện tại phòng khám đang phục vụ: Số 15
/// - Ước tính thời gian chờ: ~10 - 15 phút
/// - Cảnh báo Push Notification khi còn 2-3 số: "Sắp đến lượt bạn! Vui lòng có mặt trước cửa Phòng khám 102"
class LiveQueueTrackerWidget extends StatefulWidget {
  final int maLuotKham;
  final String? initialDoctorName;
  final String? initialRoom;
  final bool isCompact;
  final bool autoPoll;

  const LiveQueueTrackerWidget({
    super.key,
    required this.maLuotKham,
    this.initialDoctorName,
    this.initialRoom,
    this.isCompact = false,
    this.autoPoll = true,
  });

  @override
  State<LiveQueueTrackerWidget> createState() => _LiveQueueTrackerWidgetState();
}

class _LiveQueueTrackerWidgetState extends State<LiveQueueTrackerWidget>
    with SingleTickerProviderStateMixin {
  Timer? _pollingTimer;
  bool _isLoading = true;
  bool _hasNotifiedThisTurn = false;

  int _yourNumber = 18;
  int _currentServing = 15;
  int _waitingAhead = 3;
  String _estimatedWaitTime = "~10 - 15 phút";
  String _room = "Phòng 102 - Lầu 1 Khu A";
  String _doctorName = "Bác sĩ chuyên khoa";
  String _status = "cho_kham";
  bool _isNearTurn = true;
  String _alertMessage = "Sắp đến lượt bạn! Vui lòng có mặt trước cửa phòng khám.";
  bool _isToday = true;
  bool _isFuture = false;
  int _daysLeft = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _room = widget.initialRoom ?? _room;
    _doctorName = widget.initialDoctorName ?? _doctorName;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadQueueStatus();

    if (widget.autoPoll) {
      // Poll mỗi 15 giây để cập nhật tiến trình hàng đợi
      _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        _loadQueueStatus(isBackground: true);
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadQueueStatus({bool isBackground = false}) async {
    if (!isBackground) {
      setState(() => _isLoading = true);
    }
    try {
      final res = await BookingApiService.getQueueStatus(widget.maLuotKham);
      final data = res['data'];
      if (data != null && mounted) {
        final int yourNum = data['so_thu_tu'] ?? 18;
        final int currServing = data['dang_phuc_vu'] ?? 15;
        final int waiting = data['so_nguoi_cho'] ?? (yourNum - currServing);
        final String waitTime = data['thoi_gian_cho_uoc_tinh'] ?? "~10 - 15 phút";
        final String roomName = data['phong_kham'] ?? _room;
        final String docName = data['ten_bac_si'] ?? _doctorName;
        final String st = data['trang_thai'] ?? _status;
        final bool nearTurn = data['canh_bao_sap_den_luot'] ?? (waiting > 0 && waiting <= 3);
        final String msg = data['thong_bao'] ?? "Sắp đến lượt bạn! Vui lòng có mặt trước cửa $roomName.";
        final bool isToday = data['is_today'] ?? true;
        final bool isFuture = data['is_future'] ?? false;
        final int daysLeft = data['so_ngay_con_lai'] ?? 0;

        setState(() {
          _yourNumber = yourNum;
          _currentServing = currServing;
          _waitingAhead = waiting;
          _estimatedWaitTime = waitTime;
          _room = roomName;
          _doctorName = docName;
          _status = st;
          _isNearTurn = nearTurn;
          _alertMessage = msg;
          _isToday = isToday;
          _isFuture = isFuture;
          _daysLeft = daysLeft;
          _isLoading = false;
        });

        // Chỉ kích hoạt Push Notification khi đúng ngày khám hôm nay và còn 2-3 số
        if (_isToday && nearTurn && !_hasNotifiedThisTurn) {
          _hasNotifiedThisTurn = true;
          FCMService.showQueueTurnNotification(
            title: "🔔 Sắp đến lượt bạn!",
            body: "Số của bạn: #$_yourNumber. Phòng khám đang phục vụ #$_currentServing. Vui lòng có mặt trước cửa $_room.",
            room: _room,
            yourNumber: _yourNumber,
            currentServing: _currentServing,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _manualTriggerTestPush() {
    FCMService.showQueueTurnNotification(
      title: "🔔 Sắp đến lượt bạn!",
      body: "Số thứ tự: #$_yourNumber (Đang gọi #$_currentServing). Vui lòng có mặt trước cửa $_room.",
      room: _room,
      yourNumber: _yourNumber,
      currentServing: _currentServing,
    );

    // Kích hoạt backend gửi thông báo
    BookingApiService.triggerQueueNotification(
      widget.maLuotKham,
      stt: _yourNumber,
      dangPhucVu: _currentServing,
    ).catchError((_) => <String, dynamic>{});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              SizedBox(height: 10),
              Text(
                'Đang tải tiến trình hàng đợi...',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final double progress = (_yourNumber > 0 && _isToday)
        ? (_currentServing / _yourNumber).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0056D2).withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _isToday && _isNearTurn ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
          width: _isToday && _isNearTurn ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Live Indicator & Room
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: !_isToday
                  ? const Color(0xFFEFF6FF)
                  : (_isNearTurn ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: !_isToday
                              ? const Color(0xFF3B82F6)
                              : (_isNearTurn ? const Color(0xFFD97706) : const Color(0xFF10B981)),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      !_isToday
                          ? (_isFuture ? 'LỊCH HẸN TRƯỚC' : 'LỊCH KHÁM')
                          : 'HÀNG ĐỢI TRỰC TIẾP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: !_isToday
                            ? const Color(0xFF1D4ED8)
                            : (_isNearTurn ? const Color(0xFFB45309) : const Color(0xFF047857)),
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.meeting_room_outlined, size: 14, color: Color(0xFF0056D2)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _room,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 2 Cột hiển thị số: STT Của bạn & Đang phục vụ
                Row(
                  children: [
                    // Số thứ tự của bạn
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0056D2), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Số thứ tự của bạn',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$_yourNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _isToday ? 'LƯỢT CỦA BẠN' : 'STT ĐÃ CẤP',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Hiện tại đang phục vụ
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: !_isToday ? const Color(0xFFF1F5F9) : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: !_isToday ? const Color(0xFFCBD5E1) : const Color(0xFFA7F3D0)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Đang phục vụ',
                              style: TextStyle(
                                color: !_isToday ? const Color(0xFF64748B) : const Color(0xFF065F46),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isToday ? '$_currentServing' : '--',
                              style: TextStyle(
                                color: !_isToday ? const Color(0xFF94A3B8) : const Color(0xFF047857),
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: !_isToday ? const Color(0xFFE2E8F0) : const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      !_isToday ? Icons.schedule_rounded : Icons.play_arrow_rounded,
                                      size: 11,
                                      color: !_isToday ? const Color(0xFF64748B) : const Color(0xFF047857),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      !_isToday
                                          ? (_isFuture ? 'CHƯA TỚI NGÀY' : 'ĐÃ QUA')
                                          : 'ĐANG KHÁM',
                                      style: TextStyle(
                                        color: !_isToday ? const Color(0xFF64748B) : const Color(0xFF047857),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Thanh tiến trình hàng đợi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            _isToday
                                ? 'Tiến trình khám: $_currentServing/$_yourNumber'
                                : 'Trạng thái: Chưa mở hàng đợi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            !_isToday
                                ? (_isFuture ? 'Còn $_daysLeft ngày nữa' : 'Đã qua ngày hẹn')
                                : (_waitingAhead > 0
                                    ? 'Còn $_waitingAhead số nữa'
                                    : (_status == 'dang_kham' ? 'Đang khám' : 'Đến lượt bạn!')),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _isToday && _waitingAhead <= 3
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF0056D2),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          !_isToday
                              ? const Color(0xFF94A3B8)
                              : (_isNearTurn ? const Color(0xFFD97706) : const Color(0xFF0056D2)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Ước tính thời gian chờ
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        flex: 5,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF64748B)),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Ước tính thời gian chờ:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 6,
                        child: Text(
                          _estimatedWaitTime,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Banner cảnh báo sắp đến lượt (khi đúng ngày khám và còn 2-3 số)
                if (_isToday && _isNearTurn) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCD34D)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_active_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'SẮP ĐẾN LƯỢT KHÁM CỦA BẠN!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _alertMessage,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFB45309),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Nút thử nghiệm Push Notification
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _manualTriggerTestPush,
                            icon: const Icon(Icons.send_rounded, size: 14, color: Color(0xFF92400E)),
                            label: const Text(
                              'Nhận lại Push Notification',
                              style: TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFF59E0B)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Banner thông báo nếu là lịch hẹn tương lai (chưa đến ngày khám)
                if (!_isToday && _isFuture) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0056D2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _alertMessage,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1E3A8A),
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
