import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'controllers/booking_controller.dart';
import 'views/summary_screen.dart';

/// Màn hình Đặt Khám & Phân luồng BHYT / Dịch vụ
/// 2.1: Phân luồng trên Mobile UI:
/// - Tách rõ 2 lựa chọn: Khám Dịch vụ (giá nội bộ, thanh toán VNPay) vs Khám BHYT (áp giá nhà nước)
/// - Nếu chọn Khám BHYT: Tự lấy mã từ hồ sơ hoặc mở ô nhập có kiểm tra định dạng (Regex 15 ký tự) realtime.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingController controller = Get.put(BookingController());
  late final TextEditingController _bhytController;

  @override
  void initState() {
    super.initState();
    _bhytController = TextEditingController(text: controller.bhytCardNumber.value);

    // Tự động kiểm tra mã BHYT từ hồ sơ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isBhyt && controller.bhytCardNumber.value.isEmpty) {
        controller.autoFillBhytFromProfile();
        if (controller.bhytCardNumber.value.isNotEmpty) {
          _bhytController.text = controller.bhytCardNumber.value;
        }
      }
    });
  }

  @override
  void dispose() {
    _bhytController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FA),
      appBar: AppBar(
        title: const Text(
          'Đặt Lịch Khám & Phân Luồng',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0056D2), Color(0xFF1E88E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_hospital, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'Phân Luồng Đặt Khám',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bệnh nhân vui lòng chọn hình thức khám phù hợp để hệ thống áp dụng bảng giá và quy định thanh toán tương ứng.',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tiêu đề phân luồng
              const Text(
                'Chọn hình thức khám (Bắt buộc):',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),

              // LỰA CHỌN 1: KHÁM DỊCH VỤ
              Obx(() => _buildOptionCard(
                    title: 'Khám Dịch Vụ',
                    badgeText: 'Giá nội bộ - VNPay',
                    badgeColor: const Color(0xFF0284C7),
                    icon: Icons.payments_outlined,
                    description:
                        'Bệnh nhân thanh toán 100% theo giá nội bộ phòng khám qua cổng thanh toán VNPay. Không cần thẻ BHYT và không thực hiện giám định BHYT.',
                    isSelected: controller.bookingType.value == BookingType.dichVu,
                    onTap: () {
                      controller.setBookingType(BookingType.dichVu);
                    },
                  )),

              const SizedBox(height: 12),

              // LỰA CHỌN 2: KHÁM BHYT
              Obx(() => _buildOptionCard(
                    title: 'Khám BHYT (Bảo hiểm y tế)',
                    badgeText: 'Áp giá nhà nước',
                    badgeColor: const Color(0xFF059669),
                    icon: Icons.health_and_safety_outlined,
                    description:
                        'Áp giá khám quy định của nhà nước (42.100đ/lượt). Mức chi trả căn cứ ký tự thứ 3 của thẻ BHYT (80%, 95%, 100%). Tự động miễn đồng chi trả nếu hóa đơn < 379.500đ.',
                    isSelected: controller.bookingType.value == BookingType.bhyt,
                    onTap: () {
                      controller.setBookingType(BookingType.bhyt);
                      if (controller.bhytCardNumber.value.isNotEmpty) {
                        _bhytController.text = controller.bhytCardNumber.value;
                      }
                    },
                  )),

              const SizedBox(height: 20),

              // KHỐI NHẬP THẺ BHYT (HIỂN THỊ KHI CHỌN KHÁM BHYT)
              Obx(() {
                if (!controller.isBhyt) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: controller.isBhytCardValid.value
                          ? const Color(0xFF059669)
                          : Colors.orange.shade400,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
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
                            child: Text(
                              'Mã thẻ BHYT (15 ký tự):',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              controller.autoFillBhytFromProfile();
                              if (controller.bhytCardNumber.value.isNotEmpty) {
                                _bhytController.text = controller.bhytCardNumber.value;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Đã nạp mã thẻ BHYT từ hồ sơ: ${controller.bhytCardNumber.value}'),
                                    backgroundColor: const Color(0xFF059669),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Hồ sơ bệnh nhân chưa lưu mã BHYT.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.file_download_outlined, size: 14),
                            label: const Text('Lấy từ hồ sơ', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade50,
                              foregroundColor: const Color(0xFF0056D2),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Textbox kiểm tra Regex realtime
                      TextField(
                        controller: _bhytController,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 15,
                        decoration: InputDecoration(
                          hintText: 'Ví dụ: DN4010123456789',
                          prefixIcon: const Icon(Icons.credit_card, color: Color(0xFF059669)),
                          suffixIcon: controller.isBhytCardValid.value
                              ? const Icon(Icons.check_circle, color: Color(0xFF059669))
                              : (controller.bhytCardNumber.value.isNotEmpty
                                  ? const Icon(Icons.error_outline, color: Colors.red)
                                  : null),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
                          ),
                          counterText: '${controller.bhytCardNumber.value.length}/15 ký tự',
                        ),
                        onChanged: (val) {
                          controller.validateBhytCard(val);
                        },
                      ),

                      // Báo lỗi realtime
                      if (controller.bhytCardError.value != null && controller.bhytCardNumber.value.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.error_outline, size: 14, color: Colors.red),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                controller.bhytCardError.value!,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
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

                      // Thông báo mức quyền lợi BHYT giải mã từ ký tự thứ 3 (nếu thẻ hợp lệ & không blacklist)
                      if (controller.isBhytCardValid.value && !controller.isBhytBlacklisted.value) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.verified_user, color: Color(0xFF059669), size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Ký tự thứ 3: "${controller.bhytCardNumber.value[2]}" → Mức hưởng BHYT: ${controller.cardBenefitRateLabel}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF065F46),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              if (controller.isSmallInvoice) ...[
                                const SizedBox(height: 6),
                                const Text(
                                  '✨ Hóa đơn nhỏ (< 379.500đ): Bạn được quỹ BHYT chi trả 100%, miễn đồng chi trả!',
                                  style: TextStyle(
                                    color: Color(0xFF059669),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
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

              // BẢNG TÍNH PHÍ REAL-TIME THEO QUY TẮC MỚI
              Obx(() {
                if (controller.bookingType.value == null) {
                  return const SizedBox.shrink();
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
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chi phí khám dự tính',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: controller.isBhyt ? Colors.green.shade50 : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              controller.isBhyt ? 'Giá Nhà Nước' : 'Giá Nội Bộ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: controller.isBhyt ? const Color(0xFF059669) : const Color(0xFF0284C7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // BHYT: Tối đa 2 chuyên khoa / ngày khám (Lượt 1: 100%, Lượt 2: 30% giá nhà nước). Dịch vụ: 100% giá niêm yết
                      ...breakdown.map((item) {
                        final bool isCapped = item['isCapped'] == true;
                        final String note = item['capNote'] ??
                            (item['isBhyt'] == true ? 'Khám BHYT' : 'Khám Dịch vụ');
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
                                    color: isCapped ? Colors.red.shade700 : Colors.grey.shade700,
                                    fontWeight: isCapped ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${formatter.format(item['cost'])}đ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng tiền khám gốc:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          Text('${formatter.format(totalBefore)}đ', style: const TextStyle(fontSize: 13)),
                        ],
                      ),

                      if (controller.isBhyt) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.isSmallInvoice
                                  ? 'BHYT trả (Hóa đơn nhỏ 100%):'
                                  : 'BHYT trả (${controller.cardBenefitRateLabel}):',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                            ),
                            Text('- ${formatter.format(discount)}đ', style: const TextStyle(fontSize: 13, color: Color(0xFF059669), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],

                      const Divider(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Bệnh nhân thanh toán:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            payable == 0 ? '0đ (Miễn phí)' : '${formatter.format(payable)}đ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: payable == 0 ? const Color(0xFF059669) : const Color(0xFF0056D2),
                            ),
                          ),
                        ],
                      ),

                      if (controller.isBhyt) ...[
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
                                  '🛡️ Hệ thống Giám định BHYT Quốc gia kiểm soát tự động phòng chống gom thuốc liên cơ sở.',
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

              const SizedBox(height: 30),

              // BUTTON TIẾP TỤC
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final bool canProceed = controller.bookingType.value != null &&
                      (!controller.isBhyt || (controller.isBhytCardValid.value && !controller.isBhytBlacklisted.value));

                  String buttonLabel = 'Tiếp tục';
                  if (controller.bookingType.value == null) {
                    buttonLabel = 'Vui lòng chọn hình thức khám';
                  } else if (controller.isBhyt && controller.isBhytBlacklisted.value) {
                    buttonLabel = 'Thẻ bị Cảnh báo đen - Chuyển Khám Dịch vụ';
                  } else if (controller.isBhyt && !controller.isBhytCardValid.value) {
                    buttonLabel = 'Nhập đúng mã BHYT (15 ký tự) để tiếp tục';
                  }

                  return ElevatedButton(
                    onPressed: canProceed
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
                      buttonLabel,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityDeclarationSection() {
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 20),
              SizedBox(width: 8),
              Text(
                'Khai báo diện ưu tiên khám (Tùy chọn)',
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

  Widget _buildOptionCard({
    required String title,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required String description,
    required bool isSelected,
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: badgeColor, size: 24),
            ),
            const SizedBox(width: 12),
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
                          fontSize: 15,
                          color: isSelected ? badgeColor : const Color(0xFF1E293B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badgeText,
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
