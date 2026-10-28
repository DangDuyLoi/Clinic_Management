import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/booking_controller.dart';
import 'insurance_screen.dart';
import '../../../services/booking_api_service.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final BookingController controller = Get.find<BookingController>();
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _timeSlots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && controller.selectedDate.value == null) {
        controller.selectedDate.value = DateTime.now();
      }
    });
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final specialtyId = controller.selectedSpecialty.value?['ma_chuyen_khoa'];
      final int? ckId = specialtyId != null ? int.tryParse(specialtyId.toString()) : null;

      final results = await Future.wait([
        BookingApiService.fetchDoctors(maChuyenKhoa: ckId),
        BookingApiService.fetchKhungGio(),
      ]);

      if (mounted) {
        setState(() {
          _doctors = results[0];
          _timeSlots = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final specialtyName = controller.selectedSpecialty.value?['name'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FA),
      appBar: AppBar(
        title: Text(
          specialtyName.isNotEmpty ? 'Bác sĩ: $specialtyName' : 'Chọn bác sĩ khám',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Column(
        children: [
          // Header Note
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 4, height: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('CHỌN BÁC SĨ & KHUNG GIỜ KHÁM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black54, fontSize: 13, fontStyle: FontStyle.italic),
                    children: [
                      TextSpan(text: 'Vui lòng bấm chọn khung giờ '),
                      TextSpan(text: 'màu xanh dương', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      TextSpan(text: ' của bác sĩ bạn muốn đặt khám'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Banner ngày khám đã chọn (khi đi từ nhánh Đặt lịch theo ngày)
          Obx(() {
            final picked = controller.selectedDate.value;
            if (picked == null) return const SizedBox.shrink();
            final dateStr = DateFormat('dd/MM/yyyy').format(picked);
            final dayOfWeek = picked.weekday == 7 ? 'Chủ nhật' : 'Thứ ${picked.weekday + 1}';
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available, color: Color(0xFF0056D2), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ngày khám đã chọn: $dayOfWeek, $dateStr',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E40AF), fontSize: 13),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final DateTime? newDate = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedDate.value ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                        helpText: 'CHỌN NGÀY KHÁM',
                        confirmText: 'CHỌN NGÀY',
                        cancelText: 'HỦY',
                      );
                      if (newDate != null) {
                        controller.selectedDate.value = newDate;
                        setState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF93C5FD)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.calendar_month, size: 14, color: Color(0xFF0056D2)),
                          SizedBox(width: 4),
                          Text(
                            'Đổi ngày',
                            style: TextStyle(color: Color(0xFF0056D2), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // Doctor List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _doctors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('Chưa có lịch trực bác sĩ cho chuyên khoa này', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _doctors.length,
                          itemBuilder: (context, index) {
                            return DoctorBookingCard(
                              doctor: _doctors[index],
                              controller: controller,
                              configuredSlots: _timeSlots,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class DoctorBookingCard extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final BookingController controller;
  final List<Map<String, dynamic>> configuredSlots;

  const DoctorBookingCard({
    super.key,
    required this.doctor,
    required this.controller,
    this.configuredSlots = const [],
  });

  @override
  State<DoctorBookingCard> createState() => _DoctorBookingCardState();
}

class _DoctorBookingCardState extends State<DoctorBookingCard> {
  DateTime? selectedDate;
  late List<DateTime> dates;
  bool _isLoadingSlots = false;
  List<String> _availableSlots = [];
  String? _lastLoadedDate;

  List<String> get timeSlots {
    if (widget.configuredSlots.isNotEmpty) {
      return widget.configuredSlots
          .map((s) => (s['label'] ?? s['time_range'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    // Fallback nếu chưa tải được
    return [
      '07:30 - 08:30',
      '08:30 - 09:30',
      '09:30 - 10:30',
      '10:30 - 11:30',
      '13:00 - 14:00',
      '14:00 - 15:00',
      '15:00 - 16:00',
      '16:00 - 17:00'
    ];
  }

  @override
  void initState() {
    super.initState();
    _initDates();
    if (selectedDate != null) {
      _fetchAvailableSlots();
    }
  }

  @override
  void didUpdateWidget(covariant DoctorBookingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initDates();
    if (selectedDate != null) {
      _fetchAvailableSlots();
    }
  }

  void _initDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final chosen = widget.controller.selectedDate.value;

    DateTime start;
    if (chosen != null) {
      selectedDate = chosen;
      if (chosen.isAfter(today)) {
        final prev = chosen.subtract(const Duration(days: 1));
        start = prev.isBefore(today) ? today : prev;
      } else {
        start = today;
      }
    } else {
      start = today;
    }

    dates = List.generate(7, (index) => start.add(Duration(days: index)));
  }

  Future<void> _fetchAvailableSlots() async {
    if (selectedDate == null) return;
    final doctorId = widget.doctor['id'] ?? widget.doctor['ma_bs'];
    if (doctorId == null) return;

    final int? docId = int.tryParse(doctorId.toString());
    if (docId == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);
    _lastLoadedDate = dateStr;

    if (mounted) {
      setState(() {
        _isLoadingSlots = true;
      });
    }

    try {
      final slots = await BookingApiService.getAvailableTimeSlots(docId, dateStr);
      if (mounted && _lastLoadedDate == dateStr) {
        setState(() {
          _availableSlots = slots;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted && _lastLoadedDate == dateStr) {
        setState(() {
          _isLoadingSlots = false;
        });
      }
    }
  }

  bool _isSlotAvailable(String slot) {
    if (_isLoadingSlots) return false;

    // Khớp nguyên chuỗi (ví dụ: '07:30 - 08:30')
    if (_availableSlots.contains(slot)) return true;

    // Khớp theo giờ bắt đầu (ví dụ: '07:30' hoặc '07:30:00')
    String start = slot;
    if (slot.contains(' - ')) {
      start = slot.split(' - ')[0].trim();
    }
    if (_availableSlots.contains(start)) return true;
    if (_availableSlots.contains('$start:00')) return true;
    if (start.length >= 5 && _availableSlots.contains(start.substring(0, 5))) return true;

    return false;
  }

  Future<void> _pickAnotherDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      widget.controller.selectedDate.value = picked;
      setState(() {
        _initDates();
      });
      _fetchAvailableSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = widget.doctor['name'] ?? widget.doctor['ho_ten'] ?? 'Bác sĩ chuyên khoa';
    final doctorDegree = widget.doctor['trinh_do'] ?? '';
    final doctorRoom = widget.doctor['room'] ?? widget.doctor['phong_kham'] ?? 'Phòng Khám Đa Khoa';
    final avatarUrl = widget.doctor['avatarUrl'] ?? 'https://i.pravatar.cc/150?img=11';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    avatarUrl,
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0056D2)),
                      ),
                      if (doctorDegree.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          doctorDegree,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        doctorRoom,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.doctor['chuyen_khoa'] ?? widget.doctor['ten_chuyen_khoa'] ?? 'Thông tin bác sĩ',
                              style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
          ),
          
          // Dates List
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length + 1,
                itemBuilder: (context, index) {
                  // Nút "Chọn ngày khác 📅" ở cuối danh sách
                  if (index == dates.length) {
                    return GestureDetector(
                      onTap: _pickAnotherDate,
                      child: Container(
                        width: 76,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_month_outlined, color: Color(0xFF0056D2), size: 24),
                            SizedBox(height: 4),
                            Text(
                              'Chọn\nngày khác',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0056D2),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final date = dates[index];
                  final isSelected = selectedDate != null && 
                      date.year == selectedDate!.year && 
                      date.month == selectedDate!.month && 
                      date.day == selectedDate!.day;
                  
                  final isToday = date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;
                  final dayName = isToday ? 'Hôm nay' : 'Thứ ${date.weekday == 7 ? 'CN' : date.weekday + 1}';
                  final dateStr = DateFormat('dd/MM\nyyyy').format(date);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedDate = null;
                          _availableSlots = [];
                        } else {
                          selectedDate = date;
                          widget.controller.selectedDate.value = date;
                        }
                      });
                      if (selectedDate != null) {
                        _fetchAvailableSlots();
                      }
                    },
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0056D2) : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? const Color(0xFF0056D2) : Colors.transparent),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateStr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black87,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, size: 10, color: Color(0xFF0056D2)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Expanded Time Slots
          if (selectedDate != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF8FAFC),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(selectedDate!)} - Buổi khám (Thứ ${selectedDate!.weekday == 7 ? 'CN' : selectedDate!.weekday + 1})',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F5B46), fontSize: 14),
                      ),
                      if (!_isLoadingSlots)
                        InkWell(
                          onTap: _fetchAvailableSlots,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.refresh, size: 14, color: Color(0xFF0056D2)),
                                SizedBox(width: 4),
                                Text('Làm mới', style: TextStyle(color: Color(0xFF0056D2), fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _isLoadingSlots
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Đang kiểm tra tình trạng chỗ trống...',
                                style: TextStyle(color: Colors.black54, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.8,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: timeSlots.length,
                          itemBuilder: (context, index) {
                            final slot = timeSlots[index];
                            final isAvailable = _isSlotAvailable(slot);

                            return GestureDetector(
                              onTap: isAvailable
                                  ? () {
                                      // Gán bác sĩ, ngày khám và khung giờ thực từ MySQL
                                      widget.controller.selectedDoctor.value = widget.doctor;
                                      widget.controller.selectedDate.value = selectedDate;
                                      widget.controller.selectedTimeSlot.value = {'time': slot, 'label': slot};
                                      Get.to(() => const InsuranceScreen());
                                    }
                                  : () {
                                      Get.snackbar(
                                        'Khung giờ đã kín chỗ',
                                        'Khung giờ $slot của bác sĩ này đã có người đặt trước. Vui lòng chọn khung giờ khác.',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: const Color(0xFFDC2626),
                                        colorText: Colors.white,
                                        duration: const Duration(seconds: 3),
                                        margin: const EdgeInsets.all(12),
                                      );
                                    },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isAvailable ? const Color(0xFFE8F1FE) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isAvailable ? const Color(0xFFBFDBFE) : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      slot,
                                      style: TextStyle(
                                        color: isAvailable ? const Color(0xFF0056D2) : const Color(0xFF94A3B8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        decoration: isAvailable ? null : TextDecoration.lineThrough,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isAvailable ? 'Còn chỗ' : 'Hết chỗ',
                                      style: TextStyle(
                                        color: isAvailable ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
            
          // Helper text if no date selected
          if (selectedDate == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 1, width: 30, color: Colors.grey.shade300),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Vui lòng chọn ngày để xem các khung giờ khám', style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                  ),
                  Container(height: 1, width: 30, color: Colors.grey.shade300),
                ],
              ),
            )
        ],
      ),
    );
  }
}
