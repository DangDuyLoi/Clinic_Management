import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/booking_controller.dart';
import 'summary_screen.dart';

/// Màn hình Chọn hình thức khám:
/// - Khám Dịch vụ (giá nội bộ, thanh toán VNPay)
/// - Khám BHYT (áp giá nhà nước, tính mức hưởng theo ký tự thứ 3, hóa đơn nhỏ < 379.500đ)
class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> {
  final BookingController controller = Get.find<BookingController>();
  late final TextEditingController _cardTextController;

  @override
  void initState() {
    super.initState();
    _cardTextController = TextEditingController(text: controller.bhytCardNumber.value);

    // Tự động kiểm tra và lấy mã thẻ từ hồ sơ nếu đã có
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isBhyt && controller.bhytCardNumber.value.isEmpty) {
        controller.autoFillBhytFromProfile();
        if (controller.bhytCardNumber.value.isNotEmpty) {
          _cardTextController.text = controller.bhytCardNumber.value;
        }
      }
    });
  }

  @override
  void dispose() {
    _cardTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FA),
      appBar: AppBar(
        title: const Text(
          'Hình thức khám bệnh',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================== BANNER HƯỚNG DẪN ===================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0056D2), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.medical_information, color: Colors.white, size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chọn hình thức khám',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Vui lòng chọn Khám BHYT để áp dụng mức hưởng theo quy định hoặc Khám Dịch vụ.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =================== PHÂN LUỒNG 2 LỰA CHỌN ===================
            const Text(
              'Hình thức đăng ký khám (bắt buộc)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hệ thống tự động áp dụng giá và quy định thanh toán tương ứng',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),

            // === LỰA CHỌN 1: KHÁM DỊCH VỤ ===
            Obx(() => _buildMethodCard(
                  isSelected: controller.bookingType.value == BookingType.dichVu,
                  icon: Icons.credit_card,
                  iconColor: const Color(0xFF0284C7),
                  title: 'Khám Dịch vụ',
                  badge: 'Giá nội bộ - VNPay',
                  badgeColor: const Color(0xFF0284C7),
                  description:
                      'Áp dụng giá niêm yết của phòng khám. Thanh toán khép kín nhanh chóng qua cổng VNPay. Bỏ qua bước kiểm tra thẻ BHYT.',
                  onTap: () {
                    controller.setBookingType(BookingType.dichVu);
                  },
                )),

            const SizedBox(height: 12),

            // === LỰA CHỌN 2: KHÁM BHYT ===
            Obx(() => _buildMethodCard(
                  isSelected: controller.bookingType.value == BookingType.bhyt,
                  icon: Icons.health_and_safety,
                  iconColor: const Color(0xFF059669),
                  title: 'Khám BHYT',
                  badge: 'Áp giá nhà nước',
                  badgeColor: const Color(0xFF059669),
                  description:
                      'Áp giá khám nhà nước (42.100đ/lượt). Tính mức hưởng theo ký tự thứ 3 mã thẻ (100%, 95%, 80%). Tự động miễn đồng chi trả nếu hóa đơn < 379.500đ.',
                  onTap: () {
                    controller.setBookingType(BookingType.bhyt);
                    if (controller.bhytCardNumber.value.isNotEmpty) {
                      _cardTextController.text = controller.bhytCardNumber.value;
                    }
                  },
                )),

            Obx(() {
              if (controller.canSelectBhytForCurrentItem) {
                return const SizedBox.shrink();
              }
              final targetDate = controller.selectedDate.value;
              final dateStr = targetDate != null
                  ? 'ngày ${DateFormat('dd/MM/yyyy').format(targetDate)}'
                  : 'ngày khám này';
              return Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đã đủ 2 chuyên khoa BHYT trong $dateStr. Chuyên khoa này vui lòng chọn Khám Dịch Vụ.',
                        style: const TextStyle(color: Color(0xFF92400E), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // =================== KHỐI NHẬP MÃ THẺ BHYT (KHI CHỌN KHÁM BHYT) ===================
            Obx(() {
              if (!controller.isBhyt) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: controller.isBhytCardValid.value
                        ? const Color(0xFF059669)
                        : Colors.orange.shade300,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.badge, color: Color(0xFF059669), size: 18),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Thông tin thẻ BHYT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF2C3E50),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Nút tự động lấy từ hồ sơ
                        TextButton.icon(
                          onPressed: () {
                            controller.autoFillBhytFromProfile();
                            if (controller.bhytCardNumber.value.isNotEmpty) {
                              _cardTextController.text = controller.bhytCardNumber.value;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã lấy mã BHYT từ hồ sơ: ${controller.bhytCardNumber.value}'),
                                  backgroundColor: const Color(0xFF059669),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Hồ sơ hiện tại chưa có thông tin thẻ BHYT hợp lệ.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.sync, size: 16, color: Color(0xFF0056D2)),
                          label: const Text(
                            'Lấy từ hồ sơ',
                            style: TextStyle(fontSize: 12, color: Color(0xFF0056D2), fontWeight: FontWeight.w600),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Ô nhập mã thẻ BHYT với Regex kiểm tra realtime
                    TextField(
                      controller: _cardTextController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 15,
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: DN4010123456789',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: const Icon(Icons.credit_card, color: Color(0xFF059669)),
                        suffixIcon: controller.isBhytCardValid.value
                            ? const Icon(Icons.check_circle, color: Color(0xFF059669))
                            : (controller.bhytCardNumber.value.isNotEmpty
                                ? const Icon(Icons.error_outline, color: Colors.red)
                                : null),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        counterText: '${controller.bhytCardNumber.value.length}/15 ký tự',
                      ),
                      onChanged: (val) {
                        controller.validateBhytCard(val);
                      },
                    ),

                    // Thông báo lỗi realtime
                    if (controller.bhytCardError.value != null && controller.bhytCardNumber.value.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.cancel, color: Colors.red, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              controller.bhytCardError.value!,
                              style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // CẢNH BÁO ĐEN TỪ HỆ THỐNG GIÁM ĐỊNH BHYT QUỐC GIA (CHỐNG TRỤC LỢI GOM THUỐC)
                    if (controller.isBhytBlacklisted.value) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.gpp_bad_rounded, color: Color(0xFFDC2626), size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'HỆ THỐNG GIÁM ĐỊNH BHYT QUỐC GIA CẢNH BÁO ĐEN',
                                    style: TextStyle(
                                      color: Color(0xFF991B1B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              controller.bhytBlacklistReason.value.isNotEmpty
                                  ? controller.bhytBlacklistReason.value
                                  : 'Phát hiện bệnh nhân đi khám liên tục nhiều ngày tại nhiều cơ sở để gom thuốc. Thẻ BHYT bị từ chối thanh toán.',
                              style: const TextStyle(color: Color(0xFF7F1D1D), fontSize: 12, height: 1.35),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  controller.setBookingType(BookingType.dichVu);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0284C7),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Chuyển sang Khám Dịch Vụ ngay',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Box hiển thị kết quả phân tích mức hưởng BHYT
                    if (controller.isBhytCardValid.value && !controller.isBhytBlacklisted.value) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified, color: Color(0xFF059669), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Mã thẻ hợp lệ: ${controller.bhytCardNumber.value}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669), fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '• Ký tự thứ 3 là "${controller.bhytCardNumber.value.length >= 3 ? controller.bhytCardNumber.value[2] : ''}" → Mức hưởng quyền lợi: ${controller.cardBenefitRateLabel}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF065F46), fontWeight: FontWeight.w500),
                            ),
                            if (controller.isSmallInvoice) ...[
                              const SizedBox(height: 4),
                              const Text(
                                '• Áp dụng quy tắc Hóa đơn nhỏ (< 379.500đ): Quỹ BHYT chi trả 100%, bạn được miễn đồng chi trả!',
                                style: TextStyle(fontSize: 12, color: Color(0xFF059669), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

            // =================== GIAI ĐOẠN 3: KHAI BÁO ƯU TIÊN THÔNG MINH ===================
            Obx(() => _buildPriorityDeclarationSection()),

            const SizedBox(height: 16),

            // =================== BẢNG CHI PHÍ DỰ KIẾN (REAL-TIME) ===================
            Obx(() {
              if (controller.bookingType.value == null) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Vui lòng chọn hình thức khám để xem chi tiết chi phí dự kiến',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final formatter = NumberFormat('#,###', 'vi_VN');
              final breakdown = controller.itemCostBreakdown;
              final totalBefore = controller.totalCostBeforeInsurance;
              final discount = controller.insuranceDiscount;
              final payable = controller.totalBookingCost;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.receipt_long, size: 20, color: Color(0xFF0056D2)),
                            SizedBox(width: 8),
                            Text(
                              'Chi phí khám dự kiến',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: controller.hasBhytBookings &&
                                    controller.hasServiceBookings
                                ? Colors.purple.shade50
                                : controller.hasBhytBookings
                                    ? Colors.green.shade50
                                    : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            controller.hasBhytBookings &&
                                    controller.hasServiceBookings
                                ? 'BHYT + Dịch vụ'
                                : controller.hasBhytBookings
                                    ? 'Giá Nhà Nước'
                                    : 'Giá Nội Bộ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: controller.hasBhytBookings &&
                                      controller.hasServiceBookings
                                  ? Colors.purple.shade700
                                  : controller.hasBhytBookings
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF0056D2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Chi tiết từng chuyên khoa (Quy tắc BHYT: Khoa 1 100%, Khoa 2+ 30%, Trần 2 lần mức giá 84.200đ)
                    const Text(
                      'Chi tiết theo quy định khám chuyên khoa:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),

                    ...breakdown.map((item) {
                      final bool isFirst = item['isFirst'] == true;
                      final bool isCapped = item['isCapped'] == true;
                      final String note = item['capNote'] ?? (isFirst ? '100% công khám' : 'Khoa thứ 2+: chỉ tính 30%');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item['name']} ($note)',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isCapped ? Colors.red.shade700 : Colors.black87,
                                  fontWeight: isCapped ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${formatter.format(item['cost'])}đ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: isCapped ? Colors.red.shade700 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Cảnh báo khi chạm hoặc vượt trần BHYT 2 lần mức giá (84.200đ)
                    if (controller.hasExceededBhytCap) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.bhytCapWarningText,
                                style: const TextStyle(
                                  color: Color(0xFF92400E),
                                  fontSize: 11.5,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Divider(height: 20),

                    // Tiền khám tổng trước giảm trừ
                    _buildCostRow('Tổng chi phí ban đầu', '${formatter.format(totalBefore)}đ'),

                    // Mức giảm BHYT
                    if (controller.hasBhytBookings) ...[
                      const SizedBox(height: 8),
                      _buildCostRow(
                        controller.isSmallInvoice
                            ? 'BHYT trả (Hóa đơn nhỏ < 379.500đ)'
                            : 'BHYT chi trả (${controller.cardBenefitRateLabel})',
                        '- ${formatter.format(discount)}đ',
                        valueColor: const Color(0xFF059669),
                      ),
                    ],

                    const Divider(height: 20),

                    // Tổng tiền BN phải thanh toán
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bệnh nhân thanh toán',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            if (controller.hasBhytBookings &&
                                controller.isSmallInvoice)
                              const Text(
                                'Được miễn đồng chi trả 100%',
                                style: TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                        Text(
                          payable == 0 ? '0đ (Miễn phí)' : '${formatter.format(payable)}đ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: payable == 0 ? const Color(0xFF059669) : const Color(0xFF0056D2),
                          ),
                        ),
                      ],
                    ),

                    if (controller.hasBhytBookings) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shield_outlined, size: 14, color: Color(0xFF64748B)),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '🛡️ Dữ liệu được đối soát tự động với Hệ thống Giám định BHYT Quốc gia phòng chống gom thuốc liên cơ sở.',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 32),

            // =================== BUTTON TIẾP TỤC ===================
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                final bool isReady = controller.bookingType.value != null &&
                    (!controller.isBhyt ||
                        controller.canSelectBhytForCurrentItem) &&
                    (!controller.isBhyt || (controller.isBhytCardValid.value && !controller.isBhytBlacklisted.value));

                String buttonText = 'Tiếp tục';
                if (controller.bookingType.value == null) {
                  buttonText = 'Vui lòng chọn hình thức khám';
                } else if (controller.isBhyt && controller.isBhytBlacklisted.value) {
                  buttonText = 'Thẻ bị Cảnh báo đen - Chuyển Khám Dịch vụ';
                } else if (controller.isBhyt && !controller.isBhytCardValid.value) {
                  buttonText = 'Nhập đúng mã thẻ BHYT (15 ký tự) để tiếp tục';
                }

                return ElevatedButton(
                  onPressed: isReady
                      ? () {
                          controller.addCurrentBookingToItems();
                          Get.to(() => const SummaryScreen());
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056D2),
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {Color valueColor = Colors.black87}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: valueColor),
        ),
      ],
    );
  }

  // =================== GIAI ĐOẠN 3: WIDGET KHAI BÁO ƯU TIÊN ===================
  Widget _buildPriorityDeclarationSection() {
    // 3.1: Tự động nhận diện Trẻ em (<6 tuổi) hoặc Người cao tuổi (>=75 tuổi)
    if (controller.isChild) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFCD34D)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF59E0B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.child_care, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚡ Diện ưu tiên: Trẻ em (${controller.patientAge} tuổi)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF92400E)),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Hệ thống tự động xếp vào hàng đợi ưu tiên (Mức 2).',
                    style: TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (controller.isElderly) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFCD34D)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF59E0B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.elderly, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚡ Diện ưu tiên: Người cao tuổi (${controller.patientAge} tuổi)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF92400E)),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Hệ thống tự động xếp vào hàng đợi ưu tiên (Mức 2).',
                    style: TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 3.2: Checkbox theo ngữ cảnh
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Khai báo diện ưu tiên khám (Tự nguyện)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Chọn nếu bệnh nhân thuộc các diện cần hỗ trợ khám trước:',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),

          // Checkbox Thai phụ (chỉ xuất hiện nếu là Nữ và tuổi 16-50)
          if (controller.canShowPregnancyOption) ...[
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              activeColor: const Color(0xFFD97706),
              title: const Text('Tôi đang mang thai', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Ưu tiên vào phòng khám (Mức 3)', style: TextStyle(fontSize: 11)),
              value: controller.isPregnant.value,
              onChanged: (val) {
                controller.isPregnant.value = val ?? false;
                if (controller.isPregnant.value) {
                  _showPriorityDocumentDialog(
                    title: 'Lưu ý diện ưu tiên: Thai phụ',
                    message:
                        'Quý khách vui lòng mang theo Sổ theo dõi thai định kỳ hoặc Giấy khám thai / Phiếu siêu âm khi đến quầy tiếp đón để đối chiếu xác thực diện ưu tiên.',
                    icon: Icons.pregnant_woman,
                  );
                }
              },
            ),
          ],

          // Checkbox Khuyết tật / Thương bệnh binh (hiển thị chung)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: const Color(0xFFD97706),
            title: const Text('Người khuyết tật / Thương bệnh binh',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: const Text('Ưu tiên vào phòng khám (Mức 3)', style: TextStyle(fontSize: 11)),
            value: controller.isDisabledOrVeteran.value,
            onChanged: (val) {
              controller.isDisabledOrVeteran.value = val ?? false;
              if (controller.isDisabledOrVeteran.value) {
                _showPriorityDocumentDialog(
                  title: 'Lưu ý diện ưu tiên: Khuyết tật / Thương bệnh binh',
                  message:
                      'Quý khách vui lòng xuất trình Giấy xác nhận khuyết tật hoặc Thẻ thương bệnh binh tại quầy tiếp đón để đối chiếu xác thực diện ưu tiên.',
                  icon: Icons.accessible,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showPriorityDocumentDialog({
    required String title,
    required String message,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.orange.shade800, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF334155)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0056D2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tôi đã hiểu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard({
    required bool isSelected,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String badge,
    required Color badgeColor,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? badgeColor.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? badgeColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: badgeColor.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 3))]
              : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio indicator
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? badgeColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: badgeColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),

            // Nội dung mô tả
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isSelected ? badgeColor : const Color(0xFF1F2937),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
